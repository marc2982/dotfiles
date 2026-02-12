#!/bin/bash
# Migration script to copy existing configs into stow structure
# Run this once to set up the dotfiles repository

set -e

DOTFILES="$HOME/git/dotfiles"
cd "$DOTFILES"

echo "📦 Copying shell configs..."
cp ~/.zshrc shell/.zshrc
cp ~/.gitconfig shell/.gitconfig
cp ~/.gitignore_global shell/.gitignore_global

echo "🎨 Copying custom zsh theme..."
cp ~/.oh-my-zsh/themes/marc.zsh-theme shell/.oh-my-zsh/themes/

echo "🖥️  Copying tmux configs..."
cp ~/.tmux.conf tmux/.tmux.conf
cp -r ~/.config/tmux-powerline/* tmux/.config/tmux-powerline/

echo "✏️  Copying neovim config..."
cp -r ~/.config/nvim nvim/.config/

echo "📜 Copying atuin config..."
cp -r ~/.config/atuin atuin/.config/

echo ""
echo "✅ Files copied to dotfiles repo structure!"
echo ""
echo "Next steps:"
echo "1. Review changes: cd $DOTFILES && git status"
echo "2. Handle secrets in shell/.zshrc (see README.md)"
echo "3. Commit changes: git add -A && git commit -m 'Initial dotfiles setup'"
echo "4. Push to remote: git push"
echo ""
echo "Then to activate symlinks:"
echo "5. Backup originals: cd ~ && for f in .zshrc .gitconfig .gitignore_global .tmux.conf; do [[ -f \$f ]] && mv \$f \${f}.backup; done"
echo "6. Backup config dirs: for d in .config/nvim .config/atuin .config/tmux-powerline; do [[ -d \$d ]] && mv \$d \${d}.backup; done"
echo "7. Stow configs: cd $DOTFILES && stow shell tmux nvim atuin"
echo "8. Verify: ls -la ~/.zshrc ~/.tmux.conf ~/.config/nvim"
