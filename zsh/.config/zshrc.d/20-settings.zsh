# ~/.config/zshrc.d/20-settings.zsh
# Zsh behaviour and option settings

# ===== Basics =====
KEYTIMEOUT=1                # Eliminate ZSH delay waiting for key sequence (multiples of 100ms)
set -o vi                   # Vi mode
setopt interactive_comments # Allow comments in interactive shells
setopt no_beep              # Don't beep on error

# ===== Changing Directories =====
setopt auto_cd              # Type directory name to cd into it
setopt auto_pushd           # Make cd push old directory onto directory stack
setopt pushd_ignore_dups    # Don't push multiple copies of same directory
setopt pushd_minus          # Exchanges meanings of +/- when navigating directory stack

# ===== Expansion and Globbing =====
setopt extended_glob        # Treat #, ~, and ^ as part of patterns for filename generation
setopt glob_dots            # Include dotfiles in globbing

# ===== History =====
setopt append_history          # Allow multiple terminal sessions to all append to one history
setopt extended_history        # Save timestamp and duration
setopt inc_append_history      # Add commands as they are typed, don't wait until shell exit
setopt hist_expire_dups_first  # When trimming history, lose oldest duplicates first
setopt hist_ignore_dups        # Don't write duplicate events
setopt hist_ignore_space       # Remove command from history if it starts with space
setopt hist_find_no_dups       # When searching, don't display duplicates
setopt hist_reduce_blanks      # Remove extra blanks from each command
setopt hist_verify             # Don't execute immediately upon history expansion
setopt share_history           # Share history between all sessions

# ===== Completion =====
setopt always_to_end       # Move cursor to end of word after completion
setopt auto_menu           # Show completion menu on successive tab press
setopt auto_name_dirs      # Any parameter set to absolute directory name becomes name for it
setopt complete_in_word    # Allow completion from within a word/phrase
setopt path_dirs           # Perform path search even on command names with slashes

unsetopt menu_complete     # Don't autoselect first completion entry

# ===== Correction =====
setopt correct             # Spelling correction for commands
unsetopt correct_all       # Don't correct arguments

# ===== Prompt =====
setopt prompt_subst        # Enable parameter expansion, command substitution in prompt

# ===== Scripts and Functions =====
setopt multios             # Perform implicit tees or cats when multiple redirections are attempted
