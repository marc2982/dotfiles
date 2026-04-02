# Deduplicate PATH entries
typeset -U PATH

# Google Cloud SDK
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

export GOPATH="$HOME/go"; export GOROOT="$HOME/.go"; export PATH="$GOPATH/bin:$PATH"; # g-install: do NOT edit, see https://github.com/stefanmaric/g
# Go's VCS stamping breaks with worktrees nested inside bare repos (exits 128)
export GOFLAGS=-buildvcs=false
export ENABLE_LSP_TOOL=1

export EDITOR=nvim

if ! command -v pass &>/dev/null; then
  echo "pass is not installed. Aborting shell init." >&2
  return 1
fi

export GITLAB_TOKEN="$(pass show gitlab/api)"
export PERTMUX_GITLAB_TOKEN="$(pass show gitlab/api_pertmux)"

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# fix home and end keys
bindkey  "^[[1~"   beginning-of-line
bindkey  "^[[4~"   end-of-line
bindkey  "^A"      beginning-of-line
bindkey  "^E"      end-of-line
bindkey  "^[[3~"   delete-char
bindkey  "[[1;3D"  backward-word
bindkey  "[[1;3C"  forward-word

# Shell options
setopt extendedglob    # Advanced glob patterns (**, ^, etc.)
setopt notify          # Immediate background job notifications

# Git: use pager with scrolling that leaves output in terminal after exit
export GIT_PAGER="less -FRX"

# History
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

# Custom Ctrl-P: accept suggestion if text exists, otherwise navigate history
_custom_ctrl_p() {
    if [[ ${#BUFFER} -gt 0 ]]; then
        # Text exists: accept autosuggestion if available
        if (( $+functions[_zsh_autosuggest_accept] )); then
            zle autosuggest-accept
        fi
    else
        # Empty line: navigate up in history
        zle up-history
    fi
}
zle -N _custom_ctrl_p
bindkey '^P' _custom_ctrl_p

# Custom Ctrl-N: navigate down in history
_custom_ctrl_n() {
    if [[ ${#BUFFER} -eq 0 ]]; then
        zle down-history
    else
        zle history-beginning-search-forward
    fi
}
zle -N _custom_ctrl_n
bindkey '^N' _custom_ctrl_n

# aliases
alias ls="ls --color"
alias less="less -R"
alias tree="tree -C"
alias o="xdg-open"
alias clip="wl-copy"
alias realdir='realpath .'
alias clippaste="wl-paste"

# nvim
alias vim="nvim"
alias v="nvim"

# git stuff
alias br="git branch"
alias ch="git checkout"
alias co="git commit -v -a"
alias ca="git commit -v -a --amend"
alias can="git commit -v -a --amend --no-edit"
alias st="git status"

# Helper: outputs "short_hash|full_hash|commit_msg|file" per dirty file
# Groups: branch-local commits, UPSTREAM, or NEW
_git-last-touch-data() {
    local upstream_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/@@')
    if [ -z "$upstream_branch" ]; then
        upstream_branch="origin/main"
    fi

    local branch_commits=$(git log --pretty=format:"%H" $upstream_branch..HEAD 2>/dev/null)

    git status --porcelain | while IFS= read -r line; do
        file="${line:3}"
        commit_hash=$(git log -1 --pretty=format:"%h" -- "$file" 2>/dev/null)
        commit_hash_full=$(git log -1 --pretty=format:"%H" -- "$file" 2>/dev/null)

        if [ -n "$commit_hash" ]; then
            if echo "$branch_commits" | grep -q "^$commit_hash_full$"; then
                commit_msg=$(git log -1 --pretty=format:"%h %s" "$commit_hash")
                echo "$commit_hash|$commit_hash_full|$commit_msg|$file"
            else
                commit_msg=$(git log -1 --pretty=format:"%h %s" "$commit_hash")
                echo "UPSTREAM|UPSTREAM|⚠️  $commit_msg (UPSTREAM - do not amend)|$file"
            fi
        else
            echo "NEW|NEW|(new file)|$file"
        fi
    done | sort
}

# Show which commit last touched each dirty file (grouped by commit)
# Only shows commits on current branch (safe to amend)
git-last-touch() {
    echo "Dirty files grouped by last commit (current branch only):"
    echo "=========================================================="

    _git-last-touch-data | awk -F'|' '
        BEGIN { prev_commit = "" }
        {
            commit = $1
            commit_msg = $3
            file = $4

            if (commit != prev_commit) {
                if (prev_commit != "") print ""
                print "\n" commit_msg ":"
                prev_commit = commit
            }
            print "  • " file
        }
    '
}

# Like git-last-touch, but creates fixup! commits for each group
git-last-touch-fixup() {
    echo "Dirty files grouped by last commit (current branch only):"
    echo "=========================================================="

    local data=$(_git-last-touch-data)

    # Display the same output as git-last-touch
    echo "$data" | awk -F'|' '
        BEGIN { prev_commit = "" }
        {
            commit = $1
            commit_msg = $3
            file = $4

            if (commit != prev_commit) {
                if (prev_commit != "") print ""
                print "\n" commit_msg ":"
                prev_commit = commit
            }
            print "  • " file
        }
    '

    echo ""
    echo "=========================================================="
    echo "Creating fixup commits..."
    echo ""

    local prev_hash=""
    local files=()
    local skipped=()

    # Process each line, grouping files by commit hash
    while IFS='|' read -r short_hash full_hash commit_msg file; do
        if [[ "$short_hash" == "UPSTREAM" || "$short_hash" == "NEW" ]]; then
            skipped+=("$file")
            continue
        fi

        # When we hit a new commit group, flush the previous group
        if [[ -n "$prev_hash" && "$full_hash" != "$prev_hash" ]]; then
            git add -- "${files[@]}"
            git commit --fixup="$prev_hash"
            files=()
        fi

        prev_hash="$full_hash"
        files+=("$file")
    done <<< "$data"

    # Flush the last group
    if [[ -n "$prev_hash" && ${#files[@]} -gt 0 ]]; then
        git add -- "${files[@]}"
        git commit --fixup="$prev_hash"
    fi

    if [[ ${#skipped[@]} -gt 0 ]]; then
        echo ""
        echo "Skipped (upstream/new - no branch commit to fixup):"
        for f in "${skipped[@]}"; do
            echo "  • $f"
        done
    fi
}

# Dotfiles management
export DOTFILES_DIR="$HOME/git/dotfiles"
alias dotfiles='cd "$DOTFILES_DIR"'

# Unalias in case these were previously defined as aliases
unalias dotfiles-sync 2>/dev/null
unalias dotfiles-status 2>/dev/null

dotfiles-sync() {
    (
        cd "$DOTFILES_DIR" || return 1
        git add -A
        if git commit -m "Update dotfiles $(date +%Y-%m-%d)"; then
            git push
        else
            echo "No changes to commit"
        fi
    )
}

dotfiles-status() {
    (cd "$DOTFILES_DIR" && git status)
}

dotfiles-diff() {
    (cd "$DOTFILES_DIR" && git diff)
}

function mkcd() {
    mkdir -p "$@"
    cd "$@"
}

eval "$(atuin init zsh --disable-up-arrow)"

tmux-git-autofetch() {
    (/home/marc/.tmux/plugins/tmux-git-autofetch/git-autofetch.tmux --current &)
}
add-zsh-hook chpwd tmux-git-autofetch

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="marc"
plugins=(
	aliases
	git
    zsh-autosuggestions
)
source $ZSH/oh-my-zsh.sh

source /usr/share/autojump/autojump.zsh

# Load work-specific config (not tracked in dotfiles)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# peon-ping quick controls
alias peon="bash /home/marc/.claude/hooks/peon-ping/peon.sh"
[ -f /home/marc/.claude/hooks/peon-ping/completions.bash ] && source /home/marc/.claude/hooks/peon-ping/completions.bash

# memory check
memhogs() {
  free -h | awk '/^Mem:/{printf "RAM:  %s used / %s total (%s available, %s free + %s buff/cache)\n",$3,$2,$7,$4,$6} /^Swap:/{printf "Swap: %s used / %s total (%s free)\n",$3,$2,$4}'
  echo ""
  ps aux --sort=-%mem | awk 'NR==1{printf "%-7s %-7s %s\n","MEM%","USER","COMMAND"} NR>1&&NR<=4{printf "%-7s %-7s %s\n",$4"%",$1,$11}'
}

# opencode
export PATH=/home/marc/.opencode/bin:$PATH
unalias opencode 2&> /dev/null
# run opencode on port 0 for pertmux support but dont add port for opencode commands (like auth)
opencode() { if [ $# -eq 0 ]; then command opencode --port 0; else command opencode "$@"; fi; }

# cargo
source "$HOME/.cargo/env"

# override oh-my-zsh alias with my better one
unalias gwt 2>/dev/null
gwt() { git fetch --all && git worktree add --track -b "$1" ".worktrees/$1" "${2:-origin/main}" && cd ".worktrees/$1"; }

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
