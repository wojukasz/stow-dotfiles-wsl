# Dotfiles for WSL Arch Linux

Modern, modular dotfiles optimized for SRE/DevOps work with AWS, Kubernetes, and Terraform.

## 🚀 Quick Start

```bash
# 1. Extract
tar -xzf dotfiles.tar.gz
cd dotfiles

# 2. IMPORTANT: Update git config with your details
nvim git/.gitconfig  # Change email, name, and GPG key

# 3. Run setup
chmod +x setup.sh
./setup.sh

# 4. Restart terminal
exec zsh

# 5. Install tmux plugins
tmux
# Press: Ctrl-a + I

# 6. Configure AWS
aws configure sso --profile your-profile
```

📖 **Read [INSTALLATION.md](INSTALLATION.md) for detailed instructions**

## 📚 Documentation

- **[INSTALLATION.md](INSTALLATION.md)** - Complete installation guide
- **[CUSTOMIZATION.md](CUSTOMIZATION.md)** - How to customize everything
- **[QUICK-REFERENCE.md](QUICK-REFERENCE.md)** - Command cheat sheet
- **[README.md](README.md)** - Feature documentation (in zsh/)

## ✨ Features

- 🐚 **Zsh** with modular configuration
- ⚡ **Starship** prompt - fast and beautiful
- 📦 **70+ Tools** - Modern CLI tools pre-configured
- ☁️  **AWS** - Comprehensive AWS CLI helpers and functions
- ☸️  **Kubernetes** - kubectl, k9s, helm with aliases
- 🏗️  **Terraform** - Complete workflow aliases
- 🐳 **Docker** - Container management
- 🔧 **asdf** - Version manager for all languages
- 📝 **Neovim** - Modern text editor
- 🖥️  **Tmux** - Terminal multiplexer with plugins

## 📁 Structure

```
dotfiles/
├── setup.sh                   # Provisioning script ⭐
├── INSTALLATION.md            # Installation guide
├── CUSTOMIZATION.md           # Customization guide
├── QUICK-REFERENCE.md         # Command cheat sheet
├── README.md                  # This file
├── .gitignore                 # Git ignore rules
├── zsh/                       # Zsh configuration
│   ├── .zshrc
│   └── .config/zshrc.d/      # Modular config files
│       ├── 00-init.zsh        # Early init (locale, asdf)
│       ├── 10-environment.zsh # Environment & PATH
│       ├── 20-settings.zsh    # Zsh settings
│       ├── 30-plugins.zsh     # Plugins (zinit)
│       ├── 40-completion.zsh  # Completion config
│       ├── 50-aliases.zsh     # Aliases
│       ├── 60-functions.zsh   # Shell functions
│       ├── 70-aws.zsh         # AWS configuration
│       └── 99-final.zsh       # SSH agent, tmux
├── git/                       # Git configuration
│   ├── .gitconfig
│   └── .gittemplate
├── tmux/                      # Tmux configuration
│   └── .tmux.conf
└── starship/                  # Prompt configuration
    └── .config/
        └── starship.toml
```

## 🛠️ What Gets Installed

### Core Tools
- zsh, tmux, neovim, git, stow

### Modern CLI
- exa (better ls), bat (better cat), fd (better find)
- ripgrep (better grep), fzf (fuzzy finder)
- zoxide (smarter cd), mcfly (better history)

### AWS & Cloud
- aws-cli-v2, aws-vault, aws-session-manager-plugin
- bash-my-aws (200+ AWS helper functions)

### Kubernetes
- kubectl, kubectx/kubens, k9s, helm

### Terraform
- terraform, terraform-docs, tflint

### Version Management
- asdf with plugins: nodejs, python, golang, direnv

### Containers
- docker, docker-compose

## 🎯 Key Features

### AWS Helpers

```bash
awswhoami              # Show current identity
awsrole 123456789012   # Assume OrgDeploy role
ec2ssh my-instance     # SSH via Session Manager
ssmget /my/parameter   # Get SSM parameter
cwlogs /aws/lambda/fn  # Tail CloudWatch logs
```

### Kubernetes Shortcuts

```bash
k                      # kubectl
kx                     # kubectx (switch context)
kn                     # kubens (switch namespace)
kgp                    # kubectl get pods
kl -f pod-name         # Follow pod logs
```

### Smart Navigation

```bash
z project              # Jump to project directory
..                     # cd ..
...                    # cd ../..
cdg                    # cd ~/git
```

### Modern Tools

```bash
ll                     # exa -l (better ls)
cat file               # bat (syntax highlighting)
Ctrl-R                 # McFly history search
**<TAB>                # FZF fuzzy completion
```

## ⚙️ Customization

### Quick Edits

```bash
zshconfig              # Edit main .zshrc
zshenv                 # Edit environment variables
zshalias               # Edit aliases
nvim ~/.config/zshrc.d/70-aws.zsh  # Edit AWS config
```

### Machine-Specific Config

Create `~/.zshrc.local`:

```bash
# Not tracked in git
export MY_VAR="value"
alias myalias="command"
```

### Add New Module

```bash
# Create numbered file in ~/.config/zshrc.d/
nvim ~/.config/zshrc.d/75-company.zsh
```

See [CUSTOMIZATION.md](CUSTOMIZATION.md) for complete guide.

## 🔄 Updating

```bash
# Update plugins
zinit update --all

# Update asdf plugins
asdf plugin update --all

# Update system
paru -Syu

# Update dotfiles
cd ~/dotfiles
git pull
stow -R */
```

## 🐛 Troubleshooting

### Locale Issues
```bash
sudo locale-gen
```

### Slow Startup
```bash
time zsh -i -c exit
rm ~/.cache/zsh/zcompdump*
zinit update --all
```

### Completion Not Working
```bash
rm ~/.cache/zsh/zcompdump*
compinit
exec zsh
```

See [INSTALLATION.md](INSTALLATION.md) for more troubleshooting.

## 📖 Documentation Overview

1. **Start here** - This README
2. **Install** - [INSTALLATION.md](INSTALLATION.md)
3. **Customize** - [CUSTOMIZATION.md](CUSTOMIZATION.md)
4. **Daily use** - [QUICK-REFERENCE.md](QUICK-REFERENCE.md)
5. **Features** - [README.md](README.md) in zsh/

## 💡 Pro Tips

1. Press `Ctrl-R` for AI-powered history search
2. Use `z` instead of `cd` for smart directory jumping
3. Type `**<TAB>` for FZF fuzzy file completion
4. Use `ll` instead of `ls -la` for better file listing
5. Check `QUICK-REFERENCE.md` for all commands

## 🎓 Learning Resources

- [zinit](https://github.com/zdharma-continuum/zinit) - Plugin manager
- [starship](https://starship.rs/) - Prompt
- [bash-my-aws](https://bash-my-aws.org/) - AWS helpers
- [asdf](https://asdf-vm.com/) - Version manager
- [tmux](https://github.com/tmux/tmux/wiki) - Terminal multiplexer

## ⚠️ Important Notes

### Before First Use

1. **Update git config** - Change name, email, GPG key
2. **Update AWS region** - Default is eu-west-2
3. **Add SSH keys** - Expected at ~/.ssh/gitkey

### Security

- `.gitignore` excludes sensitive files
- Use `~/.zshrc.local` for secrets (not tracked)
- Use `~/.secret_envvars` for sensitive environment variables

## 🤝 Contributing

This is your personal dotfiles repository. To share with team:

1. Fork this repo
2. Make your changes
3. Update documentation
4. Test thoroughly
5. Share with team

## 📜 License

MIT License - Use and modify as needed

## 🆘 Getting Help

1. Check relevant config file in `~/.config/zshrc.d/`
2. Read the documentation files
3. Check tool-specific docs
4. Search for examples online

---

**Ready to get started?** Read [INSTALLATION.md](INSTALLATION.md) next!

For daily commands, keep [QUICK-REFERENCE.md](QUICK-REFERENCE.md) handy.

To customize, see [CUSTOMIZATION.md](CUSTOMIZATION.md).

**Enjoy your new shell environment!** 🚀
