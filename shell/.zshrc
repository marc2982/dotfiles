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

# PATH prepends. Order matters: later entries take precedence.
# Lowest priority first, highest last.
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Google Cloud SDK
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# Cargo
source "$HOME/.cargo/env"

# pass is required for secrets in .zshrc.local; skip that file gracefully if missing
if command -v pass &>/dev/null; then
    _pass_available=1
else
    echo "warning: pass not installed; skipping .zshrc.local" >&2
    _pass_available=0
fi

# ==============================================================================
# Shell options & history
# ==============================================================================
setopt extendedglob          # Advanced glob patterns (**, ^, etc.)
setopt notify                # Immediate background job notifications
setopt INTERACTIVE_COMMENTS  # Allow # comments at the prompt

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY            # Show expanded history command before running

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

# Drop OMZ git plugin's `g=git` alias; we use g (stefanmaric/g) for Go.
unalias g 2>/dev/null

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
bindkey  "^[[1;3D"  backward-word
bindkey  "^[[1;3C"  forward-word

# Ctrl-P: history search by prefix when typing, else previous command
# Alternative: try `zsh-history-substring-search` (oh-my-zsh plugin) for
# substring matching anywhere in the command instead of just the prefix.
_custom_ctrl_p() {
    if [[ ${#BUFFER} -gt 0 ]]; then
        zle history-beginning-search-backward
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

# Ctrl-F: accept autosuggestion (right-arrow/End also work)
bindkey '^F' autosuggest-accept

# ==============================================================================
# Plugins & integrations (after oh-my-zsh)
# ==============================================================================

# Atuin (after oh-my-zsh so keybinds are reliable)
eval "$(atuin init zsh --disable-up-arrow)"

# Autojump
source /usr/share/autojump/autojump.zsh

# tmux git autofetch on directory change
autoload -U add-zsh-hook
tmux-git-autofetch() {
    git rev-parse --git-dir &>/dev/null || return
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
alias less="less -FRXi"
alias tree="tree -C"
alias o="xdg-open"
alias clip="wl-copy"
alias clippaste="wl-paste"
alias oc="opencode"

# Pipe target: copies "$ <cmd>\n<output>" to the clipboard.
#   usage: <any pipeline> | clipcmd      # stdout only
#          <any pipeline> |& clipcmd     # stdout + stderr (zsh shorthand for 2>&1 |)
clipcmd() {
  emulate -L zsh
  local cmd=${history[$HISTCMD]}
  cmd=$(print -r -- "$cmd" | sed -E 's/[[:space:]]*\|[[:space:]]*clipcmd[[:space:]]*$//')
  # Strip ANSI escape codes from stdin so GUI paste handlers don't choke.
  { printf '$ %s\n' "$cmd"; sed -E 's/\x1b\[[0-9;]*[a-zA-Z]//g'; } | clip
}
alias realdir='realpath .'
alias rl='exec zsh'

# Nvim
alias vim="nvim"
alias v="nvim"

# Git
alias br="git br"
alias co="git commit -v -a"
alias ca="git commit -v -a --amend"
alias can="git commit -v -a --amend --no-edit"
alias st="git status"
alias gwts='wt switch'    # switch worktree (interactive picker if no arg)
gwtm() { wt switch '^' }  # jump to main worktree (default branch)

# Dotfiles
alias dotfiles='cd "$DOTFILES_DIR"'

# format zshrc functions
bbat() { bat -l zsh <(declare -f "$1") }

# ==============================================================================
# Functions
# ==============================================================================

# Sourced from shell/.zsh_functions (stow-symlinked to ~/.zsh_functions).
[[ -f ~/.zsh_functions ]] && source ~/.zsh_functions

# ==============================================================================
# Local overrides (not tracked in dotfiles)
# ==============================================================================
[[ -f ~/.zshrc.local && $_pass_available -eq 1 ]] && source ~/.zshrc.local
unset _pass_available

export PATH=$PATH:/home/marc/.spicetify

# bun completions
[ -s "/home/marc/.bun/_bun" ] && source "/home/marc/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"