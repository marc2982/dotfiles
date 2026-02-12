#!/bin/bash
# Script to install the custom zsh theme to oh-my-zsh

set -e

THEME_SOURCE="$HOME/git/dotfiles/themes/marc.zsh-theme"
THEME_DEST="$HOME/.oh-my-zsh/custom/themes/marc.zsh-theme"

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "❌ oh-my-zsh is not installed"
    echo "Install it first: sh -c \"\$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
    exit 1
fi

if [[ ! -f "$THEME_SOURCE" ]]; then
    echo "❌ Theme file not found at $THEME_SOURCE"
    exit 1
fi

mkdir -p "$HOME/.oh-my-zsh/custom/themes"
cp "$THEME_SOURCE" "$THEME_DEST"

echo "✅ Installed marc.zsh-theme to $THEME_DEST"
echo "   Make sure your .zshrc has: ZSH_THEME=\"marc\""
