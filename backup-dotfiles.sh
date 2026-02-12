#!/bin/bash
# Automatic dotfiles backup script
# Can be run manually or via cron

DOTFILES_DIR="$HOME/git/dotfiles"

cd "$DOTFILES_DIR" || exit 1

# Add all changes
/usr/bin/git add -A

# Check if there are changes to commit
if ! /usr/bin/git diff --cached --quiet; then
    # Commit and push
    /usr/bin/git commit -m "Auto-backup dotfiles $(date +%Y-%m-%d)"
    /usr/bin/git push
    echo "$(date): Dotfiles backed up successfully"
else
    echo "$(date): No changes to backup"
fi
