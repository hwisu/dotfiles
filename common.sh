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

# Security enhancement functions

# Compare two version strings (like 0.8.3 and 0.7.2)
# Returns: 0 if equal, 1 if v1 > v2, 2 if v1 < v2
function version_compare() {
  local v1=$1
  local v2=$2

  # 버전 문자열이 비어있는 경우 처리
  [[ -z "$v1" ]] && v1="0.0.0"
  [[ -z "$v2" ]] && v2="0.0.0"

  # 버전을 숫자 배열로 변환
  local a1=(${(s:.:)v1})
  local a2=(${(s:.:)v2})

  # 배열 길이 계산
  local len1=${#a1[@]}
  local len2=${#a2[@]}
  local max_len=$((len1 > len2 ? len1 : len2))

  # 각 버전 부분 비교
  for ((i=1; i<=max_len; i++)); do
    local num1=$((i <= len1 ? a1[i] : 0))
    local num2=$((i <= len2 ? a2[i] : 0))

    if (( num1 > num2 )); then
      return 1
    elif (( num1 < num2 )); then
      return 2
    fi
  done

  # 모든 부분이 동일하면 버전이 같음
  return 0
}

# Execute commands with sudo safely with user confirmation
function safe_sudo() {
  local cmd="$*"

  log_warning "다음 명령을 실행하기 위해 관리자 권한이 필요합니다:"
  echo "  $ sudo $cmd"
  log_warning "이 작업은 시스템에 변경사항을 만들 수 있습니다."

  read -p "계속 진행하시겠습니까? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo $cmd
    return $?
  fi

  log_warning "작업이 취소되었습니다."
  return 1
}

# Verify file integrity using checksum
function verify_checksum() {
  local file=$1
  local expected_hash=$2
  local hash_type=${3:-"sha256"}

  if [[ ! -f "$file" ]]; then
    log_error "파일이 존재하지 않습니다: $file"
    return 1
  fi

  local actual_hash
  case $hash_type in
    sha256)
      actual_hash=$(shasum -a 256 "$file" | cut -d ' ' -f1)
      ;;
    md5)
      actual_hash=$(md5 -q "$file")
      ;;
    *)
      log_error "지원하지 않는 해시 타입입니다: $hash_type"
      return 1
      ;;
  esac

  if [[ "$actual_hash" != "$expected_hash" ]]; then
    log_error "체크섬이 일치하지 않습니다!"
    log_error "예상: $expected_hash"
    log_error "실제: $actual_hash"
    return 1
  fi

  log_success "파일 무결성 검증 완료: $file"
  return 0
}

# Set secure file permissions
function set_secure_permissions() {
  local path=$1
  local type=$2  # "file" 또는 "directory"

  if [[ ! -e "$path" ]]; then
    log_error "경로가 존재하지 않습니다: $path"
    return 1
  fi

  case $type in
    file)
      # 파일: 소유자만 읽기/쓰기 가능 (600)
      chmod 600 "$path"
      ;;
    directory)
      # 디렉토리: 소유자만 읽기/쓰기/실행 가능 (700)
      chmod 700 "$path"
      ;;
    executable)
      # 실행 파일: 소유자만 읽기/쓰기/실행 가능 (700)
      chmod 700 "$path"
      ;;
    *)
      log_error "알 수 없는 타입입니다: $type"
      return 1
      ;;
  esac

  # 소유자 확인
  if [[ $(stat -f %u "$path") != $(id -u) ]]; then
    safe_sudo "chown $(id -u):$(id -g) '$path'"
  fi

  log_success "보안 권한 설정 완료: $path"
  return 0
}

# Safely clone a git repository with integrity check
function secure_git_clone() {
  local repo_url=$1
  local target_dir=$2
  local branch=${3:-"HEAD"}
  local expected_commit=${4:-""}

  log_info "저장소 클론 중: $repo_url"

  # Clone with specific branch if provided
  if [[ "$branch" != "HEAD" ]]; then
    git clone --branch "$branch" "$repo_url" "$target_dir"
  else
    git clone "$repo_url" "$target_dir"
  fi

  if [[ $? -ne 0 ]]; then
    log_error "저장소 클론 실패: $repo_url"
    return 1
  fi

  # Verify commit hash if provided
  if [[ -n "$expected_commit" ]]; then
    local actual_commit=$(cd "$target_dir" && git rev-parse HEAD)
    if [[ "$actual_commit" != "$expected_commit" ]]; then
      log_error "커밋 해시가 일치하지 않습니다!"
      log_error "예상: $expected_commit"
      log_error "실제: $actual_commit"
      rm -rf "$target_dir"
      return 1
    fi
    log_success "저장소 무결성 검증 완료"
  fi

  return 0
}
