#!/bin/zsh
# GUI 애플리케이션 설치 함수 (gui_apps.sh)

# Import utilities
source "$(dirname "$0")/common.sh"
source "$(dirname "$0")/brew_utils.sh"

# Install Cursor editor
function install_cursor() {
  # Cursor에 대한 추가 앱 이름 변형 확인
  local possible_cursors=(
    "/Applications/Cursor.app"
    "$HOME/Applications/Cursor.app"
    "/Applications/Cursor Editor.app"
    "$HOME/Applications/Cursor Editor.app"
  )

  for cursor_path in "${possible_cursors[@]}"; do
    if [[ -d "$cursor_path" ]]; then
      log_success "Cursor already installed at $cursor_path"
      save_state "brew_cursor"
      return 0
    fi
  done

  install_brew_package "cursor" true "cursor" "Cursor"
}

# Install iTerm2
function install_iterm2() {
  # iTerm2에 대한 추가 앱 이름 확인
  local possible_iterms=(
    "/Applications/iTerm.app"
    "/Applications/iTerm2.app"
    "$HOME/Applications/iTerm.app"
    "$HOME/Applications/iTerm2.app"
  )

  for iterm_path in "${possible_iterms[@]}"; do
    if [[ -d "$iterm_path" ]]; then
      log_success "iTerm2 already installed at $iterm_path"
      save_state "brew_iterm2"
      return 0
    fi
  done

  install_brew_package "iterm2" true "iterm2" "iTerm"
}

# Install 1Password
function install_1password() {
  # 1Password에 대한 추가 앱 이름 확인
  local possible_1passwords=(
    "/Applications/1Password.app"
    "/Applications/1Password 7.app"
    "/Applications/1Password 8.app"
    "$HOME/Applications/1Password.app"
    "$HOME/Applications/1Password 7.app"
    "$HOME/Applications/1Password 8.app"
  )

  for pw_path in "${possible_1passwords[@]}"; do
    if [[ -d "$pw_path" ]]; then
      log_success "1Password already installed at $pw_path"
      save_state "brew_1password"
      return 0
    fi
  done

  install_brew_package "1password" true "1password" "1Password"
}

# Install Docker
function install_docker() {
  install_brew_package "docker" true "docker" "Docker"
}

# Install Neovim
function install_nvim() {
  install_brew_package "neovim" false "nvim"
}

# Install Fira Code Nerd Font
function install_fira_code_nerd_font() {
  if is_completed "font_fira_code_nerd_font"; then
    log_success "Fira Code Nerd Font previously installed"
    return 0
  fi

  log_info "Installing Fira Code Nerd Font..."

  # 폰트가 이미 설치되어 있는지 여러 방법으로 확인
  if fc-list 2>/dev/null | grep -i "fira code nerd" &>/dev/null; then
    log_success "Fira Code Nerd Font already installed (detected via fc-list)"
    save_state "font_fira_code_nerd_font"
    return 0
  fi

  if find ~/Library/Fonts /Library/Fonts -name "*FiraCode*Nerd*" 2>/dev/null | grep -q "."; then
    log_success "Fira Code Nerd Font already installed (found font files)"
    save_state "font_fira_code_nerd_font"
    return 0
  fi

  # 시스템 폰트 확인
  if system_profiler SPFontsDataType 2>/dev/null | grep -i "fira code" | grep -i "nerd" &>/dev/null; then
    log_success "Fira Code Nerd Font already installed (detected via system_profiler)"
    save_state "font_fira_code_nerd_font"
    return 0
  fi

  if brew list --cask font-fira-code-nerd-font &>/dev/null; then
    log_success "Fira Code Nerd Font already installed via Homebrew"
    save_state "font_fira_code_nerd_font"
    return 0
  else
    # 폰트 캐시를 확인하여 폰트의 존재 여부 추가 확인
    if [ -d ~/Library/Caches/Homebrew/Cask/font-fira-code-nerd-font* ]; then
      log_success "Fira Code Nerd Font detected in Homebrew cache"
      save_state "font_fira_code_nerd_font"
      return 0
    fi

    log_info "Installing Fira Code Nerd Font via Homebrew..."
    if brew install --cask font-fira-code-nerd-font; then
      log_success "Fira Code Nerd Font installed successfully"
      save_state "font_fira_code_nerd_font"
    else
      log_error "Failed to install Fira Code Nerd Font"
      return 1
    fi
  fi
}

# Set up editor configuration
function setup_editor() {
  log_info "Setting up Cursor editor configuration..."
  if brew list --cask cursor &>/dev/null || [[ -d "/Applications/Cursor.app" ]]; then
    # 로컬 editor_setting.sh 파일 사용
    local script_path="$(dirname "$0")/editor_setting.sh"
    if [ -f "$script_path" ]; then
      log_info "Using local editor_setting.sh..."
      /bin/chmod +x "$script_path"
      "$script_path"
      log_success "Cursor editor configured successfully"
    else
      log_error "Local editor_setting.sh not found at $script_path"
      return 1
    fi
  else
    log_warning "Cursor not installed, skipping editor configuration"
  fi
}
