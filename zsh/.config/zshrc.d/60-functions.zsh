# ~/.config/zshrc.d/60-functions.zsh
# Useful shell functions

# ===== nnn file manager with cd on quit =====
n() {
  # Block nesting of nnn in subshells
  if [ -n "$NNNLVL" ] && [ "${NNNLVL:-0}" -ge 1 ]; then
    echo "nnn is already running"
    return
  fi

  # The default behaviour is to cd on quit
  export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

  nnn "$@"

  if [ -f "$NNN_TMPFILE" ]; then
    . "$NNN_TMPFILE"
    rm -f "$NNN_TMPFILE" > /dev/null
  fi
}

# ===== Create directory and cd into it =====
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# ===== Extract various archive types =====
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz) tar xzf "$1" ;;
      *.tar.xz) tar xJf "$1" ;;
      *.bz2) bunzip2 "$1" ;;
      *.rar) unrar x "$1" ;;
      *.gz) gunzip "$1" ;;
      *.tar) tar xf "$1" ;;
      *.tbz2) tar xjf "$1" ;;
      *.tgz) tar xzf "$1" ;;
      *.zip) unzip "$1" ;;
      *.Z) uncompress "$1" ;;
      *.7z) 7z x "$1" ;;
      *) echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# ===== Find files by name =====
ff() {
  find . -type f -iname "*$1*"
}

# ===== Find directories by name =====
fd() {
  find . -type d -iname "*$1*"
}

# ===== Quick note taking =====
note() {
  local note_file="${HOME}/notes/$(date +%Y-%m-%d).md"
  mkdir -p "${HOME}/notes"
  
  if [ $# -eq 0 ]; then
    ${EDITOR} "$note_file"
  else
    echo "- $(date +%H:%M) - $*" >> "$note_file"
  fi
}

# ===== Git functions =====
# Quick commit with message
gcm() {
  git add -A && git commit -m "$*"
}

# Create and checkout new branch
gnb() {
  git checkout -b "$1"
}

# Git clone and cd into directory
gclone() {
  git clone "$1" && cd "$(basename "$1" .git)"
}

# ===== Docker functions =====
# Docker cleanup
dcleanup() {
  echo "Removing stopped containers..."
  docker container prune -f
  echo "Removing dangling images..."
  docker image prune -f
  echo "Removing unused volumes..."
  docker volume prune -f
  echo "Removing unused networks..."
  docker network prune -f
}

# Docker shell into running container
dsh() {
  docker exec -it "$1" /bin/bash
}

# ===== System functions =====
# Show disk usage in current directory
diskspace() {
  du -h --max-depth=1 | sort -hr
}

# Show largest files in current directory
largest() {
  local num="${1:-10}"
  find . -type f -exec du -h {} + | sort -rh | head -n "$num"
}

# ===== Network functions =====
# Port check
port() {
  if [ $# -eq 0 ]; then
    echo "Usage: port <port_number>"
    return 1
  fi
  lsof -i :"$1"
}

# ===== Backup function =====
backup() {
  if [ $# -eq 0 ]; then
    echo "Usage: backup <file_or_directory>"
    return 1
  fi
  cp -r "$1" "${1}.backup.$(date +%Y%m%d_%H%M%S)"
}

# ===== tmux auto-attach or create =====
tm() {
  if [ $# -eq 0 ]; then
    # If no session name provided, attach to first available or create new
    tmux attach-session -t $(tmux list-sessions -F '#S' | head -n 1) 2>/dev/null || tmux new-session
  else
    # If session name provided, attach to it or create it
    tmux attach-session -t "$1" 2>/dev/null || tmux new-session -s "$1"
  fi
}

# ===== Path management =====
# Add to PATH if not already present
pathadd() {
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
    export PATH="$1:$PATH"
  fi
}

# Show PATH in readable format
path() {
  echo $PATH | tr ':' '\n' | nl
}

# ===== Quick server =====
# Start a simple HTTP server
serve() {
  local port="${1:-8000}"
  python3 -m http.server "$port"
}

# ===== Search history =====
hs() {
  if [ $# -eq 0 ]; then
    history
  else
    history | grep "$*"
  fi
}
