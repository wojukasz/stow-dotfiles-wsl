# SSH Agent configuration
# Automatically start ssh-agent and load keys

SSH_ENV="$HOME/.ssh/agent-env"

_start_ssh_agent() {
  eval "$(ssh-agent -s)" > /dev/null
  echo "SSH_AUTH_SOCK=$SSH_AUTH_SOCK; export SSH_AUTH_SOCK;" > "$SSH_ENV"
  echo "SSH_AGENT_PID=$SSH_AGENT_PID; export SSH_AGENT_PID;" >> "$SSH_ENV"
}

# Check if current agent is actually usable (exit code 2 = no agent)
ssh-add -l &>/dev/null
if [ $? -eq 2 ]; then
  # No working agent — try to restore from saved env
  if [ -f "$SSH_ENV" ]; then
    . "$SSH_ENV" > /dev/null
    ssh-add -l &>/dev/null
    if [ $? -eq 2 ]; then
      _start_ssh_agent
    fi
  else
    _start_ssh_agent
  fi
fi

# Ensure the key is loaded regardless of how we got the agent
ssh-add -l 2>/dev/null | grep -q gitkey || ssh-add ~/.ssh/gitkey 2>/dev/null
