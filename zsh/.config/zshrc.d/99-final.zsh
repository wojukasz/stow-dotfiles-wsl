# ~/.config/zshrc.d/99-final.zsh
# Final initialization - SSH agent, tmux auto-start, etc.

# ===== SSH Agent =====
# Start SSH agent if not already running
if [ -z "$SSH_AUTH_SOCK" ]; then
  # Check if ssh-agent is already running
  if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)" > /dev/null
  fi
fi

# Auto-add SSH key if it exists (suppress output)
if [ -f ~/.ssh/gitkey ]; then
  ssh-add ~/.ssh/gitkey 2>/dev/null
fi

# ===== Tmux Auto-start =====
# Automatically start or attach to tmux session
start_tmux() {
  # Only auto-start if:
  # 1. tmux is installed
  # 2. Not already in a tmux session
  # 3. This is an interactive shell
  # 4. Not running in VS Code or other specific environments
  
  if command -v tmux &> /dev/null; then
    # Skip if already in tmux
    if [ -z "$TMUX" ]; then
      # Skip if in VS Code integrated terminal
      if [ -z "$VSCODE_IPC_HOOK_CLI" ]; then
        # Skip if this is a login shell on specific host
        # Uncomment and modify the condition below if you want host-specific behaviour
        # if [[ $HOST == "your-hostname" ]]; then
          
        # Try to attach to existing session, or create new one
        tmux attach-session -t default 2>/dev/null || tmux new-session -s default
        
        # fi
      fi
    fi
  fi
}

# Uncomment the line below to enable tmux auto-start
# start_tmux

# ===== FZF Key Bindings =====
# If fzf is installed, set up key bindings
if command -v fzf &>/dev/null; then
  # Source fzf key bindings if available
  if [ -f /usr/share/fzf/key-bindings.zsh ]; then
    source /usr/share/fzf/key-bindings.zsh
  fi
  if [ -f /usr/share/fzf/completion.zsh ]; then
    source /usr/share/fzf/completion.zsh
  fi
fi

# ===== Directory Hashes =====
# Quick access to common directories
hash -d dl=~/Downloads
hash -d docs=~/Documents
hash -d git=~/git
hash -d dots=~/dotfiles

# ===== Welcome Message (optional) =====
# Uncomment for a nice welcome message
# echo "Welcome back, ${USER}!"
# echo "$(date '+%A, %d %B %Y %H:%M')"

# ===== Custom Local Configuration =====
# Source local configuration if it exists (machine-specific settings)
if [ -f ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi
