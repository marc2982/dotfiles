# Dotfiles

Personal configuration files managed with GNU Stow.

## Structure

- `shell/` - Bash, Zsh, Git configs
- `tmux/` - Tmux config and powerline theme
- `nvim/` - Neovim configuration
- `atuin/` - Shell history manager config

## Setup on New Machine

### Quick Start (Automated)

For a fully automated setup, run the setup script:

```bash
# Clone the repository
git clone <your-repo-url> ~/git/dotfiles
cd ~/git/dotfiles

# Run with sudo to auto-install dependencies
yes | sudo ./setup-new-workspace.sh

# Or run without sudo (will prompt for missing dependencies)
./setup-new-workspace.sh
```

The script will:

- Install required dependencies (stow, git, zsh, tmux, nvim, atuin, autojump)
- Create `~/.tokens/` directory
- Set up `.gitconfig.local` and `.zshrc.local` from templates
- Install oh-my-zsh and custom theme
- Install zsh-autosuggestions plugin
- Backup existing configs
- Create symlinks with stow
- Install Tmux Plugin Manager (TPM)
- Optionally set up automatic nightly backups

See the "Manual Setup" section below for detailed step-by-step instructions.

---

### Manual Setup

If you prefer to set up manually or need to understand each step:

### 1. Install Dependencies

```bash
# Fedora/RHEL
sudo dnf install stow

# Debian/Ubuntu
sudo apt install stow
```

### 2. Clone Repository

```bash
git clone <your-repo-url> ~/git/dotfiles
cd ~/git/dotfiles
```

### 3. Set Up Secrets

These files contain sensitive information and are NOT in the repository:

#### Tokens

```bash
# Create tokens directory
mkdir -p ~/.tokens
chmod 700 ~/.tokens

# Add your tokens
echo "your-gitlab-token" > ~/.tokens/gitlab_token
echo "your-coderabbit-token" > ~/.tokens/coderabbit
echo "your-linear-token" > ~/.tokens/linear
chmod 600 ~/.tokens/*
```

The `.zshrc` will automatically load these tokens if they exist.

#### Git Personal Config

```bash
# Create local git config with your personal information
cp ~/git/dotfiles/shell/.gitconfig.local.template ~/.gitconfig.local

# Edit with your details
vim ~/.gitconfig.local
```

The `.gitconfig` includes `.gitconfig.local` for your name, email, and work-specific settings.

#### Work-Specific Shell Config

```bash
# Create local zsh config with work-specific aliases and functions
cp ~/git/dotfiles/shell/.zshrc.local.template ~/.zshrc.local

# Edit with your work-specific customizations
vim ~/.zshrc.local
```

The `.zshrc` sources `.zshrc.local` for work-specific aliases, functions, and configurations.

### 4. Install oh-my-zsh and Custom Theme

```bash
# Install oh-my-zsh if not already installed
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install custom theme
cd ~/git/dotfiles
./install-theme.sh
```

### 5. Stow Configurations

```bash
cd ~/git/dotfiles

# Backup existing configs if any
for file in ~/.zshrc ~/.gitconfig ~/.gitignore_global ~/.tmux.conf; do
    [[ -f "$file" ]] && mv "$file" "${file}.backup"
done

# Backup existing config directories
for dir in ~/.config/nvim ~/.config/atuin ~/.config/tmux-powerline; do
    [[ -d "$dir" ]] && mv "$dir" "${dir}.backup"
done

# Create symlinks
stow -t ~ shell tmux nvim atuin

# Verify symlinks
ls -la ~/.zshrc ~/.tmux.conf ~/.config/nvim ~/.config/atuin
```

### 6. Install Tmux Plugin Manager (TPM)

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Start tmux and install plugins
tmux
# Press prefix (Ctrl-s) + I to install plugins
```

### 7. Neovim Plugins

Neovim plugins will auto-install on first launch via lazy.nvim:

```bash
nvim
# Wait for plugins to install
```

## Usage

### Making Changes

Edit files directly - they're symlinked to the repo:

```bash
# Edit your zshrc
vim ~/.zshrc

# Changes are immediately reflected in the repo
cd ~/git/dotfiles
git status
git add -A
git commit -m "Update zsh config"
git push
```

### Helpful Aliases and Functions

The following are included in `.zshrc`:

```bash
dotfiles           # cd to dotfiles directory
dotfiles-sync      # commit and push changes (safe if nothing to commit)
dotfiles-status    # show git status
```

### Automatic Backup

To automatically backup your dotfiles nightly at 2 AM:

```bash
cd ~/git/dotfiles
./setup-auto-backup.sh
```

This installs a cronjob that runs `backup-dotfiles.sh` daily. The script only commits and pushes if there are changes.

To manually run a backup at any time:

```bash
~/git/dotfiles/backup-dotfiles.sh
# or use the function:
dotfiles-sync
```

View backup logs:

```bash
tail -f /tmp/dotfiles-backup.log
```

### Managing Packages

```bash
cd ~/git/dotfiles

# Enable a package
stow shell

# Disable a package
stow -D shell

# Re-stow (useful after moving files)
stow -R shell
```

## Important Notes

### Tmux Powerline

Custom powerline theme located at `tmux/.config/tmux-powerline/themes/marc.sh`.

The `tmux-git-autofetch` segment is configured for `~/git/<company>/*` - adjust if needed.

### Atuin

Atuin stores encryption keys in `~/.local/share/atuin/` which is NOT backed up.

To sync history across machines, you'll need to:

1. Back up the key manually
2. Or re-login to atuin on each machine

## Troubleshooting

### Stow Conflicts

If stow reports conflicts:

```bash
# Remove the conflicting file
rm ~/.zshrc

# Try stowing again
stow shell
```

### Broken Symlinks

If symlinks break after moving the repo:

```bash
cd ~/git/dotfiles
stow -R shell tmux nvim atuin
```

### Verifying Setup

```bash
# Check symlinks point to dotfiles repo
ls -la ~ | grep " -> .*dotfiles"
ls -la ~/.config | grep " -> .*dotfiles"

# Test configurations
zsh -c 'echo $SHELL'
tmux source ~/.tmux.conf
nvim --version
```
