#!/bin/zsh
# Neovim 설정 및 플러그인 설치 스크립트 - 멱등적 실행 지원

# 현재 디렉토리 기억
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# 공통 유틸리티 로드
source "$SCRIPT_DIR/common.sh"

# Neovim 버전 확인 (보안 취약점 CVE GHSA-6f9m-hj8h-xjgj 대응)
check_nvim_security() {
  local min_secure_version="0.8.3"

  if command -v nvim &> /dev/null; then
    # 버전 문자열 추출 및 정리 (v0.11.0 → 0.11.0)
    local version_output=$(nvim --version | head -n1)
    local current_version=$(echo "$version_output" | awk '{print $2}' | sed 's/^v//')

    log_info "감지된 Neovim 버전: $current_version"

    # 버전 형식 확인
    if [[ ! "$current_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      log_warning "Neovim 버전 형식을 파싱할 수 없습니다: $version_output"
      log_warning "버전 정보를 사용할 수 없어 보안 검사를 건너뜁니다."
      return 0
    fi

    version_compare "$current_version" "$min_secure_version"
    local result=$?

    if [[ $result -eq 2 ]]; then
      log_error "보안 취약점 (GHSA-6f9m-hj8h-xjgj) 위험이 있는 Neovim 버전입니다."
      log_error "현재 버전: $current_version, 필요 버전: $min_secure_version 이상"
      log_warning "Treesitter 코드 삽입 취약점이 존재합니다."
      log_info "Neovim을 업그레이드하시겠습니까?"

      read -p "업그레이드 진행? (y/N) " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v brew &> /dev/null; then
          brew upgrade neovim

          # 업그레이드 후 버전 다시 확인
          version_output=$(nvim --version | head -n1)
          current_version=$(echo "$version_output" | awk '{print $2}' | sed 's/^v//')
          version_compare "$current_version" "$min_secure_version"
          result=$?

          if [[ $result -eq 2 ]]; then
            log_error "Neovim 업그레이드 후에도 여전히 취약한 버전입니다."
            log_error "수동으로 최신 버전을 설치해주세요: https://github.com/neovim/neovim/releases"
            return 1
          else
            log_success "Neovim이 안전한 버전으로 업그레이드되었습니다: $current_version"
          fi
        else
          log_error "Homebrew가 설치되어 있지 않아 자동 업그레이드가 불가능합니다."
          log_error "수동으로 최신 버전을 설치해주세요: https://github.com/neovim/neovim/releases"
          return 1
        fi
      else
        log_warning "보안 취약점이 있는 버전을 계속 사용합니다. 주의하세요!"
      fi
    elif [[ $result -eq 0 || $result -eq 1 ]]; then
      log_success "Neovim 버전($current_version)이 알려진 보안 취약점으로부터 안전합니다."
    fi
  fi
}

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
        safe_sudo "apt update && apt install -y neovim"
      elif command -v dnf &> /dev/null; then
        safe_sudo "dnf install -y neovim"
      else
        log_error "지원되는 패키지 관리자를 찾을 수 없습니다."
        exit 1
      fi
    else
      log_error "지원되지 않는 OS입니다."
      exit 1
    fi

    # 설치 성공 여부 확인
    if ! command -v nvim &> /dev/null; then
      log_error "Neovim 설치에 실패했습니다."
      return 1
    fi

    log_success "Neovim 설치 완료!"

    # 설치 후 보안 버전 확인
    check_nvim_security
  else
    log_info "Neovim이 이미 설치되어 있습니다. 버전: $(nvim --version | head -n 1)"
    # 기존 설치에 대한 보안 버전 확인
    check_nvim_security
  fi

  return 0
}

# 폰트 설치 (macOS)
install_nerd_font() {
  if [[ "$(uname)" == "Darwin" ]]; then
    if ! command -v brew &> /dev/null; then
      log_error "Homebrew가 필요합니다. https://brew.sh에서 설치해주세요."
      return 1
    fi

    # 이미 설치되어 있는지 확인
    if brew list --cask font-fira-code-nerd-font &>/dev/null; then
      log_info "FiraCode Nerd Font가 이미 설치되어 있습니다."
      return 0
    fi

    log_info "FiraCode Nerd Font 설치 중..."
    brew tap homebrew/cask-fonts
    brew install --cask font-fira-code-nerd-font

    # 설치 확인
    if ! brew list --cask font-fira-code-nerd-font &>/dev/null; then
      log_error "FiraCode Nerd Font 설치에 실패했습니다."
      return 1
    fi

    log_success "FiraCode Nerd Font 설치 완료!"
  else
    log_warning "자동 폰트 설치는 macOS에서만 지원됩니다."
    log_info "다음 URL에서 FiraCode Nerd Font를 수동으로 설치해주세요: https://www.nerdfonts.com/font-downloads"
  fi

  return 0
}

# Git 확인
check_git() {
  if ! command -v git &> /dev/null; then
    log_error "Git이 설치되어 있지 않습니다. Git은 플러그인 설치에 필요합니다."

    # macOS에서 자동 설치 시도
    if [[ "$(uname)" == "Darwin" ]] && command -v brew &> /dev/null; then
      log_info "Git 설치를 시도합니다..."
      brew install git

      if ! command -v git &> /dev/null; then
        log_error "Git 설치에 실패했습니다."
        exit 1
      fi

      log_success "Git 설치 완료!"
    else
      exit 1
    fi
  fi

  # Git 버전 확인
  local git_version=$(git --version | awk '{print $3}')
  log_info "Git 버전: $git_version"

  return 0
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
        safe_sudo "apt install -y ripgrep"
      elif command -v dnf &> /dev/null; then
        safe_sudo "dnf install -y ripgrep"
      fi
    fi

    # 설치 확인
    if ! command -v rg &> /dev/null; then
      log_error "ripgrep 설치에 실패했습니다."
      return 1
    fi

    log_success "ripgrep 설치 완료!"
  else
    log_info "ripgrep이 이미 설치되어 있습니다."
  fi

  return 0
}

# lazy.nvim 보안 설치
secure_install_lazy_nvim() {
  local lazypath="$HOME/.local/share/nvim/lazy/lazy.nvim"

  if [[ -d "$lazypath" ]]; then
    log_info "lazy.nvim이 이미 설치되어 있습니다."
    return 0
  fi

  log_info "lazy.nvim 설치 중..."

  # 디렉토리 경로 확인
  local parent_dir=$(dirname "$lazypath")
  if [[ ! -d "$parent_dir" ]]; then
    mkdir -p "$parent_dir"
  fi

  # 임시 디렉토리 생성 및 깃 클론
  local repo_url="https://github.com/folke/lazy.nvim.git"
  local branch="stable"

  # 저장소 클론 (무결성 검증은 실제 프로덕션 환경에서 특정 커밋 해시 사용)
  secure_git_clone "$repo_url" "$lazypath" "$branch"

  if [[ $? -eq 0 ]]; then
    log_success "lazy.nvim 설치 완료!"
    # 디렉토리 권한 설정
    set_secure_permissions "$lazypath" "directory"
    return 0
  else
    log_error "lazy.nvim 설치 실패!"
    return 1
  fi
}

# Neovim 설정 디렉토리 생성
setup_nvim_config_dir() {
  local NVIM_CONFIG_DIR="${HOME}/.config/nvim"

  if [[ ! -d "$NVIM_CONFIG_DIR" ]]; then
    log_info "Neovim 설정 디렉토리 생성 중..."
    mkdir -p "$NVIM_CONFIG_DIR"
    # 보안 권한 설정
    set_secure_permissions "$NVIM_CONFIG_DIR" "directory"
    log_success "디렉토리 생성 완료: $NVIM_CONFIG_DIR"
  fi

  # init.lua가 이미 존재하면 백업
  if [[ -f "$NVIM_CONFIG_DIR/init.lua" ]]; then
    local BACKUP_FILE="$NVIM_CONFIG_DIR/init.lua.bak.$(date +%Y%m%d%H%M%S)"
    log_info "기존 init.lua 파일 백업 중: $BACKUP_FILE"
    cp "$NVIM_CONFIG_DIR/init.lua" "$BACKUP_FILE"
    # 보안 권한 설정
    set_secure_permissions "$BACKUP_FILE" "file"
    log_success "백업 완료"
  fi

  # 새 init.lua 생성/복사
  if [[ -f "$SCRIPT_DIR/init.lua" ]]; then
    log_info "init.lua 파일을 Neovim 설정 디렉토리로 복사 중..."
    cp "$SCRIPT_DIR/init.lua" "$NVIM_CONFIG_DIR/init.lua"
    # 보안 권한 설정
    set_secure_permissions "$NVIM_CONFIG_DIR/init.lua" "file"
    log_success "init.lua 설치 완료"
  else
    log_error "스크립트 디렉토리에 init.lua 파일이 없습니다."
    return 1
  fi

  return 0
}

# 메인 스크립트
setup_nvim() {
  log_info "Neovim 설정 및 플러그인 설치 스크립트를 시작합니다."

  # 이미 완료된 경우 건너뛰기
  if is_completed "nvim_setup_completed"; then
    log_success "Neovim 설정이 이미 완료되어 있습니다."

    # 보안 버전 확인은 항상 수행
    check_nvim_security
    return 0
  fi

  local setup_success=true

  # 각 단계별 실행 및 오류 처리
  check_and_install_neovim || setup_success=false

  if [[ "$setup_success" == "true" ]]; then
    check_git || setup_success=false
  fi

  if [[ "$setup_success" == "true" ]]; then
    install_nerd_font || log_warning "폰트 설치에 문제가 있을 수 있습니다. 계속 진행합니다."
  fi

  if [[ "$setup_success" == "true" ]]; then
    install_ripgrep || log_warning "ripgrep 설치에 문제가 있을 수 있습니다. 계속 진행합니다."
  fi

  if [[ "$setup_success" == "true" ]]; then
    secure_install_lazy_nvim || setup_success=false
  fi

  if [[ "$setup_success" == "true" ]]; then
    setup_nvim_config_dir || setup_success=false
  fi

  if [[ "$setup_success" == "true" ]]; then
    log_success "Neovim 설정이 완료되었습니다!"
    log_info "Neovim을 실행하면 자동으로 lazy.nvim과 플러그인이 설치됩니다."
    log_info "첫 실행 시 플러그인 설치가 진행되므로 잠시 기다려 주세요."

    save_state "nvim_setup_completed"
  else
    log_error "Neovim 설정 중 오류가 발생했습니다. 로그를 확인하여 문제를 해결해주세요."
    return 1
  fi

  return 0
}

# 직접 실행된 경우에만 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_nvim
fi
