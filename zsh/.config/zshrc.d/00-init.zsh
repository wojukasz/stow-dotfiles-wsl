# ~/.config/zshrc.d/00-init.zsh
# Early initialization - locale, asdf, critical settings

# Set locale (UK English)
export LANG=en_GB.UTF-8
export LC_ALL=en_GB.UTF-8
export LANGUAGE=en_GB.UTF-8

# XDG Base Directory Specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Ensure XDG directories exist
mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME" "$XDG_STATE_HOME"

# Initialize asdf version manager WITHOUT bash completions
if [ -f ~/.asdf/asdf.sh ]; then
  # Prevent asdf from loading any completions at this stage
  export ASDF_DIR="$HOME/.asdf"
  
  # Source asdf but skip completions (they'll be handled by zinit later)
  source ~/.asdf/asdf.sh
  
  # Remove the bash completion function if it was loaded
  unfunction _asdf 2>/dev/null || true
fi
