# ==============================================================================
# Environment & PATH
# ==============================================================================
typeset -U PATH  # Deduplicate PATH entries

export EDITOR=nvim
export GOPATH="$HOME/go"; export GOROOT="$HOME/.go"; export PATH="$GOPATH/bin:$PATH"; # g-install: do NOT edit, see https://github.com/stefanmaric/g
export GOFLAGS=-buildvcs=false  # Go's VCS stamping breaks with worktrees nested inside bare repos (exits 128)
export ENABLE_LSP_TOOL=1
export GIT_PAGER="less -FRX"  # scrollable, leaves output in terminal after exit
export DOTFILES_DIR="$HOME/git/dotfiles"

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH=/home/marc/.opencode/bin:$PATH

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Google Cloud SDK
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# Cargo
source "$HOME/.cargo/env"

# pass is required for secrets loaded in .zshrc.local
if ! command -v pass &>/dev/null; then
  echo "pass is not installed. Aborting shell init." >&2
  return 1
fi

# ==============================================================================
# Shell options & history
# ==============================================================================
setopt extendedglob    # Advanced glob patterns (**, ^, etc.)
setopt notify          # Immediate background job notifications

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# ==============================================================================
# oh-my-zsh (runs compinit internally)
# ==============================================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="marc"
plugins=(
	aliases
	git
    zsh-autosuggestions
)
source $ZSH/oh-my-zsh.sh

# Completion styles (after oh-my-zsh compinit)
zstyle ':completion:*' menu select

# ==============================================================================
# Keybindings (after oh-my-zsh so nothing gets clobbered)
# ==============================================================================

# Fix home/end/delete/word-movement keys
bindkey  "^[[1~"   beginning-of-line
bindkey  "^[[4~"   end-of-line
bindkey  "^A"      beginning-of-line
bindkey  "^E"      end-of-line
bindkey  "^[[3~"   delete-char
bindkey  "[[1;3D"  backward-word
bindkey  "[[1;3C"  forward-word

# Ctrl-P: accept autosuggestion if text exists, otherwise navigate history
_custom_ctrl_p() {
    if [[ ${#BUFFER} -gt 0 ]]; then
        if (( $+functions[_zsh_autosuggest_accept] )); then
            zle autosuggest-accept
        fi
    else
        zle up-history
    fi
}
zle -N _custom_ctrl_p
bindkey '^P' _custom_ctrl_p

# Ctrl-N: navigate down in history
_custom_ctrl_n() {
    if [[ ${#BUFFER} -eq 0 ]]; then
        zle down-history
    else
        zle history-beginning-search-forward
    fi
}
zle -N _custom_ctrl_n
bindkey '^N' _custom_ctrl_n

# ==============================================================================
# Plugins & integrations (after oh-my-zsh)
# ==============================================================================

# Atuin (after oh-my-zsh so keybinds are reliable)
eval "$(atuin init zsh --disable-up-arrow)"

# Autojump
source /usr/share/autojump/autojump.zsh

# tmux git autofetch on directory change
tmux-git-autofetch() {
    (/home/marc/.tmux/plugins/tmux-git-autofetch/git-autofetch.tmux --current &)
}
add-zsh-hook chpwd tmux-git-autofetch

# wt (worktree tool)
if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

# ==============================================================================
# Aliases
# ==============================================================================

# General
alias ls="ls --color"
alias less="less -R"
alias tree="tree -C"
alias o="xdg-open"
alias clip="wl-copy"
alias clippaste="wl-paste"
alias realdir='realpath .'

# Nvim
alias vim="nvim"
alias v="nvim"

# Git
alias br="git branch"
alias ch="git checkout"
alias co="git commit -v -a"
alias ca="git commit -v -a --amend"
alias can="git commit -v -a --amend --no-edit"
alias st="git status"

# Dotfiles
alias dotfiles='cd "$DOTFILES_DIR"'

# ==============================================================================
# Functions
# ==============================================================================

mkcd() {
    mkdir -p "$@"
    cd "$@"
}

memhogs() {
  free -h | awk '/^Mem:/{printf "RAM:  %s used / %s total (%s available, %s free + %s buff/cache)\n",$3,$2,$7,$4,$6} /^Swap:/{printf "Swap: %s used / %s total (%s free)\n",$3,$2,$4}'
  echo ""
  ps aux --sort=-%mem | awk 'NR==1{printf "%-7s %-9s %-7s %s\n","MEM%","RSS","USER","COMMAND"} NR>1&&NR<=6{rss=$6; if(rss>=1048576){h=sprintf("%.1fG",rss/1048576)}else if(rss>=1024){h=sprintf("%.0fM",rss/1024)}else{h=sprintf("%dK",rss)}; printf "%-7s %-9s %-7s %s\n",$4"%",h,$1,$11}'
}

# OpenCode: use port 0 for pertmux support but not for subcommands (like auth)
unalias opencode 2>/dev/null
opencode() { if [ $# -eq 0 ]; then command opencode --port 0; else command opencode "$@"; fi; }

# --- Dotfiles management ---
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

# --- Git helpers ---

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

# ==============================================================================
# Local overrides (not tracked in dotfiles)
# ==============================================================================
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
