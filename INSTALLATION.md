# Installation Guide

## Quick Start

### 1. Extract the Archive

```bash
cd ~
tar -xzf dotfiles.tar.gz
cd dotfiles
```

### 2. Customize Your Git Configuration

**IMPORTANT**: Before running the setup, update your personal information:

```bash
# Edit git/.gitconfig and update these fields:
nvim git/.gitconfig

# Change:
# [user]
#     email = YOUR_EMAIL@example.com
#     name = Your Name
#     signingkey = YOUR_GPG_KEY  # Optional, comment out if not using GPG signing
```

If you don't use GPG signing, comment out or remove:
```
[commit]
    gpgsign = true
```

### 3. Run the Setup Script

```bash
chmod +x setup.sh
./setup.sh
```

This script will:
- ✅ Fix locale issues (en_GB.UTF-8)
- ✅ Install paru (AUR helper)
- ✅ Install all required packages (70+ tools)
- ✅ Configure asdf with DevOps plugins
- ✅ Set up AWS CLI, kubectl, terraform tools
- ✅ Install bash-my-aws for AWS helpers
- ✅ Set up tmux plugin manager
- ✅ Apply all stow configurations
- ✅ Set zsh as default shell

### 4. Restart Your Terminal

```bash
# Either close and reopen your terminal, or:
exec zsh
```

### 5. Install Tmux Plugins

```bash
tmux
# Press: Ctrl-a + I (capital I)
# Wait for plugins to install
```

### 6. Configure AWS

```bash
aws configure sso --profile your-profile-name
aws sso login --profile your-profile-name
```

### 7. Add SSH Keys

```bash
# Generate if needed
ssh-keygen -t ed25519 -C "your_email@example.com"

# If you have an existing key named differently, create a symlink:
ln -s ~/.ssh/your-key ~/.ssh/gitkey
```

## Manual Installation (Without Setup Script)

If you prefer to install manually:

### 1. Install Prerequisites

```bash
# Install base tools
sudo pacman -S --needed base-devel git stow

# Install paru
cd /tmp
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

### 2. Use Stow to Deploy Configs

```bash
cd ~/dotfiles

# Deploy individual packages
stow -t $HOME zsh
stow -t $HOME git  
stow -t $HOME tmux
stow -t $HOME starship

# Or deploy all at once
stow -t $HOME */
```

### 3. Install Packages

```bash
paru -S zsh tmux neovim starship exa bat fd ripgrep fzf jq \
        aws-cli-v2 kubectl docker terraform git-delta \
        zoxide nnn tree htop btop ncdu ttf-hack-nerd
```

### 4. Install asdf

```bash
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1
source ~/.asdf/asdf.sh
```

### 5. Install bash-my-aws

```bash
git clone https://github.com/bash-my-aws/bash-my-aws.git ~/.bash-my-aws
```

### 6. Set Zsh as Default Shell

```bash
chsh -s $(which zsh)
```

## What Gets Installed

### Package Overview

- **Shell**: zsh with zinit plugin manager
- **Prompt**: starship (fast, customizable)
- **Terminal**: tmux with TPM
- **Editor**: neovim
- **Modern CLI**: exa, bat, fd, ripgrep, fzf, zoxide, mcfly
- **AWS Tools**: aws-cli-v2, aws-vault, bash-my-aws, session-manager-plugin
- **Kubernetes**: kubectl, kubectx, k9s, helm
- **Terraform**: terraform, terraform-docs, tflint
- **Containers**: docker, docker-compose
- **Version Manager**: asdf with plugins (nodejs, python, golang, etc.)

## Directory Structure

After installation, your home directory will have:

```
~/
├── .zshrc                          # Main zsh config (symlink)
├── .config/
│   ├── zshrc.d/                    # Modular zsh configs (symlinks)
│   │   ├── 00-init.zsh
│   │   ├── 10-environment.zsh
│   │   ├── 20-settings.zsh
│   │   ├── 30-plugins.zsh
│   │   ├── 40-completion.zsh
│   │   ├── 50-aliases.zsh
│   │   ├── 60-functions.zsh
│   │   ├── 70-aws.zsh
│   │   └── 99-final.zsh
│   └── starship.toml               # Prompt config (symlink)
├── .gitconfig                      # Git config (symlink)
├── .gittemplate                    # Commit template (symlink)
├── .tmux.conf                      # Tmux config (symlink)
├── .asdf/                          # Version manager
├── .bash-my-aws/                   # AWS helper scripts
└── .tmux/plugins/tpm/              # Tmux plugin manager
```

## Customization

### Machine-Specific Settings

Create `~/.zshrc.local` for machine-specific configuration that won't be committed:

```bash
# Example ~/.zshrc.local
export COMPANY_VPN="vpn.company.com"
alias work="cd ~/company/projects"
export MY_CUSTOM_VAR="value"
```

### Adding New Modules

Create a new file in `~/.config/zshrc.d/` with an appropriate number prefix:

```bash
# Example: Company-specific configuration
nvim ~/.config/zshrc.d/75-company.zsh
```

Files are sourced in numerical order:
- `00-19`: Early initialization
- `20-29`: Settings and configuration
- `30-49`: Plugins and completions
- `50-69`: Aliases and functions
- `70-89`: Tool-specific configurations
- `90-99`: Final initialization

### Disabling Modules

Rename the file to disable it:

```bash
mv ~/.config/zshrc.d/70-aws.zsh ~/.config/zshrc.d/70-aws.zsh.disabled
```

### Quick Config Edits

```bash
zshconfig    # Edit main .zshrc
zshenv       # Edit environment variables
zshalias     # Edit aliases
nvim ~/.config/zshrc.d/70-aws.zsh  # Edit AWS config
```

## Updating

### Update Plugins

```bash
zinit update --all
```

### Update asdf Plugins

```bash
asdf plugin update --all
```

### Update System Packages

```bash
paru -Syu
```

### Update Dotfiles from Git

```bash
cd ~/dotfiles
git pull
stow -R */  # Restow all packages
```

## Troubleshooting

### Locale Issues

If you see locale warnings:
```bash
sudo locale-gen
```

### Slow Startup

Check startup time:
```bash
time zsh -i -c exit
```

Clear completion cache:
```bash
rm ~/.cache/zsh/zcompdump*
exec zsh
```

### Completion Not Working

```bash
rm ~/.cache/zsh/zcompdump*
compinit
exec zsh
```

### Stow Conflicts

If stow complains about existing files:
```bash
# Backup existing configs
mkdir ~/config-backup
mv ~/.zshrc ~/config-backup/
mv ~/.config/zshrc.d ~/config-backup/
# etc.

# Then restow
cd ~/dotfiles
stow -t $HOME zsh
```

### AWS Commands Not Working

```bash
# Check configuration
aws configure list

# Re-login
aws sso login --profile your-profile

# Verify bash-my-aws is installed
ls ~/.bash-my-aws
```

### Tmux Plugins Not Installing

```bash
# Remove and reinstall TPM
rm -rf ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Start tmux and install
tmux
# Press: Ctrl-a + I
```

## Uninstallation

To remove these configurations:

```bash
cd ~/dotfiles

# Unstow all packages
stow -D */

# Remove installed directories
rm -rf ~/.asdf
rm -rf ~/.bash-my-aws
rm -rf ~/.tmux/plugins
rm -rf ~/.local/share/zinit

# Remove the dotfiles directory (if desired)
rm -rf ~/dotfiles
```

## Next Steps

1. ✅ Read QUICK-REFERENCE.md for command cheat sheet
2. ✅ Read README.md for detailed feature documentation  
3. ✅ Configure AWS profiles
4. ✅ Set up SSH keys
5. ✅ Customize to your preferences
6. ✅ Commit your changes to Git

## Getting Help

- Check the README.md for feature documentation
- Check QUICK-REFERENCE.md for command reference
- Read comments in `~/.config/zshrc.d/*.zsh` files
- Check tool-specific documentation

## Tips

1. **Use `z` instead of `cd`** - Zoxide smart directory jumping
2. **Press `Ctrl-R`** - McFly history search
3. **Use `**<TAB>`** - FZF fuzzy completion
4. **Type `alias`** - See all available aliases
5. **Type `functions`** - See all available functions
6. **Check QUICK-REFERENCE.md** - Keep it handy!

---

**Enjoy your new shell environment!** 🚀

For issues or questions about specific features, check the relevant config file in `~/.config/zshrc.d/`.
