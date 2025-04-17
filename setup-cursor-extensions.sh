#!/bin/zsh
# Cursor 에디터 확장 프로그램 설치 스크립트 - 이미지에 보이는 확장 기능 설치 (Unity 제외)

# 현재 디렉토리 기억
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# 공통 유틸리티 로드
source "$SCRIPT_DIR/common.sh"

# 신뢰할 수 있는 확장 ID 목록 및 해시 (이상적으로는 확장 패키지 해시를 검증해야 함)
declare -A TRUSTED_EXTENSIONS=(
  ["haskell.haskell"]="Haskell 언어 지원"
  ["justusadam.language-haskell"]="Haskell 구문 강조"
  ["hoovercj.haskell-linter"]="Haskell 린터"
  ["qufiwefefwoyn.kanagawa"]="Kanagawa 테마"
  ["ms-python.python"]="Python 언어 지원"
  ["ms-python.vscode-pylance"]="Python Pylance"
  ["ms-python.debugpy"]="Python 디버거"
  ["mechatroner.rainbow-csv"]="Rainbow CSV"
  ["alexcvzz.vscode-sqlite"]="SQLite 뷰어"
  ["asvetliakov.vscode-neovim"]="VSCode Neovim"
)

# Cursor 설치 여부 확인
check_cursor_installed() {
  if [[ "$(uname)" == "Darwin" ]]; then
    if [[ -d "/Applications/Cursor.app" ]]; then
      return 0
    fi
  elif [[ "$(uname)" == "Linux" ]]; then
    if [[ -d "$HOME/.local/share/Cursor" ]] || [[ -d "/usr/share/cursor" ]]; then
      return 0
    fi
  fi

  log_error "Cursor가 설치되어 있지 않은 것 같습니다."
  log_info "Cursor 앱을 먼저 설치해 주세요: https://cursor.sh"
  return 1
}

# Cursor CLI 명령어 확인
check_cursor_cli() {
  # 먼저 Cursor가 설치되어 있는지 확인
  check_cursor_installed || return 1

  if ! command -v cursor &> /dev/null; then
    log_warning "Cursor CLI를 찾을 수 없습니다."

    # macOS에서 Cursor CLI 심볼릭 링크 생성 시도
    if [[ "$(uname)" == "Darwin" ]]; then
      if [[ -f "/Applications/Cursor.app/Contents/MacOS/Cursor" ]]; then
        log_info "Cursor 앱을 찾았습니다. CLI 심볼릭 링크를 생성합니다."
        safe_sudo "ln -sf '/Applications/Cursor.app/Contents/MacOS/Cursor' /usr/local/bin/cursor"
        log_success "Cursor CLI 심볼릭 링크가 생성되었습니다."
      else
        log_error "Cursor 실행 파일을 찾을 수 없습니다. Cursor가 설치되어 있는지 확인해주세요."
        return 1
      fi
    else
      log_error "Cursor CLI를 찾을 수 없습니다. Cursor가 설치되어 있고 PATH에 추가되어 있는지 확인하세요."
      return 1
    fi
  fi

  # CLI 명령 작동 확인 - 버전 체크로 확인
  if ! cursor --version &> /dev/null; then
    # 다른 방법으로 시도 (일부 버전에서는 --version 대신 -v 사용)
    if ! cursor -v &> /dev/null; then
      log_error "Cursor CLI가 올바르게 작동하지 않습니다."
      return 1
    fi
  fi

  return 0
}

# 확장 프로그램 설치
install_extensions() {
  local extensions=(
    "haskell.haskell"
    "justusadam.language-haskell"
    "hoovercj.haskell-linter"
    "qufiwefefwoyn.kanagawa"
    "ms-python.python"
    "ms-python.vscode-pylance"
    "ms-python.debugpy"
    "mechatroner.rainbow-csv"
    "alexcvzz.vscode-sqlite"
    "asvetliakov.vscode-neovim"
  )

  log_info "확장 프로그램 설치를 시작합니다..."

  # 확장 프로그램 디렉토리 결정
  local extensions_dir=""
  if [[ "$(uname)" == "Darwin" ]]; then
    extensions_dir="${HOME}/.cursor/extensions"
  elif [[ "$(uname)" == "Linux" ]]; then
    extensions_dir="${HOME}/.config/Cursor/extensions"
  else
    log_error "지원되지 않는 운영체제입니다."
    return 1
  fi

  # 확장 디렉토리 생성 및 권한 설정
  if [[ ! -d "$extensions_dir" ]]; then
    mkdir -p "$extensions_dir"
  fi

  if [[ -d "$extensions_dir" ]]; then
    set_secure_permissions "$extensions_dir" "directory"
  else
    log_warning "확장 프로그램 디렉토리를 생성할 수 없습니다: $extensions_dir"
    log_info "수동으로 확장을 설치해야 할 수 있습니다."
  fi

  # 설치 성공 여부 추적
  local install_success=0
  local install_failures=0

  # 각 확장 프로그램 확인 및 설치
  for ext in "${extensions[@]}"; do
    # 확장 ID가 신뢰할 수 있는 목록에 있는지 확인
    if [[ -z "${TRUSTED_EXTENSIONS[$ext]}" ]]; then
      log_warning "알 수 없는 확장 ID: $ext - 설치를 건너뜁니다."
      continue
    fi

    # 이미 설치되어 있는지 확인
    local ext_dir="${extensions_dir}/${ext}"
    if [[ -d "$ext_dir" ]]; then
      log_info "확장 프로그램이 이미 설치되어 있습니다: $ext"
      ((install_success++))
      continue
    fi

    log_info "설치 중: $ext (${TRUSTED_EXTENSIONS[$ext]})"
    # 초기 설치 시도 시 출력을 숨기지 않음 (오류 확인을 위해)
    cursor --install-extension "$ext"

    if [[ $? -ne 0 ]]; then
      log_warning "설치 실패: $ext"
      ((install_failures++))

      # 설치 실패 시 다시 시도
      log_info "다시 시도 중: $ext"
      cursor --install-extension "$ext"

      if [[ $? -ne 0 ]]; then
        log_warning "재시도 후에도 설치 실패: $ext"
      else
        log_success "재시도 설치 성공: $ext"
        ((install_success++))

        # 확장 폴더가 존재하면 권한 설정
        if [[ -d "$ext_dir" ]]; then
          set_secure_permissions "$ext_dir" "directory"
        fi
      fi
    else
      log_success "설치 완료: $ext"
      ((install_success++))

      # 확장 폴더가 존재하면 권한 설정
      if [[ -d "$ext_dir" ]]; then
        set_secure_permissions "$ext_dir" "directory"
      fi
    fi
  done

  if [[ $install_failures -eq 0 ]]; then
    log_success "모든 확장 프로그램 설치가 완료되었습니다! ($install_success/${#extensions[@]})"
    save_state "cursor_extensions_installed"
    return 0
  elif [[ $install_success -gt 0 ]]; then
    log_warning "일부 확장 프로그램만 설치되었습니다. ($install_success/${#extensions[@]})"
    if [[ $install_success -ge $((${#extensions[@]} / 2)) ]]; then
      log_info "과반수 이상의 확장이 설치되어 진행 상태를 저장합니다."
      save_state "cursor_extensions_installed"
      return 0
    fi
    return 1
  else
    log_error "모든 확장 프로그램 설치에 실패했습니다."
    return 1
  fi
}

# 대체 설치 방법 (Cursor CLI가 작동하지 않는 경우)
alternative_install() {
  local EXTENSIONS_DIR

  if [[ "$(uname)" == "Darwin" ]]; then
    EXTENSIONS_DIR="${HOME}/.cursor/extensions"
  elif [[ "$(uname)" == "Linux" ]]; then
    EXTENSIONS_DIR="${HOME}/.config/Cursor/extensions"
  else
    log_error "지원되지 않는 운영체제입니다."
    return 1
  fi

  # 폴더가 없으면 생성 및 적절한 권한 설정
  if [[ ! -d "$EXTENSIONS_DIR" ]]; then
    mkdir -p "$EXTENSIONS_DIR"
    set_secure_permissions "$EXTENSIONS_DIR" "directory"
  fi

  log_info "확장 프로그램 디렉토리: $EXTENSIONS_DIR"
  log_info "Cursor를 실행하고 다음 확장 프로그램을 직접 설치해주세요:"

  # 확장 프로그램 목록 출력 (신뢰할 수 있는 목록만)
  for ext_id in "${!TRUSTED_EXTENSIONS[@]}"; do
    echo -e "${colors[blue]}${TRUSTED_EXTENSIONS[$ext_id]}${colors[nc]} - $ext_id"
  done

  log_warning "확장 프로그램 수동 설치 후 다음 명령어를 실행하여 설치 상태를 기록하세요:"
  echo "  source $SCRIPT_DIR/common.sh && save_state cursor_extensions_installed"

  return 1
}

# 메인 스크립트
setup_cursor_extensions() {
  log_info "Cursor 확장 프로그램 설치 스크립트를 시작합니다."

  # 이미 완료된 경우 건너뛰기
  if is_completed "cursor_extensions_installed"; then
    log_success "Cursor 확장 프로그램이 이미 설치되어 있습니다."
    return 0
  fi

  # Cursor 설치 확인
  if ! check_cursor_installed; then
    log_error "Cursor 앱이 설치되어 있지 않아 확장 프로그램을 설치할 수 없습니다."
    log_info "Cursor 앱을 먼저 설치한 후 다시 시도해주세요: https://cursor.sh"
    return 1
  fi

  # Cursor CLI 확인
  if check_cursor_cli; then
    install_extensions
    local result=$?
    if [[ $result -eq 0 ]]; then
      log_success "Cursor 확장 프로그램 설치가 완료되었습니다."
      return 0
    else
      log_warning "자동 설치에 문제가 있어 수동 설치 방법을 안내합니다."
      alternative_install
      return 1
    fi
  else
    log_warning "CLI 도구를 사용할 수 없어 수동 설치 방법을 안내합니다."
    alternative_install
    return 1
  fi
}

# 직접 실행된 경우에만 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_cursor_extensions
fi
