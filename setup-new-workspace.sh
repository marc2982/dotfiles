#!/bin/bash
# setup-new-workspace.sh
# Automates dotfiles setup on a new machine

set -e          # Exit on error
set -o pipefail # Exit on pipe failures

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="/tmp/dotfiles-setup.log"
BACKUP_SUFFIX=".backup"

# Detect the real user's home directory (handle sudo case)
if [[ -n "$SUDO_USER" ]]; then
	REAL_USER="$SUDO_USER"
	REAL_HOME=$(eval echo "~$SUDO_USER")
else
	REAL_USER="$USER"
	REAL_HOME="$HOME"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging
log() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" >>"$LOG_FILE"
}

print_banner() {
	cat <<"EOF"
╔══════════════════════════════════════════════════════════╗
║        Dotfiles Workspace Setup                          ║
╚══════════════════════════════════════════════════════════╝
EOF
	echo -e "${BLUE}Working directory: $DOTFILES_DIR${NC}\n"
	log "Setup started in $DOTFILES_DIR"
}

print_step() {
	echo -e "\n${BLUE}[$1] $2...${NC}"
	log "Step $1: $2"
}

print_success() {
	echo -e "${GREEN}    ✓ $1${NC}"
	log "Success: $1"
}

print_info() {
	echo -e "${YELLOW}    → $1${NC}"
	log "Info: $1"
}

print_error() {
	echo -e "${RED}    ✗ $1${NC}" >&2
	log "Error: $1"
}

prompt_yes_no() {
	local prompt="$1"
	local default="${2:-y}"
	local response

	if [[ "$default" == "y" ]]; then
		read -p "$prompt [Y/n]: " response
		response=${response:-y}
	else
		read -p "$prompt [y/N]: " response
		response=${response:-n}
	fi

	[[ "$response" =~ ^[Yy]$ ]]
}

check_command() {
	command -v "$1" &>/dev/null
}

# Run command as the real user (not root) when script is run with sudo
run_as_user() {
	if [[ -n "$SUDO_USER" ]]; then
		sudo -u "$SUDO_USER" HOME="$REAL_HOME" "$@"
	else
		"$@"
	fi
}

check_and_install_dependencies() {
	print_step "✓" "Checking and installing dependencies"

	local deps_core=("stow" "git" "zsh" "tmux" "nvim")
	local deps_shell=("atuin" "autojump")
	local missing_core=()
	local missing_shell=()
	local has_sudo=false

	# Check if running with sudo
	if [[ $EUID -eq 0 ]] || sudo -n true 2>/dev/null; then
		has_sudo=true
	fi

	# Check core dependencies
	for dep in "${deps_core[@]}"; do
		if check_command "$dep"; then
			print_success "$dep installed"
		else
			missing_core+=("$dep")
		fi
	done

	# Check shell tools
	for dep in "${deps_shell[@]}"; do
		if check_command "$dep"; then
			print_success "$dep installed"
		else
			missing_shell+=("$dep")
		fi
	done

	# Install missing dependencies
	local all_missing=("${missing_core[@]}" "${missing_shell[@]}")
	if [[ ${#all_missing[@]} -gt 0 ]]; then
		if [[ "$has_sudo" == true ]]; then
			print_info "Installing missing packages: ${all_missing[*]}"
			if [[ $EUID -eq 0 ]]; then
				dnf install -y "${all_missing[@]}" 2>&1 | tee -a "$LOG_FILE"
			else
				sudo dnf install -y "${all_missing[@]}" 2>&1 | tee -a "$LOG_FILE"
			fi

			for dep in "${all_missing[@]}"; do
				if check_command "$dep"; then
					print_success "$dep installed"
				else
					print_error "Failed to install $dep"
				fi
			done
		else
			print_error "Missing dependencies: ${all_missing[*]}"
			print_error "Run with sudo to auto-install, or manually install:"
			echo -e "${RED}    sudo dnf install ${all_missing[*]}${NC}"
			exit 1
		fi
	fi
}

setup_tokens_dir() {
	print_step "1/10" "Creating tokens directory"

	if [[ -d "$REAL_HOME/.tokens" ]]; then
		print_success "~/.tokens already exists"
	else
		run_as_user mkdir -p "$REAL_HOME/.tokens"
		run_as_user chmod 700 "$REAL_HOME/.tokens"
		print_success "Created ~/.tokens with 700 permissions"
	fi
	print_info "Remember to add your tokens later!"
}

setup_templates() {
	print_step "2/10" "Setting up template files"

	local gitconfig_template="$DOTFILES_DIR/shell/.gitconfig.local.template"
	local gitconfig_dest="$REAL_HOME/.gitconfig.local"
	local zshrc_template="$DOTFILES_DIR/shell/.zshrc.local.template"
	local zshrc_dest="$REAL_HOME/.zshrc.local"
	local files_created=()

	if [[ ! -f "$gitconfig_dest" ]]; then
		run_as_user cp "$gitconfig_template" "$gitconfig_dest"
		print_success "Created ~/.gitconfig.local from template"
		files_created+=("$gitconfig_dest")
	else
		print_success "~/.gitconfig.local already exists"
	fi

	if [[ ! -f "$zshrc_dest" ]]; then
		run_as_user cp "$zshrc_template" "$zshrc_dest"
		print_success "Created ~/.zshrc.local from template"
		files_created+=("$zshrc_dest")
	else
		print_success "~/.zshrc.local already exists"
	fi

	if [[ ${#files_created[@]} -gt 0 ]] && [[ -t 0 ]]; then
		if prompt_yes_no "    Edit templates now?" "n"; then
			for file in "${files_created[@]}"; do
				print_info "Opening $file in ${EDITOR:-nvim}..."
				run_as_user ${EDITOR:-nvim} "$file"
			done
		fi
	elif [[ ${#files_created[@]} -gt 0 ]]; then
		print_info "Edit templates later: ${files_created[*]}"
	fi
}

install_oh_my_zsh() {
	print_step "3/10" "Installing oh-my-zsh"

	if [[ -d "$REAL_HOME/.oh-my-zsh" ]]; then
		print_success "oh-my-zsh already installed"
	else
		if prompt_yes_no "    Install oh-my-zsh?" "y"; then
			print_info "Installing oh-my-zsh..."
			if run_as_user sh -c "RUNZSH=no KEEP_ZSHRC=yes sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\"" 2>&1 | tee -a "$LOG_FILE"; then
				print_success "oh-my-zsh installed"
			else
				print_error "Failed to install oh-my-zsh"
				exit 1
			fi
		else
			print_info "Skipped oh-my-zsh installation"
		fi
	fi

	# Install zsh-autosuggestions
	local autosuggestions_dir="$REAL_HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
	if [[ -d "$REAL_HOME/.oh-my-zsh" ]]; then
		if [[ ! -d "$autosuggestions_dir" ]]; then
			print_info "Installing zsh-autosuggestions..."
			if run_as_user git clone https://github.com/zsh-users/zsh-autosuggestions "$autosuggestions_dir" 2>&1 | tee -a "$LOG_FILE"; then
				print_success "zsh-autosuggestions installed"
			else
				print_error "Failed to install zsh-autosuggestions"
				exit 1
			fi
		else
			print_success "zsh-autosuggestions already installed"
		fi
	fi
}

install_theme() {
	print_step "4/10" "Installing custom zsh theme"

	if [[ -f "$DOTFILES_DIR/install-theme.sh" ]]; then
		if run_as_user REAL_HOME="$REAL_HOME" bash "$DOTFILES_DIR/install-theme.sh" 2>&1 | tee -a "$LOG_FILE"; then
			print_success "Theme installed to ~/.oh-my-zsh/custom/themes/"
		else
			print_info "Theme installation skipped or failed"
		fi
	else
		print_error "install-theme.sh not found"
	fi
}

backup_existing_configs() {
	print_step "5/10" "Backing up existing configs"

	local files_to_check=(
		"$REAL_HOME/.zshrc"
		"$REAL_HOME/.gitconfig"
		"$REAL_HOME/.gitignore_global"
		"$REAL_HOME/.tmux.conf"
		"$REAL_HOME/.config/nvim/init.lua"
		"$REAL_HOME/.config/atuin/config.toml"
	)

	local backed_up=false
	for file in "${files_to_check[@]}"; do
		# Skip if file doesn't exist
		if [[ ! -e "$file" ]]; then
			continue
		fi

		# Check if file or any parent directory is a symlink to dotfiles repo
		local realpath=$(readlink -f "$file" 2>/dev/null)
		if [[ "$realpath" == "$DOTFILES_DIR"* ]]; then
			# File is inside dotfiles repo (through symlink), skip it
			continue
		fi

		# Only backup regular files that aren't from this repo
		if [[ -f "$file" ]] && [[ ! -L "$file" ]]; then
			run_as_user mv "$file" "${file}${BACKUP_SUFFIX}"
			print_success "Backed up $file → ${file}${BACKUP_SUFFIX}"
			backed_up=true
		fi
	done

	if [[ "$backed_up" == false ]]; then
		print_info "No existing configs to backup"
	fi
}

run_stow() {
	print_step "6/10" "Creating symlinks with stow"

	local packages=("shell" "tmux" "nvim" "atuin")
	echo -e "    ${YELLOW}Packages: ${packages[*]}${NC}"

	if prompt_yes_no "    Create symlinks?" "y"; then
		cd "$DOTFILES_DIR"
		for package in "${packages[@]}"; do
			if [[ -d "$package" ]]; then
				if run_as_user stow -t "$REAL_HOME" "$package" 2>&1 | tee -a "$LOG_FILE"; then
					print_success "Stowed $package"
				else
					print_error "Failed to stow $package"
					exit 1
				fi
			else
				print_error "Package directory $package not found"
				exit 1
			fi
		done
	else
		print_info "Skipped stow"
	fi
}

install_tpm() {
	print_step "7/10" "Installing Tmux Plugin Manager"

	local tpm_dir="$REAL_HOME/.tmux/plugins/tpm"
	if [[ -d "$tpm_dir" ]]; then
		print_success "TPM already installed"
	else
		print_info "Cloning TPM..."
		if run_as_user git clone https://github.com/tmux-plugins/tpm "$tpm_dir" 2>&1 | tee -a "$LOG_FILE"; then
			print_success "Cloned TPM to ~/.tmux/plugins/tpm"
		else
			print_error "Failed to clone TPM"
			exit 1
		fi
	fi
}

setup_auto_backup() {
	print_step "8/10" "Setting up automatic backups"

	if [[ -f "$DOTFILES_DIR/setup-auto-backup.sh" ]]; then
		if prompt_yes_no "    Setup nightly auto-backup?" "y"; then
			run_as_user bash "$DOTFILES_DIR/setup-auto-backup.sh" 2>&1 | tee -a "$LOG_FILE"
			print_success "Cronjob installed (runs daily at 2 AM)"
		else
			print_info "Skipped auto-backup setup"
		fi
	else
		print_error "setup-auto-backup.sh not found"
	fi
}

print_next_steps() {
	cat <<EOF

════════════════════════════════════════════════════════════

Setup complete! Next steps:

  1. Edit your local configs:
     • nvim ~/.gitconfig.local (add your name and email)
     • nvim ~/.zshrc.local (add work-specific aliases)

  2. Add your tokens:
     • echo "token" > ~/.tokens/gitlab_token
     • echo "token" > ~/.tokens/coderabbit
     • echo "token" > ~/.tokens/linear
     • chmod 600 ~/.tokens/*

  3. Install tmux plugins:
     • tmux
     • Press Ctrl-s + I (prefix + I)

  4. Launch neovim:
     • nvim (plugins will auto-install)

  5. Reload your shell:
     • exec zsh

Full log: $LOG_FILE
EOF
	log "Setup completed successfully"
}

main() {
	# Initialize log
	echo "=== Dotfiles Setup $(date) ===" >"$LOG_FILE"

	print_banner
	check_and_install_dependencies
	setup_tokens_dir
	setup_templates
	install_oh_my_zsh
	install_theme
	backup_existing_configs
	run_stow
	install_tpm
	setup_auto_backup
	print_next_steps
}

main "$@"
