#!/bin/zsh
# Homebrew 관련 유틸리티 함수 (brew_utils.sh)

# Import common utilities
source "$(dirname "$0")/common.sh"

# Check if Homebrew is installed, install if not
function ensure_homebrew() {
  if is_completed "homebrew"; then
    log_success "Homebrew previously installed and configured"
    return 0
  fi

  log_info "Checking for Homebrew..."
  if (( ! $+commands[brew] )); then
    log_warning "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"

      # Only add to zprofile if not already present
      if ! grep -q "brew shellenv" ~/.zprofile; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
      fi

      log_success "Homebrew installed and added to PATH"
    else
      eval "$(/usr/local/bin/brew shellenv)"
      log_success "Homebrew installed"
    fi
  else
    log_success "Homebrew already installed"
  fi

  # Update Homebrew
  log_info "Updating Homebrew..."
  brew update

  save_state "homebrew"
}

# Install package function with error handling and idempotency
function install_brew_package() {
  local package=$1
  local is_cask=${2:-false}
  local state_key="brew_${package//[^a-zA-Z0-9]/_}"
  local cmd_name=${3:-$package}
  local app_name=${4:-$package}  # 앱 이름 (앱 폴더 확인용)

  # 이미 상태가 저장되어 있는지 확인
  if is_completed $state_key; then
    log_success "$package previously installed"
    return 0
  fi

  # 명령어가 이미 존재하는지 확인 (brew 외 설치 포함)
  if ! $is_cask && command -v $cmd_name &>/dev/null; then
    log_success "$package already installed (detected in PATH)"
    save_state $state_key
    return 0
  fi

  # brew로 설치되었는지 확인
  if $is_cask; then
    if brew list --cask $package &>/dev/null 2>&1; then
      log_success "$package already installed via Homebrew"
      save_state $state_key
      return 0
    fi
  else
    if brew list $package &>/dev/null 2>&1; then
      log_success "$package already installed via Homebrew"
      save_state $state_key
      return 0
    fi
  fi

  # 앱이 설치되어 있는지 확인 (Cask 앱용)
  if $is_cask; then
    # 다양한 가능한 앱 위치 및 이름 형식 확인
    local possible_app_locations=(
      "/Applications/${app_name}.app"
      "/Applications/${app_name/ /\ }.app"  # 공백 유지
      "/Applications/${package}.app"
      "/Applications/${cmd_name}.app"
      "/Applications/${app_name/-/ }.app"  # 하이픈을 공백으로
      "$HOME/Applications/${app_name}.app"
      "$HOME/Applications/${package}.app"
      "$HOME/Applications/${cmd_name}.app"
    )

    # 대문자 변환 (zsh 호환)
    local app_name_capitalized=$(echo ${app_name:0:1} | tr '[:lower:]' '[:upper:]')${app_name:1}
    local package_capitalized=$(echo ${package:0:1} | tr '[:lower:]' '[:upper:]')${package:1}
    local cmd_name_capitalized=$(echo ${cmd_name:0:1} | tr '[:lower:]' '[:upper:]')${cmd_name:1}

    # 대문자 변형 추가
    possible_app_locations+=(
      "/Applications/${app_name_capitalized}.app"
      "/Applications/${package_capitalized}.app"
      "/Applications/${cmd_name_capitalized}.app"
      "$HOME/Applications/${app_name_capitalized}.app"
      "$HOME/Applications/${package_capitalized}.app"
      "$HOME/Applications/${cmd_name_capitalized}.app"
    )

    # 모든 가능한 위치 검사
    for app_path in "${possible_app_locations[@]}"; do
      if [[ -d "$app_path" ]]; then
        log_success "$package already installed at $app_path"
        save_state $state_key
        return 0
      fi
    done

    # mdfind로 앱 검색 (Spotlight)
    if mdfind "kMDItemKind == 'Application'" | grep -i "${app_name}.app" &>/dev/null; then
      log_success "$package already installed (found via Spotlight)"
      save_state $state_key
      return 0
    fi
  fi

  log_info "Installing $package..."

  if $is_cask; then
    if brew install --cask $package; then
      log_success "$package installed successfully"
      save_state $state_key
    else
      log_error "Failed to install $package"
      return 1
    fi
  else
    if brew install $package; then
      log_success "$package installed successfully"
      save_state $state_key
    else
      log_error "Failed to install $package"
      return 1
    fi
  fi
}
