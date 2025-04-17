#!/bin/zsh
# 개발 도구 설치 함수 (dev_tools.sh)

# Import utilities
source "$(dirname "$0")/common.sh"
source "$(dirname "$0")/brew_utils.sh"

# Set up Git configuration
function setup_git() {
  log_info "Setting up Git configuration..."
  if [ ! -f "$HOME/.gitconfig" ] || ! grep -q "user.name" "$HOME/.gitconfig"; then
    # 로컬 gitset.sh 파일 사용
    local script_path="$(dirname "$0")/gitset.sh"
    if [ -f "$script_path" ]; then
      log_info "Using local gitset.sh..."
      /bin/chmod +x "$script_path"
      "$script_path"
      log_success "Git configured successfully"
    else
      log_error "Local gitset.sh not found at $script_path"
      return 1
    fi
  else
    log_success "Git already configured"
  fi
}

# Install developer tools
function install_dev_tools() {
  if is_completed "dev_tools_installed"; then
    log_success "Developer tools previously installed and configured"
    return 0
  fi

  log_info "Installing additional development tools..."

  # 공통 도구 설치 (명령줄 도구)
  local tools=(
    "ripgrep:rg"
    "lazygit:lazygit"
    "bat:bat"
    "eza:eza"
    "tldr:tldr"
    "httpie:http"
  )

  for tool_info in "${tools[@]}"; do
    local package="${tool_info%%:*}"
    local cmd="${tool_info##*:}"

    if ! install_brew_package "$package" false "$cmd"; then
      log_warning "Skipping some configuration for $package"
    fi
  done

  # bat 별칭 설정
  if command -v bat &>/dev/null && ! grep -q "bat alias" ~/.zshrc; then
    log_info "Configuring bat alias in .zshrc..."
    echo "" >> ~/.zshrc
    echo "# bat alias" >> ~/.zshrc
    echo 'alias cat="bat"' >> ~/.zshrc
    log_success "bat alias added to .zshrc"
  elif grep -q "bat alias" ~/.zshrc; then
    log_success "bat alias already configured in .zshrc"
  fi

  # eza 별칭 설정
  if command -v eza &>/dev/null && ! grep -q "eza aliases" ~/.zshrc; then
    log_info "Configuring eza aliases in .zshrc..."
    echo "" >> ~/.zshrc
    echo "# eza aliases" >> ~/.zshrc
    echo 'alias ls="eza"' >> ~/.zshrc
    echo 'alias ll="eza -l"' >> ~/.zshrc
    echo 'alias la="eza -la"' >> ~/.zshrc
    echo 'alias lt="eza --tree"' >> ~/.zshrc
    log_success "eza aliases added to .zshrc"
  elif grep -q "eza aliases" ~/.zshrc; then
    log_success "eza aliases already configured in .zshrc"
  fi

  save_state "dev_tools_installed"
}

# Install Node.js tools
function install_node_tools() {
  if is_completed "node_tools_installed"; then
    log_success "Node.js tools previously installed and configured"
    return 0
  fi

  log_info "Installing Node.js and related tools..."

  # Install nvm if not already installed
  if [ ! -d "$HOME/.nvm" ]; then
    log_info "Installing NVM (Node Version Manager)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    log_success "NVM installed successfully"
  else
    log_success "NVM already installed"
  fi

  # Add nvm to zshrc if not already present
  if ! grep -q "nvm initialization" ~/.zshrc; then
    log_info "Configuring NVM in .zshrc..."
    echo "" >> ~/.zshrc
    echo "# nvm initialization" >> ~/.zshrc
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.zshrc
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.zshrc
    log_success "NVM configuration added to .zshrc"
  else
    log_success "NVM already configured in .zshrc"
  fi

  # Source nvm directly
  export NVM_DIR="$HOME/.nvm"
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
    log_success "NVM sourced in current shell"

    # Check if LTS version is installed, install if not
    if ! nvm ls --no-colors | grep -q "lts"; then
      log_info "Installing Node.js LTS version..."
      nvm install --lts
      nvm use --lts
      log_success "Node.js LTS installed and set as default"
    else
      log_success "Node.js LTS already installed"
    fi

    # Install pnpm if not already installed
    if ! command -v pnpm >/dev/null 2>&1; then
      log_info "Installing pnpm..."
      curl -fsSL https://get.pnpm.io/install.sh | /bin/sh -
      log_success "pnpm installed successfully"
    else
      log_success "pnpm already installed"
    fi

    # Add pnpm to path directly
    export PNPM_HOME="$HOME/Library/pnpm"
    case ":$PATH:" in
      *":$PNPM_HOME:"*) ;;
      *) export PATH="$PNPM_HOME:$PATH" ;;
    esac

    # Add pnpm to .zshrc if not already present
    if ! grep -q "pnpm initialization" ~/.zshrc; then
      log_info "Configuring pnpm in .zshrc..."
      echo "" >> ~/.zshrc
      echo "# pnpm initialization" >> ~/.zshrc
      echo 'export PNPM_HOME="$HOME/Library/pnpm"' >> ~/.zshrc
      echo 'case ":$PATH:" in' >> ~/.zshrc
      echo '  *":$PNPM_HOME:"*) ;;' >> ~/.zshrc
      echo '  *) export PATH="$PNPM_HOME:$PATH" ;;' >> ~/.zshrc
      echo 'esac' >> ~/.zshrc
      log_success "pnpm configuration added to .zshrc"
    else
      log_success "pnpm already configured in .zshrc"
    fi

    # Install global development tools if not already installed
    if [ -d "$PNPM_HOME" ]; then
      log_info "Installing global Node.js development tools..."
      if ! command -v typescript >/dev/null 2>&1; then
        $PNPM_HOME/pnpm install -g typescript ts-node
        log_success "TypeScript tools installed globally"
      else
        log_success "TypeScript tools already installed"
      fi

      if ! command -v ni >/dev/null 2>&1; then
        $PNPM_HOME/pnpm install -g @antfu/ni
        log_success "@antfu/ni installed globally"
      else
        log_success "@antfu/ni already installed"
      fi
    fi
  else
    log_error "NVM installation not found, skipping Node.js tools setup"
  fi

  save_state "node_tools_installed"
}
