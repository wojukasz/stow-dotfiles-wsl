# ~/.config/zshrc.d/50-aliases.zsh
# Command aliases

# ===== Navigation =====
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias -- -="cd -"

# Quick directory access
alias cdd="cd ~/Downloads/"
alias cdg="cd ~/git/"

# ===== Editor =====
if command -v nvim &>/dev/null; then
  alias vim='nvim'
  alias vi='nvim'
  alias v='nvim'
elif command -v vim &>/dev/null; then
  alias vi='vim'
fi

# ===== File Listing =====
if command -v exa &>/dev/null; then
  alias ls='exa --icons'
  alias ll='exa -l --icons --git -a'
  alias la='exa -la --icons --git'
  alias lt='exa --tree --icons --git --long'
  alias l='exa -l --icons --git'
else
  alias ll='ls --color=auto -lh'
  alias la='ls --color=auto -lAh'
  alias l='ls --color=auto -lh'
fi

# Tree view
if command -v tree &>/dev/null; then
  alias tree='tree -C'
fi

# ===== Git =====
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --decorate --graph'

# ===== Modern CLI Tools =====
# bat (better cat)
if command -v bat &>/dev/null; then
  alias cat='bat --paging=never'
  alias less='bat'
fi

# fd (better find)
if command -v fdfind &>/dev/null; then
  alias fd='fdfind'
fi

# ===== System =====
alias h='history'
alias j='just'
alias k='kubectl'
alias tf='terraform'
alias d='docker'
alias dc='docker-compose'

# Process management
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias ports='netstat -tulanp'

# System info
alias meminfo='free -m -l -t'
alias cpuinfo='lscpu'
alias df='df -h'
alias du='du -h'

# ===== Safety nets =====
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'

# ===== Kubernetes =====
alias k='kubectl'
alias kx='kubectx'
alias kn='kubens'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deployments'
alias kl='kubectl logs'
alias kd='kubectl describe'
alias ke='kubectl edit'

# ===== Terraform =====
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tff='terraform fmt'
alias tfv='terraform validate'

# ===== SSH =====
alias key='ssh-add ~/.ssh/gitkey'
alias keycl='ssh-add -D'
alias keylist='ssh-add -l'

# ===== Miscellaneous =====
# Generate SHA-512 password hash
alias pwhash='python -c "import crypt,getpass; print(crypt.crypt(getpass.getpass(), crypt.mksalt(crypt.METHOD_SHA512)))"'

# Network
alias myip='curl ifconfig.me'
alias localip='ip -4 addr show | grep -oP "(?<=inet\s)\d+(\.\d+){3}"'

# Arch Linux specific
if command -v paru &>/dev/null; then
  alias update='paru -Syu'
  alias install='paru -S'
  alias remove='paru -Rns'
  alias search='paru -Ss'
fi

# Make commands run at lower priority
if command -v makepkg &>/dev/null; then
  alias makepkg='chrt --idle 0 ionice -c idle makepkg'
fi

# Reload zsh config
alias reload='source ~/.zshrc'

# Quick edit configs
alias zshconfig='nvim ~/.zshrc'
alias zshenv='nvim ~/.config/zshrc.d/10-environment.zsh'
alias zshalias='nvim ~/.config/zshrc.d/50-aliases.zsh'
