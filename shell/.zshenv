. "$HOME/.cargo/env"

# Worktree helpers must load in non-interactive shells too (agent/tool shells
# read .zshenv, not .zshrc). Guarded so a missing work-dotfiles repo is harmless.
[[ -f "$HOME/git/dotfiles-synctera/shell/worktree-fns.zsh" ]] && \
    source "$HOME/git/dotfiles-synctera/shell/worktree-fns.zsh"
