#!/bin/zsh
# Neovim 설정 및 플러그인 설치 스크립트 - 멱등적 실행 지원

# 현재 디렉토리 기억
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# 공통 유틸리티 로드
source "$SCRIPT_DIR/common.sh"

# Neovim 확인 및 설치
check_and_install_neovim() {
  if ! command -v nvim &> /dev/null; then
    log_info "Neovim이 설치되어 있지 않습니다. 설치를 시도합니다."

    if [[ "$(uname)" == "Darwin" ]]; then
      if command -v brew &> /dev/null; then
        brew install neovim
      else
        log_error "Homebrew가 설치되어 있지 않습니다. Neovim을 설치할 수 없습니다."
        exit 1
      fi
    elif [[ "$(uname)" == "Linux" ]]; then
      if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y neovim
      elif command -v dnf &> /dev/null; then
        sudo dnf install -y neovim
      else
        log_error "지원되는 패키지 관리자를 찾을 수 없습니다."
        exit 1
      fi
    else
      log_error "지원되지 않는 OS입니다."
      exit 1
    fi

    log_success "Neovim 설치 완료!"
  else
    log_info "Neovim이 이미 설치되어 있습니다. 버전: $(nvim --version | head -n 1)"
  fi
}

# 폰트 설치 (macOS)
install_nerd_font() {
  if [[ "$(uname)" == "Darwin" ]]; then
    if ! command -v brew &> /dev/null; then
      log_error "Homebrew가 필요합니다. https://brew.sh에서 설치해주세요."
      return 1
    fi

    log_info "FiraCode Nerd Font 설치 중..."
    brew install --cask font-fira-code-nerd-font
    log_success "FiraCode Nerd Font 설치 완료!"
  else
    log_warning "자동 폰트 설치는 macOS에서만 지원됩니다."
    log_info "다음 URL에서 FiraCode Nerd Font를 수동으로 설치해주세요: https://www.nerdfonts.com/font-downloads"
  fi
}

# Git 확인
check_git() {
  if ! command -v git &> /dev/null; then
    log_error "Git이 설치되어 있지 않습니다. Git은 플러그인 설치에 필요합니다."
    exit 1
  fi
}

# ripgrep 설치 (Telescope 검색용)
install_ripgrep() {
  if ! command -v rg &> /dev/null; then
    log_info "ripgrep 설치 중..."

    if [[ "$(uname)" == "Darwin" ]]; then
      if command -v brew &> /dev/null; then
        brew install ripgrep
      fi
    elif [[ "$(uname)" == "Linux" ]]; then
      if command -v apt &> /dev/null; then
        sudo apt install -y ripgrep
      elif command -v dnf &> /dev/null; then
        sudo dnf install -y ripgrep
      fi
    fi

    log_success "ripgrep 설치 완료!"
  else
    log_info "ripgrep이 이미 설치되어 있습니다."
  fi
}

# Neovim 설정 디렉토리 생성
setup_nvim_config_dir() {
  local NVIM_CONFIG_DIR="${HOME}/.config/nvim"

  if [[ ! -d "$NVIM_CONFIG_DIR" ]]; then
    log_info "Neovim 설정 디렉토리 생성 중..."
    mkdir -p "$NVIM_CONFIG_DIR"
    log_success "디렉토리 생성 완료: $NVIM_CONFIG_DIR"
  fi

  # init.lua가 이미 존재하면 백업
  if [[ -f "$NVIM_CONFIG_DIR/init.lua" ]]; then
    BACKUP_FILE="$NVIM_CONFIG_DIR/init.lua.bak.$(date +%Y%m%d%H%M%S)"
    log_info "기존 init.lua 파일 백업 중: $BACKUP_FILE"
    cp "$NVIM_CONFIG_DIR/init.lua" "$BACKUP_FILE"
    log_success "백업 완료"
  fi

  # 새 init.lua 생성/복사
  if [[ -f "$SCRIPT_DIR/init.lua" ]]; then
    log_info "init.lua 파일을 Neovim 설정 디렉토리로 복사 중..."
    cp "$SCRIPT_DIR/init.lua" "$NVIM_CONFIG_DIR/init.lua"
    log_success "init.lua 설치 완료"
  else
    log_error "스크립트 디렉토리에 init.lua 파일이 없습니다."
    exit 1
  fi
}

# 메인 스크립트
setup_nvim() {
  log_info "Neovim 설정 및 플러그인 설치 스크립트를 시작합니다."

  # 이미 완료된 경우 건너뛰기
  if is_completed "nvim_setup_completed"; then
    log_success "Neovim 설정이 이미 완료되어 있습니다."
    return 0
  fi

  check_and_install_neovim
  check_git
  install_nerd_font
  install_ripgrep
  setup_nvim_config_dir

  log_success "Neovim 설정이 완료되었습니다!"
  log_info "Neovim을 실행하면 자동으로 lazy.nvim과 플러그인이 설치됩니다."
  log_info "첫 실행 시 플러그인 설치가 진행되므로 잠시 기다려 주세요."

  save_state "nvim_setup_completed"
}

# 직접 실행된 경우에만 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_nvim
fi
