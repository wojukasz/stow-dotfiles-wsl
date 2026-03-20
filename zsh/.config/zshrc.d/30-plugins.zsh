# ~/.config/zshrc.d/30-plugins.zsh
# Plugin management with zinit

# Install zinit if not present
ZINIT_HOME="${XDG_DATA_HOME}/zinit"
mkdir -p "$ZINIT_HOME"

if [ ! -d "${ZINIT_HOME}/bin" ]; then
  echo "Installing zinit..."
  git clone https://github.com/zdharma-continuum/zinit.git "${ZINIT_HOME}/bin"
fi

# Configure zinit
declare -A ZINIT
ZINIT[BIN_DIR]="${ZINIT_HOME}/bin"
ZINIT[HOME_DIR]="${ZINIT_HOME}"

source "${ZINIT_HOME}/bin/zinit.zsh"

# ===== Prompt =====
# Starship prompt (fast, customizable)
zinit ice from"gh-r" as"program" atclone"./starship init zsh > init.zsh" atpull"%atclone" src"init.zsh"
zinit light starship/starship

# ===== Initialize Completion FIRST (synchronously, no wait) =====
zinit ice lucid atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay"
zinit light zdharma-continuum/fast-syntax-highlighting

# ===== Load fzf-tab IMMEDIATELY after compinit (no wait!) =====
zinit light Aloxaf/fzf-tab

# ===== Now load everything else with wait =====

# Auto-suggestions (fish-like)
zinit ice wait lucid atload"!_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

# Additional completions
zinit ice wait lucid blockf
zinit light zsh-users/zsh-completions

# ===== Tool-specific Plugins =====
# Terraform helpers
zinit light macunha1/zsh-terraform

# Command hints
zinit light joepvd/zsh-hints

# Helpful tips for aliases
zinit light molovo/tipz

# ===== OMZ Plugins =====
# AWS plugin from Oh My Zsh
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl

# Command-not-found suggestions
zinit snippet 'https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/command-not-found/command-not-found.plugin.zsh'

# FZF plugin from Oh My Zsh
zinit ice wait lucid
zinit snippet OMZP::fzf

# ===== Additional Tools =====
# Zoxide (smarter cd command)
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
elif command -v cargo &>/dev/null; then
  echo "Installing zoxide..."
  cargo install zoxide --locked
  eval "$(zoxide init zsh)"
fi

# Direnv (environment variable management per directory)
if command -v direnv &>/dev/null; then
  eval "$(asdf exec direnv hook zsh)"
  # Shortcut for asdf-managed direnv
  direnv() { asdf exec direnv "$@"; }
fi

# McFly (better history search)
# Detect architecture for correct binary
case $(uname) in
  Darwin)
    case $(uname -m) in
      x86_64) mcfly_os="*x86_64*darwin*" ;;
      arm64) mcfly_os="*aarch64*darwin*" ;;
    esac
    ;;
  Linux)
    case $(uname -m) in
      x86_64) mcfly_os="*x86_64*linux*musl*" ;;
      arm64|aarch64) mcfly_os="*aarch64*linux*" ;;
    esac
    ;;
esac

zinit ice wait lucid from"gh-r" as"program" atload'eval "$(mcfly init zsh)"' bpick"${mcfly_os}"
zinit light cantino/mcfly

# ===== Completion Loading =====
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
