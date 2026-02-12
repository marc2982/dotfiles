# The next line updates PATH for the Google Cloud SDK.
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if [ -f '/Users/marc/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/marc/google-cloud-sdk/path.zsh.inc'; fi
else
    # Linux
    if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
fi

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

# TODO look into these
# setopt beep extendedglob nomatch notify
# unsetopt autocd
# bindkey -v
# zstyle :compinstall filename '/home/marc/.zshrc'

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
alias dotfiles='cd ~/git/dotfiles'
alias dotfiles-sync='cd ~/git/dotfiles && git add -A && git commit -m "Update dotfiles $(date +%Y-%m-%d)" && git push && cd -'
alias dotfiles-status='cd ~/git/dotfiles && git status && cd -'

function mkcd() {
    mkdir -p "$@"
    cd "$@"
}


# The next line updates PATH for the Google Cloud SDK.
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if [ -f '/Users/marc/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/marc/google-cloud-sdk/path.zsh.inc'; fi
    if [ -f '/Users/marc/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/marc/google-cloud-sdk/completion.zsh.inc'; fi
else
    # Linux
    if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
    if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi
fi
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
