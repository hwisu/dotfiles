#!/bin/zsh
# Cursor 에디터 확장 프로그램 설치 스크립트 - 이미지에 보이는 확장 기능 설치 (Unity 제외)

# 현재 디렉토리 기억
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# 공통 유틸리티 로드
source "$SCRIPT_DIR/common.sh"

# Cursor CLI 명령어 확인
check_cursor_cli() {
  if ! command -v cursor &> /dev/null; then
    log_warning "Cursor CLI를 찾을 수 없습니다."

    # macOS에서 Cursor CLI 심볼릭 링크 생성 시도
    if [[ "$(uname)" == "Darwin" ]]; then
      if [[ -f "/Applications/Cursor.app/Contents/MacOS/Cursor" ]]; then
        log_info "Cursor 앱을 찾았습니다. CLI 심볼릭 링크를 생성합니다."
        sudo ln -sf "/Applications/Cursor.app/Contents/MacOS/Cursor" /usr/local/bin/cursor
        log_success "Cursor CLI 심볼릭 링크가 생성되었습니다."
      else
        log_error "Cursor 앱을 찾을 수 없습니다. Cursor가 설치되어 있는지 확인해주세요."
        exit 1
      fi
    else
      log_error "Cursor CLI를 찾을 수 없습니다. Cursor가 설치되어 있고 PATH에 추가되어 있는지 확인하세요."
      exit 1
    fi
  fi
}

# 확장 프로그램 설치
install_extensions() {
  local extensions=(
    "haskell.haskell"
    "justusadam.language-haskell"
    "hoovercj.haskell-linter"
    "qufiwefefwoyn.kanagawa"
    "mechatroner.rainbow-csv"
    "alexcvzz.vscode-sqlite"
    "asvetliakov.vscode-neovim"
  )

  log_info "확장 프로그램 설치를 시작합니다..."

  for ext in "${extensions[@]}"; do
    log_info "설치 중: $ext"
    cursor --install-extension "$ext" || log_warning "설치 실패: $ext"
  done

  log_success "확장 프로그램 설치가 완료되었습니다!"
  save_state "cursor_extensions_installed"
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
    exit 1
  fi

  log_info "확장 프로그램 디렉토리: $EXTENSIONS_DIR"
  log_info "Cursor를 실행하고 다음 확장 프로그램을 직접 설치해주세요:"

  echo -e "${colors[blue]}Haskell${colors[nc]} - haskell.haskell"
  echo -e "${colors[blue]}Haskell Syntax Highlighting${colors[nc]} - justusadam.language-haskell"
  echo -e "${colors[blue]}haskell-linter${colors[nc]} - hoovercj.haskell-linter"
  echo -e "${colors[blue]}Kanagawa${colors[nc]} - qufiwefefwoyn.kanagawa"
  echo -e "${colors[blue]}Rainbow CSV${colors[nc]} - mechatroner.rainbow-csv"
  echo -e "${colors[blue]}SQLite Viewer${colors[nc]} - alexcvzz.vscode-sqlite"
  echo -e "${colors[blue]}VSCode Neovim${colors[nc]} - asvetliakov.vscode-neovim"
}

# 메인 스크립트
setup_cursor_extensions() {
  log_info "Cursor 확장 프로그램 설치 스크립트를 시작합니다."

  # 이미 완료된 경우 건너뛰기
  if is_completed "cursor_extensions_installed"; then
    log_success "Cursor 확장 프로그램이 이미 설치되어 있습니다."
    return 0
  fi

  if check_cursor_cli; then
    install_extensions
  else
    alternative_install
  fi
}

# 직접 실행된 경우에만 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_cursor_extensions
fi
