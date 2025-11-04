# Customization Guide

## Personal Information

### Git Configuration

**MUST DO BEFORE FIRST COMMIT**:

Edit `git/.gitconfig`:

```bash
nvim git/.gitconfig

# Update these fields:
[user]
    email = your.email@example.com
    name = Your Name
    signingkey = YOUR_GPG_KEY_IF_USING_GPG
```

If you don't use GPG signing, comment out:
```
[commit]
    gpgsign = true
```

### SSH Configuration

The zsh config expects an SSH key at `~/.ssh/gitkey`. Either:

1. **Create a symlink** to your existing key:
   ```bash
   ln -s ~/.ssh/id_ed25519 ~/.ssh/gitkey
   ```

2. **Update the path** in `zsh/.config/zshrc.d/99-final.zsh`:
   ```bash
   # Change this line:
   if [ -f ~/.ssh/gitkey ]; then
     ssh-add ~/.ssh/gitkey 2>/dev/null
   fi
   
   # To:
   if [ -f ~/.ssh/YOUR_KEY_NAME ]; then
     ssh-add ~/.ssh/YOUR_KEY_NAME 2>/dev/null
   fi
   ```

## Environment Variables

### AWS Region

Edit `zsh/.config/zshrc.d/10-environment.zsh`:

```bash
# Change from:
export AWS_REGION="eu-west-2"
export AWS_DEFAULT_REGION="eu-west-2"

# To your preferred region:
export AWS_REGION="us-east-1"
export AWS_DEFAULT_REGION="us-east-1"
```

### Editor

If you don't use neovim:

```bash
# In zsh/.config/zshrc.d/10-environment.zsh
export EDITOR='vim'  # or 'code', 'emacs', etc.
export VISUAL='vim'
```

### Custom PATH

Add to `zsh/.config/zshrc.d/10-environment.zsh`:

```bash
# Custom paths
export PATH="$HOME/my-custom-bin:$PATH"
export PATH="/opt/my-software/bin:$PATH"
```

## Aliases

### Company-Specific Aliases

Create `zsh/.config/zshrc.d/51-company-aliases.zsh`:

```bash
# Company-specific aliases
alias vpn='sudo openvpn /etc/openvpn/company.ovpn'
alias ssh-bastion='ssh user@bastion.company.com'
alias deploy-prod='cd ~/company/infra && terraform apply'

# Project shortcuts
alias proj-api='cd ~/company/api && code .'
alias proj-web='cd ~/company/web && npm start'
```

### Personal Aliases

Add to `~/.zshrc.local` (not tracked in git):

```bash
# Personal machine-specific aliases
alias home='cd ~/personal/projects'
alias backup='rsync -avz ~ /mnt/backup/'
```

## Functions

### Custom Functions

Create `zsh/.config/zshrc.d/61-custom-functions.zsh`:

```bash
# Deploy to environment
deploy() {
  if [ $# -eq 0 ]; then
    echo "Usage: deploy <env>"
    return 1
  fi
  
  local env="$1"
  echo "Deploying to $env..."
  cd ~/company/infra
  terraform workspace select "$env"
  terraform apply -auto-approve
}

# Connect to database
dbconnect() {
  local env="${1:-dev}"
  local host=$(aws ssm get-parameter --name "/db/$env/host" --query 'Parameter.Value' --output text)
  psql -h "$host" -U admin -d mydb
}
```

## AWS Configuration

### Multiple AWS Profiles

Add to `zsh/.config/zshrc.d/70-aws.zsh` or create `71-aws-profiles.zsh`:

```bash
# Company AWS profiles
alias aws-dev='export AWS_PROFILE=company-dev'
alias aws-staging='export AWS_PROFILE=company-staging'
alias aws-prod='export AWS_PROFILE=company-prod'

# Quick profile switcher with prompt
awsenv() {
  export AWS_PROFILE="$1"
  echo "AWS Profile set to: $AWS_PROFILE"
}
```

### Custom AWS Functions

```bash
# Get RDS endpoint
rds-endpoint() {
  local instance="$1"
  aws rds describe-db-instances \
    --db-instance-identifier "$instance" \
    --query 'DBInstances[0].Endpoint.Address' \
    --output text
}

# List all Lambda functions
lambda-list() {
  aws lambda list-functions \
    --query 'Functions[].FunctionName' \
    --output table
}
```

## Kubernetes Configuration

### Custom Kubernetes Aliases

Create `zsh/.config/zshrc.d/71-kubernetes.zsh`:

```bash
# Context shortcuts
alias kc-dev='kubectl config use-context dev-cluster'
alias kc-staging='kubectl config use-context staging-cluster'
alias kc-prod='kubectl config use-context prod-cluster'

# Namespace shortcuts
alias kn-app='kubens application'
alias kn-infra='kubens infrastructure'
alias kn-monitoring='kubens monitoring'

# Common operations
alias k-restart='kubectl rollout restart deployment'
alias k-logs-tail='kubectl logs -f --tail=100'
alias k-describe-pod='kubectl describe pod'
```

## Prompt Customization

### Starship Prompt

Edit `starship/.config/starship.toml`:

```toml
# Change the prompt format
format = """
$username\
$hostname\
$directory\
$git_branch\
$git_status\
$character
"""

# Customize colors
[character]
success_symbol = '[➜](bold green)'
error_symbol = '[✗](bold red)'

# Add/remove modules as needed
[aws]
disabled = false
symbol = "☁️ "

[kubernetes]
disabled = false
format = '[$symbol$context( \($namespace\))]($style) '
```

### Simple One-Line Prompt

For a minimal prompt, replace the format in `starship.toml`:

```toml
format = """
$directory\
$git_branch\
$character
"""

[character]
success_symbol = '[❯](bold green)'
error_symbol = '[❯](bold red)'
```

## Tmux Customization

### Change Prefix Key

Edit `tmux/.tmux.conf`:

```bash
# Change from Ctrl-a to Ctrl-b (default)
set-option -g prefix C-b
bind-key C-b last-window
bind-key b send-prefix
```

### Add Custom Key Bindings

```bash
# Split panes with | and -
bind | split-window -h
bind - split-window -v

# Resize panes
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5
```

### Different Status Bar

```bash
# Minimal status bar
set -g status-left ''
set -g status-right '%H:%M %d-%b-%y'
```

## Plugin Configuration

### Add New Zsh Plugins

Edit `zsh/.config/zshrc.d/30-plugins.zsh`:

```bash
# Add your plugins
zinit light your-username/your-plugin

# Or from Oh My Zsh
zinit snippet OMZP::plugin-name
```

### Add Tmux Plugins

Edit `tmux/.tmux.conf`:

```bash
# Add before the last line (run '~/.tmux/plugins/tpm/tpm')
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
```

Then reload tmux and press `Ctrl-a + I` to install.

## Enabling/Disabling Features

### Disable AWS Functions

```bash
mv zsh/.config/zshrc.d/70-aws.zsh zsh/.config/zshrc.d/70-aws.zsh.disabled
```

### Enable Tmux Auto-start

Edit `zsh/.config/zshrc.d/99-final.zsh`:

```bash
# Uncomment this line:
start_tmux
```

### Disable Vi Mode

Edit `zsh/.config/zshrc.d/20-settings.zsh`:

```bash
# Comment out:
# set -o vi
```

## Machine-Specific Configuration

### Create Local Config

Create `~/.zshrc.local` for machine-specific settings:

```bash
# ~/.zshrc.local - Not tracked in git

# Local environment variables
export COMPANY_VPN="vpn.company.com"
export LOCAL_DEV_PATH="/mnt/projects"

# Local aliases
alias mount-nas='sudo mount -t cifs //nas/share /mnt/nas'

# Local functions
work() {
  cd "$LOCAL_DEV_PATH/$1"
}

# Override settings
export HISTSIZE=100000
```

This file is automatically sourced by `99-final.zsh` if it exists.

## Theme Colors

### Terminal Colors

The configuration uses a Base16 color scheme. To change:

1. **Starship**: Edit colors in `starship/.config/starship.toml`
2. **Tmux**: Edit status bar colors in `tmux/.tmux.conf`
3. **Terminal**: Configure in your terminal emulator settings

### Syntax Highlighting

For `bat` (used as `cat` alias):

```bash
# Set theme
export BAT_THEME="TwoDark"

# Or try others:
bat --list-themes
```

## Advanced Customization

### Custom Completion

Create `zsh/.config/zshrc.d/41-custom-completions.zsh`:

```bash
# Custom completion for your tool
_mytool_completion() {
  local -a commands
  commands=(
    'start:Start the service'
    'stop:Stop the service'
    'restart:Restart the service'
  )
  _describe 'command' commands
}

compdef _mytool_completion mytool
```

### Custom Widgets

```bash
# Search command history for current directory
local-history-search() {
  zle push-input
  BUFFER="history | grep $(pwd) | grep "
  zle end-of-line
}
zle -N local-history-search
bindkey '^[h' local-history-search
```

## Company/Team Configuration

### Shared Team Config

Create a separate repo for team-shared configs:

```bash
# Clone team configs
git clone git@github.com:company/team-dotfiles.git ~/.config/team

# Source in your config
# In zsh/.config/zshrc.d/72-team.zsh:
if [ -f ~/.config/team/team.zsh ]; then
  source ~/.config/team/team.zsh
fi
```

### Environment-Specific Configs

```bash
# In ~/.zshrc.local
case "$HOST" in
  dev-*)
    export ENV="development"
    source ~/.config/dev-env.zsh
    ;;
  staging-*)
    export ENV="staging"
    source ~/.config/staging-env.zsh
    ;;
  prod-*)
    export ENV="production"
    source ~/.config/prod-env.zsh
    ;;
esac
```

## Testing Changes

### Test Without Committing

```bash
# Make changes to a config file
nvim ~/.config/zshrc.d/50-aliases.zsh

# Reload configuration
source ~/.zshrc
# or
exec zsh

# Test your changes
# If good, commit:
cd ~/dotfiles
git add zsh/.config/zshrc.d/50-aliases.zsh
git commit -m "Add new aliases"
```

### Backup Before Major Changes

```bash
# Backup current config
tar -czf ~/dotfiles-backup-$(date +%Y%m%d).tar.gz ~/dotfiles

# Make changes
# If something breaks:
cd ~
tar -xzf ~/dotfiles-backup-20241104.tar.gz
cd dotfiles
stow -R */
```

## Performance Tuning

### Lazy Load Heavy Tools

```bash
# In zsh/.config/zshrc.d/30-plugins.zsh
# Instead of:
# eval "$(some-slow-tool init zsh)"

# Use:
zinit ice wait lucid
zinit snippet <(some-slow-tool init zsh)
```

### Reduce Plugin Load

Comment out plugins you don't use in `30-plugins.zsh`:

```bash
# zinit light plugin-i-dont-use
```

### Profile Startup

Add to `~/.zshrc`:

```bash
zmodload zsh/zprof
# ... rest of config ...
zprof  # At the end
```

## Getting Help

For customization questions:
1. Check the relevant config file in `zsh/.config/zshrc.d/`
2. Read tool documentation (starship, tmux, etc.)
3. Check examples in this guide
4. Search for similar customizations online

---

**Remember**: After making changes, always reload your configuration with `source ~/.zshrc` or `exec zsh` to test them!
