#!/usr/bin/env bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(cd "$script_dir/.." && pwd)
env_file="$repo_root/.env"

if [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]]; then
  color_reset=$'\033[0m'
  color_red=$'\033[31m'
  color_green=$'\033[32m'
  color_yellow=$'\033[33m'
  color_blue=$'\033[34m'
  color_bold=$'\033[1m'
else
  color_reset=''
  color_red=''
  color_green=''
  color_yellow=''
  color_blue=''
  color_bold=''
fi

log_info() {
  printf '%s[info]%s %s\n' "$color_blue" "$color_reset" "$1"
}

log_success() {
  printf '%s[ok]%s %s\n' "$color_green" "$color_reset" "$1"
}

log_warn() {
  printf '%s[warn]%s %s\n' "$color_yellow" "$color_reset" "$1"
}

log_error() {
  printf '%s[error]%s %s\n' "$color_red" "$color_reset" "$1" >&2
}

usage() {
  cat <<'EOF'
Usage:
  ./scripts/sync-public-web.sh <project>
  ./scripts/sync-public-web.sh --list

Convention:
  <project> maps to <PROJECT>_PUBLIC_WEB_PATH in .env
  Example: project-name -> PROJECT_NAME_PUBLIC_WEB_PATH
EOF
}

require_env_file() {
  if [[ ! -f "$env_file" ]]; then
    log_error "Missing .env file at $env_file"
    exit 1
  fi
}

load_env() {
  require_env_file
  set -a
  # shellcheck disable=SC1090
  source "$env_file"
  set +a
}

project_to_env_key() {
  local project=$1

  echo "${project^^}" | tr -- '-./' '___'
}

list_projects() {
  require_env_file
  awk -F= '/^[A-Z0-9_]+_PUBLIC_WEB_PATH=/{print $1}' "$env_file" \
    | sed 's/_PUBLIC_WEB_PATH$//' \
    | tr 'A-Z' 'a-z' \
    | tr '_' '-'
}

sync_project() {
  local project=$1
  local env_prefix env_key source_dir destination_dir

  env_prefix=$(project_to_env_key "$project")
  env_key="${env_prefix}_PUBLIC_WEB_PATH"

  load_env

  source_dir=${!env_key:-}
  if [[ -z "$source_dir" ]]; then
    log_error "Missing $env_key in $env_file"
    exit 1
  fi

  if [[ ! -d "$source_dir" ]]; then
    log_error "Source directory does not exist: $source_dir"
    exit 1
  fi

  destination_dir="$repo_root/$project"
  if [[ "$destination_dir" == "$repo_root" ]]; then
    log_error "Refusing to sync into repo root"
    exit 1
  fi

  log_info "Syncing ${color_bold}$project${color_reset}"
  log_info "Source: $source_dir"
  log_info "Destination: $destination_dir"

  mkdir -p "$destination_dir"

  if command -v rsync >/dev/null 2>&1; then
    log_info "Using rsync mirror mode"
    rsync -a --delete "$source_dir/" "$destination_dir/"
  else
    log_warn "rsync not found, falling back to cp"
    rm -rf "$destination_dir"
    mkdir -p "$destination_dir"
    cp -R "$source_dir/." "$destination_dir/"
  fi

  log_success "Synced $project"
}

main() {
  if [[ $# -ne 1 ]]; then
    usage >&2
    exit 1
  fi

  case "$1" in
    --list)
      list_projects
      ;;
    -h|--help)
      usage
      ;;
    *)
      sync_project "$1"
      ;;
  esac
}

main "$@"