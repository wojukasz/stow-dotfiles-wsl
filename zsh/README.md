# Modern ZSH Configuration for WSL Arch Linux

A clean, modular, and well-organised zsh configuration optimised for SRE/DevOps work with AWS, Kubernetes, and Terraform.

## Features

- 🚀 **Fast startup** with lazy-loaded plugins
- 📦 **Modular design** - easy to customise and extend
- ☁️ **AWS-focused** - comprehensive AWS CLI helpers and functions
- 🐳 **Container-ready** - Docker and Kubernetes tools integrated
- 🎨 **Modern tools** - exa, bat, fd, ripgrep, fzf, and more
- 🔧 **SRE toolkit** - Terraform, kubectl, monitoring tools
- 📝 **Clean codebase** - no cruft, well-commented

## Structure

```
~/.zshrc                          # Main config (loads all modules)
~/.config/zshrc.d/
├── 00-init.zsh                   # Early init (locale, asdf, XDG)
├── 10-environment.zsh            # Environment variables & PATH
├── 20-settings.zsh               # Zsh behaviour settings
├── 30-plugins.zsh                # Plugin management (zinit)
├── 40-completion.zsh             # Completion configuration
├── 50-aliases.zsh                # Command aliases
├── 60-functions.zsh              # Useful shell functions
├── 70-aws.zsh                    # AWS-specific config
└── 99-final.zsh                  # Final init (SSH agent, tmux)
```

## Quick Start

### Installation

1. **Run the provisioning script:**
   ```bash
   cd ~/dotfiles
   chmod +x setup-wsl-complete.sh
   ./setup-wsl-complete.sh
   ```

2. **Restart your terminal or run:**
   ```bash
   exec zsh
   ```

3. **Configure AWS:**
   ```bash
   aws configure sso --profile your-profile
   aws sso login --profile your-profile
   ```

### Manual Installation

If you prefer manual installation:

```bash
# Clone your dotfiles
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Use stow to symlink configs
stow -t $HOME zsh

# Restart shell
exec zsh
```

## Key Tools & Plugins

### Plugin Manager
- **zinit** - Fast, flexible plugin manager

### Prompt
- **starship** - Fast, customizable prompt

### Plugins
- `fast-syntax-highlighting` - Syntax highlighting
- `zsh-autosuggestions` - Fish-like autosuggestions
- `zsh-completions` - Additional completions
- `fzf-tab` - Replace zsh completion with fzf
- `asdf.plugin.zsh` - ASDF version manager integration
- `zsh-terraform` - Terraform helpers

### CLI Tools
- `exa` - Modern ls replacement
- `bat` - Cat with syntax highlighting
- `fd` - Fast find alternative
- `ripgrep` - Fast grep alternative
- `fzf` - Fuzzy finder
- `zoxide` - Smarter cd command
- `mcfly` - Better history search
- `direnv` - Per-directory environment variables

### AWS Tools
- `aws-cli-v2` - AWS command line interface
- `aws-vault` - Secure AWS credential storage
- `bash-my-aws` - AWS helper scripts
- `aws-session-manager-plugin` - SSM session manager

### Kubernetes Tools
- `kubectl` - Kubernetes CLI
- `kubectx/kubens` - Context and namespace switcher
- `k9s` - Terminal UI for Kubernetes
- `helm` - Package manager for Kubernetes

### Terraform
- `terraform` - Infrastructure as code
- `terraform-docs` - Documentation generator
- `tflint` - Linter

## Configuration

### Environment Variables

Edit `~/.config/zshrc.d/10-environment.zsh`:

```bash
export AWS_REGION="eu-west-2"
export AWS_DEFAULT_REGION="eu-west-2"
export EDITOR='nvim'
```

### Aliases

Add custom aliases to `~/.config/zshrc.d/50-aliases.zsh`

### Functions

Add custom functions to `~/.config/zshrc.d/60-functions.zsh`

### AWS Configuration

AWS-specific configs in `~/.config/zshrc.d/70-aws.zsh`

### Local Overrides

Create `~/.zshrc.local` for machine-specific configuration that won't be committed to version control.

## Usage Examples

### AWS Functions

```bash
# Assume a role
assume arn:aws:iam::123456789012:role/MyRole my-session

# Assume role by account ID (uses OrgDeploy role)
awsrole 123456789012

# Show current AWS identity
awswhoami

# Clear AWS credentials
awsclear

# Switch region
awsregion eu-west-1

# Get EC2 instance ID by name
ec2id my-instance-name

# SSH to EC2 via Session Manager
ec2ssh my-instance-name

# Get SSM parameter
ssmget /my/parameter/path

# Tail CloudWatch logs
cwlogs /aws/lambda/my-function
```

### General Functions

```bash
# Create directory and cd into it
mkcd my-new-directory

# Extract any archive
extract archive.tar.gz

# Start/attach to tmux session
tm session-name

# Quick note taking
note "Meeting with team about project X"

# Git commit all changes
gcm "Fix bug in authentication"

# Docker cleanup
dcleanup

# Show disk usage
diskspace

# Simple HTTP server
serve 8080
```

### Navigation

```bash
# Quick directory access
cdg              # cd ~/git
cdd              # cd ~/Downloads

# Directory hashes
cd ~git          # cd ~/git
cd ~docs         # cd ~/Documents

# Zoxide smart jump
z project        # Jump to project directory
```

## Customisation

### Adding New Modules

Create a new file in `~/.config/zshrc.d/` with appropriate number prefix:

```bash
# Example: 75-datadog.zsh
touch ~/.config/zshrc.d/75-datadog.zsh
```

Files are sourced in numerical order, so:
- `00-19`: Early initialization
- `20-29`: Settings and configuration
- `30-49`: Plugins and completions
- `50-69`: Aliases and functions
- `70-89`: Tool-specific configurations
- `90-99`: Final initialization

### Disabling Modules

Simply rename or remove the `.zsh` extension:

```bash
mv ~/.config/zshrc.d/99-final.zsh ~/.config/zshrc.d/99-final.zsh.disabled
```

### Enabling Tmux Auto-start

Edit `~/.config/zshrc.d/99-final.zsh` and uncomment:

```bash
# start_tmux    # <- Uncomment this line
```

## Performance

Check startup time:

```bash
time zsh -i -c exit
```

Profile startup (already in .zshrc, uncommented):

```bash
# Uncomment these lines in ~/.zshrc:
# zmodload zsh/zprof
# ... (at the end)
# zprof
```

## Troubleshooting

### Slow startup

1. Check which plugins are slow:
   ```bash
   # Uncomment zprof lines in ~/.zshrc
   ```

2. Defer loading of heavy plugins

### Completion not working

```bash
# Rebuild completion cache
rm ~/.cache/zsh/zcompdump*
compinit
```

### Locale issues

```bash
# Run the locale fix script
./fix-locale.sh
```

## Updates

Update plugins:

```bash
zinit update --all
```

Update asdf plugins:

```bash
asdf plugin update --all
```

Update system packages:

```bash
paru -Syu
```

## Contributing

Feel free to customise and extend this configuration for your needs!

## License

MIT License - Feel free to use and modify

## Resources

- [zinit](https://github.com/zdharma-continuum/zinit)
- [starship](https://starship.rs/)
- [bash-my-aws](https://bash-my-aws.org/)
- [asdf](https://asdf-vm.com/)
- [Modern Unix Tools](https://github.com/ibraheemdev/modern-unix)
