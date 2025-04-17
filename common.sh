#!/bin/zsh
# 공통 유틸리티 함수 및 변수 (common.sh)

# Colors for output
typeset -A colors
colors=(
  [red]=$'\033[0;31m'
  [green]=$'\033[0;32m'
  [yellow]=$'\033[0;33m'
  [blue]=$'\033[0;34m'
  [nc]=$'\033[0m'
)

# State tracking
typeset -A STATE
STATE_FILE="${HOME}/.bootstrap_state"
[[ -f ${STATE_FILE} ]] && source ${STATE_FILE}

# Log functions
function log_info() {
  echo -e "${colors[blue]}[INFO]${colors[nc]} $1"
}

function log_success() {
  echo -e "${colors[green]}[SUCCESS]${colors[nc]} $1"
}

function log_warning() {
  echo -e "${colors[yellow]}[WARNING]${colors[nc]} $1"
}

function log_error() {
  echo -e "${colors[red]}[ERROR]${colors[nc]} $1"
}

# Save state after each successful operation
function save_state() {
  local key=$1
  local value=${2:-"done"}
  STATE[$key]=$value

  # Save state to file
  typeset -p STATE > ${STATE_FILE}
  chmod 600 ${STATE_FILE}
}

# Check if a state has been completed
function is_completed() {
  [[ -n ${STATE[$1]} ]]
  return $?
}

# Check OS
function check_os() {
  local os=${$(uname):-"Unknown"}
  log_info "Detected OS: $os"

  if [[ $os != "Darwin" ]]; then
    log_error "This script is only for macOS. Exiting."
    exit 1
  fi

  save_state "check_os"
}

# Function to create/update configuration with backup
function update_config_file() {
  local file=$1
  local marker=$2
  local content=$3

  # Create directory if needed
  [[ -d ${file:h} ]] || mkdir -p ${file:h}

  # Create backup if file exists
  if [[ -f $file ]]; then
    cp $file ${file}.bak.$(date +%Y%m%d%H%M%S)
  fi

  # Only add configuration if not already present
  if [[ -f $file ]] && grep -q "$marker" $file; then
    log_success "Configuration for $marker already exists in $file"
    return 0
  fi

  log_info "Adding $marker configuration to $file..."
  echo "" >> $file
  echo "# $marker" >> $file
  echo $content >> $file
  log_success "$marker configuration added to $file"
  return 0
}
