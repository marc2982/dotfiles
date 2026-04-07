#!/bin/bash
# Automatic dotfiles backup script
# Can be run manually or via systemd timer (dotfiles-backup.timer)

DOTFILES_DIR="$HOME/git/dotfiles"

# Ensure SSH agent is available (systemd service sets SSH_AUTH_SOCK,
# but for manual runs we fall back to GNOME Keyring)
: "${SSH_AUTH_SOCK:="/run/user/$(id -u)/keyring/.ssh"}"
export SSH_AUTH_SOCK

cd "$DOTFILES_DIR" || exit 1

# Add all changes
/usr/bin/git add -A

# Check if there are changes to commit
if ! /usr/bin/git diff --cached --quiet; then
	/usr/bin/git commit -m "Auto-backup dotfiles $(date +%Y-%m-%d)"
	/usr/bin/git push
	echo "Dotfiles backed up successfully"
else
	echo "No changes to backup"
fi
