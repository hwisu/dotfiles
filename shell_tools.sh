#!/bin/zsh
# 쉘 도구 설치 함수 (shell_tools.sh)

# Import utilities
source "$(dirname "$0")/common.sh"
source "$(dirname "$0")/brew_utils.sh"

# Install Starship prompt with improved configuration
function install_starship() {
  if is_completed "starship_installed"; then
    log_success "Starship previously installed and configured"
    return 0
  fi

  if ! install_brew_package "starship" false "starship"; then
    return 1
  fi

  update_config_file ~/.zshrc "Starship prompt initialization" '
export STARSHIP_CONFIG=~/.config/starship.toml
export STARSHIP_CACHE=~/.starship/cache
eval "$(starship init zsh)"'

  save_state "starship_installed"
}

# Install Zinit
function install_zinit() {
  if is_completed "zinit_installed"; then
    log_success "Zinit previously installed and configured"
    return 0
  fi

  log_info "Installing Zinit..."

  # 이미 zinit 디렉토리가 있는지 확인
  if [[ -d "$HOME/.zinit" ]]; then
    log_success "Zinit already installed"
  elif brew list zinit &>/dev/null; then
    log_success "Zinit already installed via Homebrew"
  else
    if brew install zinit; then
      log_success "Zinit installed successfully"
    else
      log_error "Failed to install Zinit"
      return 1
    fi
  fi

  # Configure Zinit in .zshrc only if not already configured
  if ! grep -q "Zinit initialization" ~/.zshrc; then
    log_info "Configuring Zinit in .zshrc..."
    echo "" >> ~/.zshrc
    echo "# Zinit initialization" >> ~/.zshrc
    echo "source \$(brew --prefix)/opt/zinit/zinit.zsh" >> ~/.zshrc
    echo "" >> ~/.zshrc
    echo "# Zinit plugins" >> ~/.zshrc
    echo "zinit light zsh-users/zsh-syntax-highlighting" >> ~/.zshrc
    echo "zinit light zsh-users/zsh-completions" >> ~/.zshrc
    echo "zinit light zsh-users/zsh-autosuggestions" >> ~/.zshrc
    echo "zinit light zsh-users/zsh-history-substring-search" >> ~/.zshrc
    log_success "Zinit configuration added to .zshrc"
  else
    log_success "Zinit already configured in .zshrc"
  fi

  save_state "zinit_installed"
}

# Install FZF
function install_fzf() {
  if is_completed "fzf_installed"; then
    log_success "FZF previously installed and configured"
    return 0
  fi

  log_info "Installing FZF..."
  if command -v fzf &>/dev/null; then
    log_success "FZF already installed"
  elif brew list fzf &>/dev/null; then
    log_success "FZF already installed via Homebrew"
  else
    if brew install fzf; then
      log_success "FZF installed successfully"
    else
      log_error "Failed to install FZF"
      return 1
    fi
  fi

  # Configure FZF in .zshrc only if not already configured
  if ! grep -q "fzf initialization" ~/.zshrc; then
    log_info "Configuring FZF in .zshrc..."
    echo "" >> ~/.zshrc
    echo "# fzf initialization" >> ~/.zshrc
    echo '[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh' >> ~/.zshrc
    log_success "FZF configuration added to .zshrc"
  else
    log_success "FZF already configured in .zshrc"
  fi

  # Run FZF install script if not already run
  if [ ! -f ~/.fzf.zsh ]; then
    log_info "Running FZF install script..."
    $(brew --prefix)/opt/fzf/install --all --no-bash --no-fish
    log_success "FZF install script completed"
  else
    log_success "FZF scripts already installed"
  fi

  save_state "fzf_installed"
}
