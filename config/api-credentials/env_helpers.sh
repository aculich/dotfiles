#!/bin/bash
# Helper functions for detecting and syncing .env files with 1Password Environments

# Detect .env files in project
# Usage: detect_env_file [project_root]
# Returns: path to .env file or empty string
detect_env_file() {
  local project_root="${1:-$(pwd)}"
  local env_file=""
  
  # Common .env file locations
  local candidates=(
    "$project_root/.env"
    "$project_root/.env.local"
    "$project_root/.env.development"
    "$project_root/.env.production"
  )
  
  for candidate in "${candidates[@]}"; do
    if [ -f "$candidate" ]; then
      env_file="$candidate"
      break
    fi
  done
  
  echo "$env_file"
}

# Extract project name from directory or git
# Usage: get_project_name [project_root]
# Returns: project name
get_project_name() {
  local project_root="${1:-$(pwd)}"
  local project_name=""
  
  # Try git first
  if [ -d "$project_root/.git" ]; then
    project_name=$(git -C "$project_root" rev-parse --show-toplevel 2>/dev/null | xargs basename 2>/dev/null)
  fi
  
  # Fallback to directory name
  if [ -z "$project_name" ]; then
    project_name=$(basename "$project_root")
  fi
  
  echo "$project_name"
}

# Check if 1Password Environment exists
# Note: This is a best-effort check since 1Password CLI doesn't support environments directly
# We check for the existence of the mounted .env file (FIFO)
# Usage: check_1password_env [env_name] [mount_path]
# Returns: 0 if exists, 1 if not
check_1password_env() {
  local env_name="${1:-}"
  local mount_path="${2:-}"
  
  if [ -z "$mount_path" ]; then
    return 1
  fi
  
  # Check if file exists and is a FIFO (named pipe)
  if [ -p "$mount_path" ]; then
    return 0
  fi
  
  return 1
}

# Parse .env file and format for 1Password
# Usage: parse_env_file [env_file]
# Returns: formatted .env content (safe for import)
parse_env_file() {
  local env_file="${1:-}"
  
  if [ ! -f "$env_file" ]; then
    echo "" >&2
    return 1
  fi
  
  # Read and format the file
  # Remove comments and empty lines, preserve key=value format
  grep -v '^[[:space:]]*#' "$env_file" | grep -v '^[[:space:]]*$' | while IFS= read -r line; do
    # Skip lines that don't look like KEY=value
    if [[ "$line" =~ ^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*= ]]; then
      echo "$line"
    fi
  done
}

# Main sync function
# Usage: sync_env_to_1password [project_root]
# Returns: 0 on success, 1 on failure
sync_env_to_1password() {
  local project_root="${1:-$(pwd)}"
  local env_file
  local project_name
  local env_name
  
  # Detect .env file
  env_file=$(detect_env_file "$project_root")
  if [ -z "$env_file" ]; then
    echo "No .env file found in $project_root" >&2
    return 1
  fi
  
  echo "Found .env file: $env_file"
  
  # Get project name
  project_name=$(get_project_name "$project_root")
  env_name="$project_name"
  
  echo "Project name: $project_name"
  echo "Environment name: $env_name"
  
  # Check if environment already exists
  local mount_path="$project_root/.env"
  if check_1password_env "$env_name" "$mount_path"; then
    echo "1Password Environment already exists and is mounted at $mount_path"
    return 0
  fi
  
  # Environment doesn't exist - generate setup instructions
  echo ""
  echo "1Password Environment not found. Generating setup instructions..."
  echo ""
  
  # Run create_project_environment.sh
  local script_path="$HOME/dotfiles/config/api-credentials/create_project_environment.sh"
  if [ -f "$script_path" ]; then
    "$script_path" \
      --project-name "$project_name" \
      --env-name "$env_name" \
      --mount-path "$mount_path" \
      --project-root "$project_root"
  else
    echo "Error: create_project_environment.sh not found at $script_path" >&2
    return 1
  fi
  
  # Parse and display .env content (for import reference)
  echo ""
  echo "Parsed .env file content (for import reference):"
  echo "----------------------------------------"
  parse_env_file "$env_file" | head -20
  if [ $(parse_env_file "$env_file" | wc -l) -gt 20 ]; then
    echo "... (showing first 20 lines)"
  fi
  echo "----------------------------------------"
  
  return 0
}

