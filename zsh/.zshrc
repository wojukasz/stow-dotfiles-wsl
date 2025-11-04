# ~/.zshrc
# Main zsh configuration file
# Modular configuration stored in ~/.config/zshrc.d/

# Performance tracking (optional - uncomment to profile startup)
# zmodload zsh/zprof

# Source all configuration files in order
ZSHRC_DIR="${HOME}/.config/zshrc.d"

if [ -d "$ZSHRC_DIR" ]; then
  for config_file in "$ZSHRC_DIR"/*.zsh; do
    [ -f "$config_file" ] && source "$config_file"
  done
fi

# Performance report (optional - uncomment to see profile)
# zprof

# asdf version manager
. "$HOME/.asdf/asdf.sh"
