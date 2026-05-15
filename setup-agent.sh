#!/bin/bash
# Local dev / AI instance provisioning script for Arch Linux WSL2.
# Mirrors setup.sh structure but omits cloud-native tools (Terraform, AWS CLI,
# kubectl, helm, etc.). Intended for machines running Ollama + Hermes agent.
# After cloning this repo: chmod +x setup-local.sh && ./setup-local.sh
set -euo pipefail

cd "$(dirname "$(realpath "$0")")"

echo "==> Starting WSL provisioning script for local dev environment..."

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
  echo "LANG=en_GB.UTF-8" | sudo tee /etc/locale.conf >/dev/null
  echo "LC_ALL=en_GB.UTF-8" | sudo tee -a /etc/locale.conf >/dev/null
fi

export LANG=en_GB.UTF-8
export LC_ALL=en_GB.UTF-8

if ! pacman -Qi base-devel &>/dev/null; then
  echo "==> Installing base-devel..."
  sudo pacman -S --noconfirm base-devel
fi

if ! pacman -Qi git &>/dev/null; then
  echo "==> Installing git..."
  sudo pacman -S --noconfirm git
fi

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

if ! pacman -Qi stow &>/dev/null; then
  echo "==> Installing stow..."
  paru -S --noconfirm stow
else
  echo "==> Stow is already installed"
fi

if [ ! -d ~/.asdf ]; then
  echo "==> Installing asdf..."
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1
fi

if [ -f ~/.asdf/asdf.sh ]; then
  source ~/.asdf/asdf.sh
fi

PACKAGES=(
  # Core utilities
  base-devel
  curl
  wget
  unzip

  # Modern CLI tools
  exa
  fd
  ripgrep
  bat
  fzf
  jq
  go-yq
  zoxide

  # Development tools
  neovim
  git
  tig
  git-delta
  lazygit

  # Terminal & Shell
  zsh
  tmux
  starship

  # File management
  tree

  # System tools
  htop
  btop
  ncdu

  # Container tools
  docker
  docker-compose

  # Dotfile manager
  stow
)

declare -a INSTALL_PACKAGES
INSTALL_PACKAGES=()

echo "==> Checking for packages to install..."
for PACKAGE in "${PACKAGES[@]}"; do
  [[ "$PACKAGE" =~ ^# ]] && continue

  if ! pacman -Qi "$PACKAGE" &>/dev/null; then
    INSTALL_PACKAGES+=("$PACKAGE")
    echo "    - $PACKAGE (needs installation)"
  fi
done

if [ "${#INSTALL_PACKAGES[@]}" -gt 0 ]; then
  echo "==> Updating package database..."
  sudo pacman -Sy

  echo "==> Installing ${#INSTALL_PACKAGES[@]} package(s)..."
  paru -S --noconfirm "${INSTALL_PACKAGES[@]}" || {
    echo ""
    echo "Warning: Some packages failed to install."
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

echo "==> Setting up ASDF plugins..."

ASDF_PLUGINS_INSTALLED=($(asdf plugin list 2>/dev/null || echo ""))

declare -a ASDF_PLUGINS_TO_INSTALL
ASDF_PLUGINS_TO_INSTALL=(
  direnv
  golang
)

for PLUGIN in "${ASDF_PLUGINS_TO_INSTALL[@]}"; do
  [[ "$PLUGIN" =~ ^# ]] && continue

  if ! echo "${ASDF_PLUGINS_INSTALLED[@]}" | grep -qw "$PLUGIN"; then
    echo "    - Installing asdf plugin: $PLUGIN"
    asdf plugin add "$PLUGIN" || echo "      Warning: Failed to add $PLUGIN plugin"
  else
    echo "    - Plugin already installed: $PLUGIN"
  fi
done

ASDF_PLUGINS_INSTALLED=($(asdf plugin list 2>/dev/null || echo ""))

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

echo "==> Setting up tmux plugin manager..."
mkdir -p ~/.tmux/plugins
if [ ! -d ~/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  echo "    - Tmux plugin manager installed"
else
  echo "    - Tmux plugin manager already installed"
fi

echo "==> Setting up LazyVim..."
if [ ! -d ~/.config/nvim ]; then
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  rm -rf ~/.config/nvim/.git
  echo "    - LazyVim starter cloned (run 'nvim' to install plugins)"
else
  echo "    - ~/.config/nvim already exists, skipping"
fi

echo "==> Setting up SSH agent..."
mkdir -p ~/.config/systemd/user
cat >~/.config/systemd/user/ssh-agent.service <<'EOF'
[Unit]
Description=SSH key agent

[Service]
Type=simple
Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
ExecStart=/usr/bin/ssh-agent -D -a $SSH_AUTH_SOCK

[Install]
WantedBy=default.target
EOF
echo "    - SSH agent service file created (manual start required on WSL)"

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

echo "==> Applying stow configurations..."

if [ ! -d "zsh" ] && [ ! -d "git" ] && [ ! -d "starship" ]; then
  echo "Warning: Stow package directories not found in current directory"
  echo "Please run this script from your dotfiles directory"
  exit 1
fi

STOW_PACKAGES=(curl git lazygit starship tmux zsh)

for package in "${STOW_PACKAGES[@]}"; do
  if [ -d "$package" ]; then
    echo "    - Stowing: $package"
    stow -t "$HOME" "$package"
  else
    echo "    - Warning: Package directory not found: $package"
  fi
done

if [ "$SHELL" != "/usr/bin/zsh" ] && [ "$SHELL" != "/bin/zsh" ]; then
  echo "==> Setting zsh as default shell..."
  chsh -s /usr/bin/zsh
  echo "    - Default shell changed to zsh (restart terminal to apply)"
fi

echo ""
echo "==> Local dev provisioning complete!"
echo ""
echo "Next steps:"
echo "  1. Open a new terminal — zsh will launch and auto-install all plugins"
echo "     (zinit, starship, fzf-tab, autosuggestions, etc. install on first run)"
echo "  2. Run 'tmux' and press prefix + I to install tmux plugins"
echo "  3. Run 'nvim' to trigger LazyVim plugin installation"
echo "  4. Setup SSH keys in ~/.ssh/"
echo ""
echo "AI tooling (install separately when ready):"
echo "  - Ollama:  curl -fsSL https://ollama.com/install.sh | sh"
echo "  - Hermes:  https://hermes-agent.nousresearch.com/docs/getting-started/installation"
echo "             (git is the only prerequisite — the installer handles the rest)"
echo ""
