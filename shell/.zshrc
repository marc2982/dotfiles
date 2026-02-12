# Google Cloud SDK
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

export GOPATH="$HOME/go"; export GOROOT="$HOME/.go"; export PATH="$GOPATH/bin:$PATH"; # g-install: do NOT edit, see https://github.com/stefanmaric/g
export ENABLE_LSP_TOOL=1

export EDITOR=nvim

gitlab_token="$HOME/.tokens/gitlab_token"
if [[ ! -f "$gitlab_token" ]]; then
    echo "Warning: $gitlab_token not found"
fi
export GITLAB_TOKEN=$(cat $gitlab_token 2>/dev/null)

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

# Git: disable pager for commands (write directly to terminal)
export GIT_PAGER=cat

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

bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward

# aliases
alias ls="ls --color"
alias less="less -R"
alias tree="tree -C"
alias o="xdg-open"
alias clip="wl-copy"
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

# Dotfiles management
export DOTFILES_DIR="$HOME/git/dotfiles"
alias dotfiles='cd "$DOTFILES_DIR"'

# Unalias in case these were previously defined as aliases
unalias dotfiles-sync 2>/dev/null
unalias dotfiles-status 2>/dev/null

dotfiles-sync() {
    pushd "$DOTFILES_DIR" > /dev/null || return 1
    git add -A
    if git commit -m "Update dotfiles $(date +%Y-%m-%d)"; then
        git push
    else
        echo "No changes to commit"
    fi
    popd > /dev/null
}

dotfiles-status() {
    pushd "$DOTFILES_DIR" > /dev/null || return 1
    git status
    popd > /dev/null
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
