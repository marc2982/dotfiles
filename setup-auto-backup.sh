#!/bin/bash
# Setup script to install nightly dotfiles backup cronjob

DOTFILES_DIR="$HOME/git/dotfiles"
BACKUP_SCRIPT="$DOTFILES_DIR/backup-dotfiles.sh"
CRON_TIME="0 2 * * *"  # 2 AM daily
LOG_FILE="/tmp/dotfiles-backup.log"

# Make backup script executable
chmod +x "$BACKUP_SCRIPT"

# Check if cronjob already exists
if crontab -l 2>/dev/null | grep -q "backup-dotfiles.sh"; then
    echo "Cronjob already exists. Current crontab:"
    crontab -l | grep "backup-dotfiles.sh"
    echo ""
    read -p "Remove and reinstall? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    # Remove existing cronjob
    crontab -l | grep -v "backup-dotfiles.sh" | crontab -
fi

# Add cronjob
(crontab -l 2>/dev/null; echo "$CRON_TIME $BACKUP_SCRIPT >> $LOG_FILE 2>&1") | crontab -

echo "✓ Cronjob installed successfully!"
echo ""
echo "Dotfiles will be automatically backed up daily at 2 AM."
echo "Logs will be written to: $LOG_FILE"
echo ""
echo "To view current crontab:"
echo "  crontab -l"
echo ""
echo "To test the backup script manually:"
echo "  $BACKUP_SCRIPT"
