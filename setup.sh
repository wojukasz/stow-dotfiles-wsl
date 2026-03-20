#!/bin/bash
set -euo pipefail

# Always run from the script's directory so stow packages are found
cd "$(dirname "$(realpath "$0")")"

echo "==> Starting WSL provisioning script for SRE environment..."

# Ensure we're running on Arch Linux
if [ ! -f /etc/arch-release ]; then
  echo "Error: This script is designed for Arch Linux only"
  exit 1
fi

# Fix locale issues (common on WSL)
echo "==> Configuring locales (en_GB.UTF-8)..."
if ! locale -a | grep -q "en_GB.utf8"; then
  echo "    - Enabling en_GB.UTF-8 and en_US.UTF-8 locales..."
  sudo sed -i 's/^#en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen
  sudo sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
  echo "    - Generating locales..."
  sudo locale-gen
fi

if [ ! -f /etc/locale.conf ]; then
  echo "    - Setting system-wide locale to en_GB.UTF-8..."
  echo "LANG=en_GB.UTF-8" | sudo tee /etc/locale.conf > /dev/null
  echo "LC_ALL=en_GB.UTF-8" | sudo tee -a /etc/locale.conf > /dev/null
fi

# Export for current session
export LANG=en_GB.UTF-8
export LC_ALL=en_GB.UTF-8

# Install base-devel if not already installed (required for building AUR packages)
if ! pacman -Qi base-devel &>/dev/null; then
  echo "==> Installing base-devel..."
  sudo pacman -S --noconfirm base-devel
fi

# Install git if not already installed (required for paru installation)
if ! pacman -Qi git &>/dev/null; then
  echo "==> Installing git..."
  sudo pacman -S --noconfirm git
fi

# Install PARU if not already installed
if ! command -v paru &>/dev/null; then
  echo "==> Installing paru..."
  PARU_DIR=$(mktemp -d)
  cd "$PARU_DIR"
  curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/paru.tar.gz | tar xzf -
  cd paru
  makepkg -si --noconfirm
  cd ~
  rm -rf "$PARU_DIR"
  echo "==> Paru installed successfully"
else
  echo "==> Paru is already installed"
fi

# Install STOW
if ! pacman -Qi stow &>/dev/null; then
  echo "==> Installing stow..."
  paru -S --noconfirm stow
else
  echo "==> Stow is already installed"
fi

# Install latest asdf using git
if [ ! -d ~/.asdf ]; then
  echo "==> Installing asdf..."
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1
fi

# Source asdf
if [ -f ~/.asdf/asdf.sh ]; then
  source ~/.asdf/asdf.sh
fi

# Define packages to install
PACKAGES=(
  # Core utilities
  base-devel
  curl
  wget
  unzip
  
  # Modern CLI tools
  exa           # Modern ls replacement
  fd            # Fast find alternative
  ripgrep       # Fast grep alternative
  bat           # Cat with syntax highlighting
  fzf           # Fuzzy finder
  jq            # JSON processor
  go-yq         # YAML processor
  
  # Development tools
  neovim        # Text editor
  git
  tig           # Text-mode interface for git
  git-delta     # Better git diff viewer
  lazygit       # Terminal UI for git
  
  # Terminal & Shell
  zsh           # Shell
  tmux          # Terminal multiplexer
  starship      # Shell prompt
  zoxide        # Smarter cd command
  
  # File management
  nnn           # File manager
  tree          # Directory tree viewer
  
  # System tools
  htop          # Process viewer
  btop          # Better top
  ncdu          # Disk usage analyzer
  
  # Fonts
  ttf-hack-nerd # Nerd font for terminal
  
  # Container tools
  docker
  docker-compose
  
  # Security & passwords
  pwgen         # Password generator
  
  # AWS & Cloud tools
  aws-cli-v2    # AWS CLI
  aws-vault     # Secure AWS credential storage
  aws-session-manager-plugin
  
  # Kubernetes tools
  kubectl
  kubectx
  k9s           # Kubernetes TUI
  helm
  
  # Terraform
  terraform
  terraform-docs
  tflint
  
  # Other SRE tools
  xclip         # Clipboard support
  stow          # Dotfile manager
)

# Check which packages need to be installed
declare -a INSTALL_PACKAGES
INSTALL_PACKAGES=()

echo "==> Checking for packages to install..."
for PACKAGE in "${PACKAGES[@]}"; do
  # Skip commented packages
  [[ "$PACKAGE" =~ ^# ]] && continue
  
  if ! pacman -Qi "$PACKAGE" &>/dev/null; then
    INSTALL_PACKAGES+=("$PACKAGE")
    echo "    - $PACKAGE (needs installation)"
  fi
done

# Update package database before installing
if [ "${#INSTALL_PACKAGES[@]}" -gt 0 ]; then
  echo "==> Updating package database..."
  sudo pacman -Sy
  
  echo "==> Installing ${#INSTALL_PACKAGES[@]} package(s)..."
  # Try to install, but continue even if some fail
  paru -S --noconfirm "${INSTALL_PACKAGES[@]}" || {
    echo ""
    echo "⚠️  Warning: Some packages failed to install."
    echo "    This is usually due to:"
    echo "    1. Package version mismatch (404 errors)"
    echo "    2. Network issues"
    echo ""
    echo "    The script will continue. You can install missing packages manually later."
    echo "    Or re-run this script after: sudo pacman -Syy"
    echo ""
    read -p "Press Enter to continue..."
  }
else
  echo "==> All packages are already installed"
fi

# Setup ASDF plugins
echo "==> Setting up ASDF plugins..."

# Get list of installed plugins
ASDF_PLUGINS_INSTALLED=($(asdf plugin list 2>/dev/null || echo ""))

declare -a ASDF_PLUGINS_TO_INSTALL
ASDF_PLUGINS_TO_INSTALL=(
  direnv          # Environment variable management
  nodejs          # Node.js for various tools
  python          # Python
  golang          # Go
  awscli          # AWS CLI (if not using system package)
  terraform       # Terraform
  terraform-docs  # Terraform documentation
  terraform-ls    # Terraform language server
  tflint          # Terraform linter
  kubectl         # Kubernetes CLI
  helm            # Kubernetes package manager
)

# Install missing ASDF plugins
for PLUGIN in "${ASDF_PLUGINS_TO_INSTALL[@]}"; do
  # Skip commented plugins
  [[ "$PLUGIN" =~ ^# ]] && continue
  
  if ! echo "${ASDF_PLUGINS_INSTALLED[@]}" | grep -qw "$PLUGIN"; then
    echo "    - Installing asdf plugin: $PLUGIN"
    asdf plugin add "$PLUGIN" || echo "      Warning: Failed to add $PLUGIN plugin"
  else
    echo "    - Plugin already installed: $PLUGIN"
  fi
done

# Update plugin list after installations
ASDF_PLUGINS_INSTALLED=($(asdf plugin list 2>/dev/null || echo ""))

# Install latest versions of ASDF-managed tools
echo "==> Installing latest versions of ASDF tools..."
for plugin in "${ASDF_PLUGINS_INSTALLED[@]}"; do
  LATEST_VERSION=$(asdf latest "$plugin" 2>/dev/null || echo "")
  
  if [ -n "$LATEST_VERSION" ]; then
    CURRENT_VERSION=$(asdf current "$plugin" 2>/dev/null | awk '{print $2}' || echo "")
    
    if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
      echo "    - Installing $plugin $LATEST_VERSION..."
      asdf install "$plugin" "$LATEST_VERSION"
      asdf global "$plugin" "$LATEST_VERSION"
    else
      echo "    - $plugin $CURRENT_VERSION is already up to date"
    fi
  fi
done

# Install bash-my-aws for AWS helpers
echo "==> Setting up bash-my-aws..."
if [ ! -d ~/.bash-my-aws ]; then
  git clone https://github.com/bash-my-aws/bash-my-aws.git ~/.bash-my-aws
  echo "    - bash-my-aws installed"
else
  echo "    - bash-my-aws already installed"
  git -C ~/.bash-my-aws pull
fi

# Install Datadog CLI (optional - uncomment if needed)
# echo "==> Installing Datadog CLI..."
# if ! command -v datadog-ci &>/dev/null; then
#   npm install -g @datadog/datadog-ci
# fi

# Ensure tmux plugin manager is installed
echo "==> Setting up tmux plugin manager..."
mkdir -p ~/.tmux/plugins
if [ ! -d ~/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  echo "    - Tmux plugin manager installed"
else
  echo "    - Tmux plugin manager already installed"
fi

# Setup LazyVim
echo "==> Setting up LazyVim..."
if [ ! -d ~/.config/nvim ]; then
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  rm -rf ~/.config/nvim/.git
  echo "    - LazyVim starter cloned (run 'nvim' to install plugins)"
else
  echo "    - ~/.config/nvim already exists, skipping"
fi

# Setup SSH agent systemd service for WSL
echo "==> Setting up SSH agent..."
mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/ssh-agent.service << 'EOF'
[Unit]
Description=SSH key agent

[Service]
Type=simple
Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
ExecStart=/usr/bin/ssh-agent -D -a $SSH_AUTH_SOCK

[Install]
WantedBy=default.target
EOF

# Don't start systemd services on WSL (they don't work the same way)
echo "    - SSH agent service file created (manual start required on WSL)"

# Backup existing configs (only if they exist and aren't symlinks)
echo "==> Backing up existing configurations..."
CONFIGS_TO_BACKUP=(
  "$HOME/.zshrc"
  "$HOME/.config/zshrc.d"
  "$HOME/.config/starship.toml"
  "$HOME/.tmux.conf"
  "$HOME/.gitconfig"
)

for config in "${CONFIGS_TO_BACKUP[@]}"; do
  if [ -e "$config" ] && [ ! -L "$config" ]; then
    echo "    - Backing up: $config"
    mv "$config" "$config.bak.$(date +%Y%m%d_%H%M%S)"
  fi
done

# Apply stow configurations
echo "==> Applying stow configurations..."

# Check if we're in the correct directory (should contain stow packages)
if [ ! -d "zsh" ] && [ ! -d "git" ] && [ ! -d "starship" ]; then
  echo "Warning: Stow package directories not found in current directory"
  echo "Please run this script from your dotfiles directory"
  echo "Expected directories: curl/, git/, starship/, tmux/, zsh/"
  exit 1
fi

# Stow each configuration
STOW_PACKAGES=(curl git lazygit starship tmux zsh)

for package in "${STOW_PACKAGES[@]}"; do
  if [ -d "$package" ]; then
    echo "    - Stowing: $package"
    stow -t "$HOME" "$package"
  else
    echo "    - Warning: Package directory not found: $package"
  fi
done

# Set zsh as default shell
if [ "$SHELL" != "/usr/bin/zsh" ] && [ "$SHELL" != "/bin/zsh" ]; then
  echo "==> Setting zsh as default shell..."
  chsh -s /usr/bin/zsh
  echo "    - Default shell changed to zsh (restart terminal to apply)"
fi

echo ""
echo "==> WSL provisioning complete! 🎉"
echo ""
echo "Next steps:"
echo "  1. Open a new terminal — zsh will launch and auto-install all plugins"
echo "     (zinit, starship, fzf-tab, autosuggestions, etc. install on first run)"
echo "  2. Run 'tmux' and press prefix + I to install tmux plugins"
echo "  3. Configure AWS CLI: aws configure sso"
echo "  4. Setup SSH keys in ~/.ssh/"
echo "  5. Run 'nvim' to trigger LazyVim plugin installation"
echo ""
echo "AWS Tools installed:"
echo "  - AWS CLI v2"
echo "  - aws-vault (secure credential storage)"
echo "  - bash-my-aws (AWS helper scripts)"
echo "  - Session Manager plugin"
echo ""
echo "Kubernetes tools installed:"
echo "  - kubectl"
echo "  - kubectx/kubens"
echo "  - k9s (terminal UI)"
echo "  - helm"
echo ""
