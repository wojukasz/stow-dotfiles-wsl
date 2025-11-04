# ~/.config/zshrc.d/70-aws.zsh
# AWS-specific configuration, aliases, and functions

# ===== bash-my-aws Integration =====
if [ -d "${BMA_HOME:-$HOME/.bash-my-aws}" ]; then
  # Source bash-my-aws aliases and functions
  source "${BMA_HOME:-$HOME/.bash-my-aws}/aliases" 2>/dev/null || true
  
  # Skip bash completions - they don't work well in zsh
  # bash-my-aws functions will work, just without bash completion
fi

# ===== AWS Aliases =====
# AWS SSO
alias sso='aws configure sso'
alias awslogin='aws sso login'

# Quick profile switching
alias awsp='export AWS_PROFILE='

# EC2 Session Manager
ssm() {
  if [ $# -eq 0 ]; then
    echo "Usage: ssm <instance-id>"
    return 1
  fi
  aws ssm start-session --target "$1"
}

# ===== AWS Functions =====

# Assume AWS IAM Role
assume() {
  if [ $# -lt 2 ]; then
    echo "Usage: assume <role-arn> <session-name>"
    return 1
  fi
  
  local ROLE_ARN="$1"
  local SESSION_NAME="$2"
  
  echo "Assuming role: $ROLE_ARN"
  eval $(aws sts assume-role \
    --role-arn "$ROLE_ARN" \
    --role-session-name "$SESSION_NAME" \
    | jq -r '.Credentials | "export AWS_ACCESS_KEY_ID=\(.AccessKeyId)\nexport AWS_SECRET_ACCESS_KEY=\(.SecretAccessKey)\nexport AWS_SESSION_TOKEN=\(.SessionToken)\n"')
  
  if [ $? -eq 0 ]; then
    echo "Successfully assumed role: $ROLE_ARN"
    echo "Session name: $SESSION_NAME"
  else
    echo "Failed to assume role"
  fi
}

# Assume role by account ID (using standard OrgDeploy role)
awsrole() {
  if [ $# -eq 0 ]; then
    echo "Usage: awsrole <account-id>"
    echo "Assumes: arn:aws:iam::<account-id>:role/OrgDeploy"
    return 1
  fi
  
  local ACCOUNT_ID="$1"
  local ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/OrgDeploy"
  
  assume "$ROLE_ARN" "OrgDeploy"
}

# Clear AWS credentials from environment
awsclear() {
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_SESSION_TOKEN
  unset AWS_SECURITY_TOKEN
  unset AWS_PROFILE
  unset ASSUMED_ROLE
  echo "AWS credentials cleared from environment"
}

# Show current AWS identity
awswhoami() {
  aws sts get-caller-identity
}

# List all AWS profiles
awsprofiles() {
  aws configure list-profiles
}

# Switch AWS region
awsregion() {
  if [ $# -eq 0 ]; then
    echo "Current region: ${AWS_REGION:-${AWS_DEFAULT_REGION:-not set}}"
    return 0
  fi
  
  export AWS_REGION="$1"
  export AWS_DEFAULT_REGION="$1"
  echo "AWS region set to: $1"
}

# Get AWS account ID
awsaccount() {
  aws sts get-caller-identity --query Account --output text
}

# List EC2 instances with useful info
ec2list() {
  aws ec2 describe-instances \
    --query 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name,Tags[?Key==`Name`].Value|[0],PrivateIpAddress,PublicIpAddress]' \
    --output table
}

# Get EC2 instance ID by name tag
ec2id() {
  if [ $# -eq 0 ]; then
    echo "Usage: ec2id <name-tag>"
    return 1
  fi
  
  aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=$1" "Name=instance-state-name,Values=running" \
    --query 'Reservations[].Instances[].InstanceId' \
    --output text
}

# SSH into EC2 instance via Session Manager
ec2ssh() {
  if [ $# -eq 0 ]; then
    echo "Usage: ec2ssh <instance-id-or-name>"
    return 1
  fi
  
  local instance="$1"
  
  # Check if it's an instance ID or name
  if [[ ! "$instance" =~ ^i-[a-z0-9]+ ]]; then
    instance=$(ec2id "$instance")
    if [ -z "$instance" ]; then
      echo "No running instance found with name: $1"
      return 1
    fi
    echo "Found instance: $instance"
  fi
  
  aws ssm start-session --target "$instance"
}

# Get parameter from AWS Systems Manager Parameter Store
ssmget() {
  if [ $# -eq 0 ]; then
    echo "Usage: ssmget <parameter-name>"
    return 1
  fi
  
  aws ssm get-parameter --name "$1" --with-decryption --query 'Parameter.Value' --output text
}

# Put parameter to AWS Systems Manager Parameter Store
ssmput() {
  if [ $# -lt 2 ]; then
    echo "Usage: ssmput <parameter-name> <parameter-value> [type]"
    echo "Type can be: String (default), StringList, SecureString"
    return 1
  fi
  
  local name="$1"
  local value="$2"
  local type="${3:-String}"
  
  aws ssm put-parameter --name "$name" --value "$value" --type "$type" --overwrite
}

# List S3 buckets with sizes
s3buckets() {
  for bucket in $(aws s3 ls | awk '{print $3}'); do
    size=$(aws s3 ls s3://$bucket --recursive --summarize | grep "Total Size" | awk '{print $3}')
    echo "$bucket: $size bytes"
  done
}

# Get CloudWatch Logs
cwlogs() {
  if [ $# -eq 0 ]; then
    echo "Usage: cwlogs <log-group-name> [stream-name]"
    return 1
  fi
  
  local log_group="$1"
  local log_stream="$2"
  
  if [ -n "$log_stream" ]; then
    aws logs tail "$log_group" --log-stream-names "$log_stream" --follow
  else
    aws logs tail "$log_group" --follow
  fi
}

# Export AWS credentials for use in other tools
awsexport() {
  if [ $# -eq 0 ]; then
    echo "Usage: awsexport <profile-name>"
    return 1
  fi
  
  local profile="$1"
  
  eval $(aws configure export-credentials --profile "$profile" --format env)
  echo "Exported credentials for profile: $profile"
}

# ===== AWS-Vault Integration =====
if command -v aws-vault &>/dev/null; then
  alias av='aws-vault'
  alias ave='aws-vault exec'
  alias avl='aws-vault list'
  alias avr='aws-vault remove'
  
  # Execute command with aws-vault profile
  avexec() {
    if [ $# -lt 2 ]; then
      echo "Usage: avexec <profile> <command>"
      return 1
    fi
    
    local profile="$1"
    shift
    aws-vault exec "$profile" -- "$@"
  }
fi
