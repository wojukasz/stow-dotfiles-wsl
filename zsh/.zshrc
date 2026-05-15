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

alias mediaserver='ssh -i /home/wojukasz/.ssh/id_ed25519_pi lukani@192.168.0.169'

alias bootdev='/home/wojukasz/.asdf/installs/golang/1.25.3/bin/bootdev'

export OLLAMA_HOST=0.0.0.0


# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
 alias zr='find . -type f -name "*:Zone.Identifier" -delete'
