# ~/.config/zshrc.d/10-environment.zsh
# Environment variables and PATH configuration

# Default editor
export EDITOR='nvim'
export VISUAL='nvim'

# AWS Configuration
export AWS_REGION="eu-west-2"
export AWS_DEFAULT_REGION="eu-west-2"

# SSH agent socket (WSL)
if uname -a | grep 'Linux' &> /dev/null; then
  if [ -z "$SSH_AUTH_SOCK" ]; then
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
  fi
fi

# History configuration
export HISTFILE="${XDG_STATE_HOME}/zsh_history"
[[ -f "$HISTFILE" ]] || touch "$HISTFILE"
export HISTSIZE=50000
export SAVEHIST=50000
export HISTCONTROL=ignoredups:ignorespace

# McFly history search options
export MCFLY_FUZZY=2
export MCFLY_KEY_SCHEME=vim
export MCFLY_RESULTS=50

# nnn file manager options
export NNN_OPTS="aedF"
export NNN_BMS="D:~/Documents;d:~/Downloads;g:~/git;h:~;"
export NNN_PLUG='p:preview-tui'

# FZF configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# PATH Configuration
# User binaries
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# Cargo (Rust) binaries
export PATH="$HOME/.cargo/bin:$PATH"

# Ruby gems
export PATH="$HOME/.local/share/gem/ruby/3.0.0/bin:$PATH"

# Krew (kubectl plugin manager)
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# bash-my-aws
export PATH="${BMA_HOME:-$HOME/.bash-my-aws}/bin:$PATH"

# Python user binaries
export PATH="$HOME/Library/Python/3.8/bin:$PATH"

# System paths
export PATH="/usr/local/sbin:$PATH"

# Load secret environment variables if they exist
if [ -f ~/.secret_envvars ]; then
  source ~/.secret_envvars
fi
