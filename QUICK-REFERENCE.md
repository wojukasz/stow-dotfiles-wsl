# ZSH Configuration Quick Reference

## Setup

```bash
# Run complete setup
cd ~/dotfiles
./setup-wsl-complete.sh

# Manual stow
cd ~/dotfiles
stow -t $HOME zsh
exec zsh

# Fix locale issues
./fix-locale.sh
```

## AWS Quick Reference

### Authentication
```bash
aws configure sso --profile myprofile    # Configure SSO
aws sso login --profile myprofile        # Login
sso                                      # Alias for aws configure sso
awslogin                                 # Alias for aws sso login
```

### Role Assumption
```bash
assume <role-arn> <session>              # Assume any role
awsrole 123456789012                     # Assume OrgDeploy role in account
awsclear                                 # Clear AWS credentials
awswhoami                                # Show current identity
awsaccount                               # Get account ID
```

### EC2
```bash
ec2list                                  # List all instances
ec2id my-instance                        # Get instance ID by name
ec2ssh my-instance                       # SSH via SSM
ssm i-1234567890abcdef0                 # Start SSM session
```

### SSM Parameter Store
```bash
ssmget /my/parameter                     # Get parameter
ssmput /my/parameter "value"             # Put parameter
ssmput /my/secret "value" SecureString   # Put secure parameter
```

### CloudWatch Logs
```bash
cwlogs /aws/lambda/my-function           # Tail log group
cwlogs /aws/lambda/my-function stream    # Tail specific stream
```

### S3
```bash
s3buckets                                # List buckets with sizes
```

### Regions & Profiles
```bash
awsregion                                # Show current region
awsregion eu-west-1                      # Set region
awsprofiles                              # List all profiles
awsp myprofile                           # Set AWS_PROFILE
```

## Kubernetes Quick Reference

### Aliases
```bash
k                                        # kubectl
kx                                       # kubectx (switch context)
kn                                       # kubens (switch namespace)
```

### Common Operations
```bash
kgp                                      # kubectl get pods
kgp -w                                   # Watch pods
kgs                                      # kubectl get services
kgd                                      # kubectl get deployments
kl <pod>                                 # kubectl logs
kl -f <pod>                              # Follow logs
kd pod <pod>                             # kubectl describe pod
ke deployment <name>                     # kubectl edit deployment
```

## Terraform Quick Reference

```bash
tf                                       # terraform
tfi                                      # terraform init
tfp                                      # terraform plan
tfa                                      # terraform apply
tfd                                      # terraform destroy
tff                                      # terraform fmt
tfv                                      # terraform validate
```

## Docker Quick Reference

```bash
d                                        # docker
dc                                       # docker-compose
dcleanup                                 # Clean up containers, images, volumes
dsh <container>                          # Shell into container
```

## Navigation

```bash
..                                       # cd ..
...                                      # cd ../..
-                                        # cd to previous directory
cdg                                      # cd ~/git
cdd                                      # cd ~/Downloads
```

### Zoxide (Smart CD)
```bash
z project                                # Jump to project directory
z -l                                     # List recent directories
zi                                       # Interactive directory selection
```

## File Operations

### Listing
```bash
ll                                       # exa -l (detailed list)
la                                       # exa -la (all files)
lt                                       # exa --tree (tree view)
ls                                       # exa (simple list)
```

### Search
```bash
fd pattern                               # Find files
rg pattern                               # Search file contents
ff pattern                               # Find files (function)
ffd pattern                              # Find directories (function)
```

### Viewing
```bash
cat file                                 # bat (with syntax highlighting)
less file                                # bat (paginated)
```

## Shell Functions

### File Management
```bash
mkcd dirname                             # Create directory and cd into it
extract archive.tar.gz                   # Extract any archive type
backup file.txt                          # Create timestamped backup
```

### Git
```bash
gcm "message"                            # Git commit all with message
gnb branch-name                          # Create and checkout new branch
gclone <url>                             # Clone and cd into repo
```

### System
```bash
diskspace                                # Show disk usage in current dir
largest 10                               # Show 10 largest files
port 8080                                # Check what's using port 8080
myip                                     # Show public IP
localip                                  # Show local IP
```

### Utilities
```bash
note "Meeting notes"                     # Quick note taking
serve 8080                               # Start HTTP server
path                                     # Show PATH in readable format
hs <pattern>                             # Search history
```

## Tmux

```bash
tm                                       # Attach/create default session
tm session-name                          # Attach/create named session
prefix + I                               # Install tmux plugins (Ctrl-b + Shift-i)
```

## Plugin Management

```bash
zinit update --all                       # Update all plugins
zinit self-update                        # Update zinit itself
```

## Completion

```bash
<command> **<tab>                        # FZF fuzzy completion
Ctrl-R                                   # McFly history search
```

## Editor

```bash
vim file                                 # Open in neovim (alias)
vi file                                  # Open in neovim (alias)
v file                                   # Open in neovim (alias)
```

## History Search

```bash
Ctrl-R                                   # McFly fuzzy history search
                                         # In McFly: Ctrl-N/P or arrows to navigate
                                         # Vim keys (j/k) also work
```

## File Manager

```bash
n                                        # Open nnn file manager (cd on quit)
                                         # In nnn: ? for help
```

## SSH

```bash
key                                      # Add SSH key (gitkey)
keycl                                    # Clear all SSH keys
keylist                                  # List loaded keys
```

## Configuration

### Edit Configs
```bash
zshconfig                                # Edit main .zshrc
zshenv                                   # Edit environment variables
zshalias                                 # Edit aliases
nvim ~/.config/zshrc.d/70-aws.zsh       # Edit AWS config
```

### Reload Config
```bash
reload                                   # Reload zsh config
exec zsh                                 # Restart shell completely
```

## Package Management (Arch)

```bash
update                                   # paru -Syu (update system)
install package                          # paru -S (install package)
remove package                           # paru -Rns (remove package)
search pattern                           # paru -Ss (search packages)
```

## System Information

```bash
meminfo                                  # Show memory info
cpuinfo                                  # Show CPU info
df                                       # Disk free space
du                                       # Disk usage
htop                                     # Interactive process viewer
btop                                     # Better process viewer
```

## Common Workflows

### New AWS Profile Setup
```bash
aws configure sso --profile mycompany
aws sso login --profile myprofile
export AWS_PROFILE=myprofile
# or
awsp myprofile
```

### EC2 Troubleshooting
```bash
ec2list                                  # Find your instance
ec2ssh my-instance-name                  # Connect via SSM
```

### Deploy Infrastructure
```bash
cd ~/git/terraform-project
tfi                                      # terraform init
tfp                                      # terraform plan
tfa                                      # terraform apply
```

### Kubernetes Debugging
```bash
kx production                            # Switch to prod context
kn my-namespace                          # Switch to namespace
kgp                                      # List pods
kl -f pod-name                           # Follow logs
kd pod pod-name                          # Describe pod
```

### Quick System Cleanup
```bash
dcleanup                                 # Clean Docker
paru -Sc                                 # Clean package cache
```

## Keyboard Shortcuts

### Command Line Editing (Vi mode)
```
ESC                                      # Enter normal mode
i                                        # Enter insert mode
A                                        # Append at end of line
I                                        # Insert at beginning
dd                                       # Delete line
yy                                       # Yank (copy) line
p                                        # Paste
/                                        # Search history
```

### zsh-specific
```
Ctrl-R                                   # History search (McFly)
Ctrl-T                                   # FZF file search
Alt-C                                    # FZF directory search
Tab                                      # FZF completion
```

## Environment Variables

### Important Paths
```
$HOME/.asdf                              # ASDF version manager
$HOME/.local/bin                         # User binaries
$HOME/.cargo/bin                         # Rust binaries
$HOME/.krew/bin                          # Kubectl plugins
$HOME/.bash-my-aws                       # AWS helpers
```

### AWS Variables
```
$AWS_REGION                              # AWS region
$AWS_DEFAULT_REGION                      # AWS default region
$AWS_PROFILE                             # AWS profile name
$AWS_ACCESS_KEY_ID                       # AWS access key
$AWS_SECRET_ACCESS_KEY                   # AWS secret key
$AWS_SESSION_TOKEN                       # AWS session token
```

## Tips & Tricks

1. **Use `z` instead of `cd`** - Faster directory jumping
2. **Use `ll` instead of `ls -la`** - Better file listing
3. **Press `Ctrl-R`** - Fuzzy search history
4. **Use `**<TAB>`** - FZF fuzzy completion for files/directories
5. **Type partial command + `Ctrl-R`** - Search history for that command
6. **Use `cat` for syntax-highlighted output** - `bat` is aliased
7. **Use `n` for file browsing** - nnn file manager with cd on quit
8. **Create notes quickly** - `note "something"` appends to today's note
9. **Extract any archive** - `extract file.tar.gz` (no need to remember flags)
10. **Use `tm`** - Quick tmux session management

## Troubleshooting

### Slow Startup
```bash
# Profile startup time
time zsh -i -c exit

# Clear completion cache
rm ~/.cache/zsh/zcompdump*

# Update plugins
zinit update --all
```

### Completion Issues
```bash
rm ~/.cache/zsh/zcompdump*
compinit
exec zsh
```

### AWS Issues
```bash
awsclear                                 # Clear cached credentials
aws configure list                       # Check configuration
aws sso login --profile myprofile        # Re-login
```

### Locale Errors
```bash
./fix-locale.sh                          # Fix locale configuration
```

---

**Keep this file handy for quick reference!**

Save to: `~/quick-reference.md`
