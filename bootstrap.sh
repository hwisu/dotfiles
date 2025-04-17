#!/bin/zsh
# 메인 부트스트랩 스크립트 (bootstrap.sh)
# 이 스크립트는 macOS 환경 설정을 자동화합니다.

# 현재 디렉토리 기억
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# 모듈 import
source "$SCRIPT_DIR/common.sh"
source "$SCRIPT_DIR/brew_utils.sh"
source "$SCRIPT_DIR/gui_apps.sh"
source "$SCRIPT_DIR/dev_tools.sh"
source "$SCRIPT_DIR/shell_tools.sh"
source "$SCRIPT_DIR/setup-cursor-extensions.sh"
source "$SCRIPT_DIR/setup-nvim.sh"

# Main function with parallel execution and better state tracking
function main() {
  # Only run OS check if not already done
  is_completed "check_os" || check_os
  ensure_homebrew

  log_info "Starting installation of applications..."

  # 앱 설치 함수 목록
  typeset -a app_installations=(
    "install_cursor"
    "install_nvim"
    "install_1password"
    "install_fira_code_nerd_font"
    "install_iterm2"
    "install_docker"
  )

  # 이미 완료된 작업은 건너뛰고 병렬 설치
  typeset -a pids
  for install_func in "${app_installations[@]}"; do
    # 함수 이름에서 패키지 이름 추출
    local pkg_name="${install_func#install_}"
    local state_key="brew_${pkg_name//[^a-zA-Z0-9]/_}"

    # 아직 설치되지 않은 경우에만 설치
    if ! is_completed $state_key; then
      $install_func &
      pids+=($!)
    fi
  done

  # 병렬 프로세스가 있다면 기다리기
  [[ ${#pids[@]} -gt 0 ]] && wait $pids
  log_info "Base applications installation completed"

  # 쉘 도구 및 설정 순차 설치 (병렬 실행 시 .zshrc 충돌 방지)
  log_info "Setting up shell tools and configurations..."
  install_starship
  install_zinit
  install_fzf
  install_node_tools
  install_dev_tools

  # 설정 설치
  log_info "Setting up configurations..."
  setup_git
  setup_editor
  setup_nvim
  setup_cursor_extensions

  log_info "====================================================="
  log_info "Bootstrap completed!"
  log_info "To apply all changes, restart your terminal or run:"
  log_info "source ~/.zshrc"
  log_info "====================================================="
}

# Run the main function
main

