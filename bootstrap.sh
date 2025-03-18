#!/bin/sh
# Improved bootstrap script for macOS

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log functions
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Check OS
check_os() {
  OS="$(uname)"
  log_info "Detected OS: $OS"
  if [ "$OS" != "Darwin" ]; then
    log_error "This script is only for macOS. Exiting."
    exit 1
  fi
}

# Check if Homebrew is installed, install if not
ensure_homebrew() {
  log_info "Checking for Homebrew..."
  if ! command -v brew >/dev/null 2>&1; then
    log_warning "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [ -f "/opt/homebrew/bin/brew" ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
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
}

# Install Cursor editor
install_cursor() {
  log_info "Installing Cursor (VSCode-based editor)..."
  if brew list --cask cursor &>/dev/null; then
    log_success "Cursor already installed"
  else
    if brew install --cask cursor; then
      log_success "Cursor installed successfully"
    else
      log_error "Failed to install Cursor"
    fi
  fi
}

# Install Neovim
install_nvim() {
  log_info "Installing Neovim..."
  if brew list neovim &>/dev/null; then
    log_success "Neovim already installed"
  else
    if brew install neovim; then
      log_success "Neovim installed successfully"
    else
      log_error "Failed to install Neovim"
    fi
  fi
}

# Install 1Password
install_1password() {
  log_info "Installing 1Password..."
  if brew list --cask 1password &>/dev/null; then
    log_success "1Password already installed"
  else
    if brew install --cask 1password; then
      log_success "1Password installed successfully"
    else
      log_error "Failed to install 1Password"
    fi
  fi
}

# Install Starship prompt
install_starship() {
  log_info "Installing Starship prompt..."
  if brew list starship &>/dev/null; then
    log_success "Starship already installed"
  else
    if brew install starship; then
      log_success "Starship installed successfully"
    else
      log_error "Failed to install Starship"
      return
    fi
  fi

  # Configure Starship in .zshrc only if not already configured
  if ! grep -q "Starship prompt initialization" ~/.zshrc; then
    log_info "Configuring Starship in .zshrc..."
    mkdir -p ~/.config
    echo "" >> ~/.zshrc
    echo "# Starship prompt initialization" >> ~/.zshrc
    echo "export STARSHIP_CONFIG=~/.config/starship.toml" >> ~/.zshrc
    echo "export STARSHIP_CACHE=~/.starship/cache" >> ~/.zshrc
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc
    log_success "Starship configuration added to .zshrc"
  else
    log_success "Starship already configured in .zshrc"
  fi
}

# Install Zinit
install_zinit() {
  log_info "Installing Zinit..."
  if brew list zinit &>/dev/null; then
    log_success "Zinit already installed"
  else
    if brew install zinit; then
      log_success "Zinit installed successfully"
    else
      log_error "Failed to install Zinit"
      return
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
    echo "zinit light zsh-users/zsh-autosuggestions" >> ~/.zshrc
    echo "zinit light zsh-users/zsh-history-substring-search" >> ~/.zshrc
    log_success "Zinit configuration added to .zshrc"
  else
    log_success "Zinit already configured in .zshrc"
  fi
}

# Install FZF
install_fzf() {
  log_info "Installing FZF..."
  if brew list fzf &>/dev/null; then
    log_success "FZF already installed"
  else
    if brew install fzf; then
      log_success "FZF installed successfully"
    else
      log_error "Failed to install FZF"
      return
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
}

# Install Fira Code Nerd Font
install_fira_code_nerd_font() {
  log_info "Installing Fira Code Nerd Font..."
  if brew list --cask font-fira-code-nerd-font &>/dev/null; then
    log_success "Fira Code Nerd Font already installed"
  else
    if brew install --cask font-fira-code-nerd-font; then
      log_success "Fira Code Nerd Font installed successfully"
    else
      log_error "Failed to install Fira Code Nerd Font"
    fi
  fi
}

# Install iTerm2
install_iterm2() {
  log_info "Installing iTerm2..."
  if brew list --cask iterm2 &>/dev/null; then
    log_success "iTerm2 already installed"
  else
    if brew install --cask iterm2; then
      log_success "iTerm2 installed successfully"
    else
      log_error "Failed to install iTerm2"
    fi
  fi
}

# Install Docker
install_docker() {
  log_info "Installing Docker..."
  if brew list --cask docker &>/dev/null; then
    log_success "Docker already installed"
  else
    if brew install --cask docker; then
      log_success "Docker installed successfully"
    else
      log_error "Failed to install Docker"
      return
    fi
  fi
}

# Install Node.js tools
install_node_tools() {
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
      curl -fsSL https://get.pnpm.io/install.sh | sh -
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
}

# Install developer tools
install_dev_tools() {
  log_info "Installing additional development tools..."

  # Install ripgrep
  if ! brew list ripgrep &>/dev/null; then
    log_info "Installing ripgrep..."
    brew install ripgrep
    log_success "ripgrep installed successfully"
  else
    log_success "ripgrep already installed"
  fi

  # Install lazygit
  if ! brew list lazygit &>/dev/null; then
    log_info "Installing lazygit..."
    brew install lazygit
    log_success "lazygit installed successfully"
  else
    log_success "lazygit already installed"
  fi

  # Install bat
  if ! brew list bat &>/dev/null; then
    log_info "Installing bat..."
    brew install bat
    log_success "bat installed successfully"
  else
    log_success "bat already installed"
  fi

  # Configure bat alias if not already configured
  if ! grep -q "bat alias" ~/.zshrc; then
    log_info "Configuring bat alias in .zshrc..."
    echo "" >> ~/.zshrc
    echo "# bat alias" >> ~/.zshrc
    echo 'alias cat="bat"' >> ~/.zshrc
    log_success "bat alias added to .zshrc"
  else
    log_success "bat alias already configured in .zshrc"
  fi

  # Install eza
  if ! brew list eza &>/dev/null; then
    log_info "Installing eza..."
    brew install eza
    log_success "eza installed successfully"
  else
    log_success "eza already installed"
  fi

  # Configure eza aliases if not already configured
  if ! grep -q "eza aliases" ~/.zshrc; then
    log_info "Configuring eza aliases in .zshrc..."
    echo "" >> ~/.zshrc
    echo "# eza aliases" >> ~/.zshrc
    echo 'alias ls="eza"' >> ~/.zshrc
    echo 'alias ll="eza -l"' >> ~/.zshrc
    echo 'alias la="eza -la"' >> ~/.zshrc
    echo 'alias lt="eza --tree"' >> ~/.zshrc
    log_success "eza aliases added to .zshrc"
  else
    log_success "eza aliases already configured in .zshrc"
  fi

  # Install tldr
  if ! brew list tldr &>/dev/null; then
    log_info "Installing tldr..."
    brew install tldr
    log_success "tldr installed successfully"
  else
    log_success "tldr already installed"
  fi

  # Install httpie
  if ! brew list httpie &>/dev/null; then
    log_info "Installing httpie..."
    brew install httpie
    log_success "httpie installed successfully"
  else
    log_success "httpie already installed"
  fi
}

# Set up Git configuration
setup_git() {
  log_info "Setting up Git configuration..."
  if [ ! -f "$HOME/.gitconfig" ] || ! grep -q "user.name" "$HOME/.gitconfig"; then
    # Download and execute gitset.sh
    log_info "Downloading gitset.sh..."
    curl -fsSL https://raw.githubusercontent.com/hwisu/REPO/main/gitset.sh -o gitset.sh
    if [ $? -eq 0 ]; then
      chmod +x gitset.sh
      ./gitset.sh
      rm gitset.sh
      log_success "Git configured successfully"
    else
      log_error "Failed to download gitset.sh"
    fi
  else
    log_success "Git already configured"
  fi
}

# Set up Cursor editor configuration
setup_editor() {
  log_info "Setting up Cursor editor configuration..."
  if brew list --cask cursor &>/dev/null; then
    log_info "Downloading editor_setting.sh..."
    curl -fsSL https://raw.githubusercontent.com/hwisu/REPO/main/editor_setting.sh -o editor_setting.sh
    if [ $? -eq 0 ]; then
      chmod +x editor_setting.sh
      ./editor_setting.sh
      rm editor_setting.sh
      log_success "Cursor editor configured successfully"
    else
      log_error "Failed to download editor_setting.sh"
    fi
  else
    log_warning "Cursor not installed, skipping editor configuration"
  fi
}

# Restart notice
restart_notice() {
  log_info "====================================================="
  log_info "Bootstrap completed!"
  log_info "To apply all changes, restart your terminal or run:"
  log_info "source ~/.zshrc"
  log_info "====================================================="
}

# Main function with parallel execution
main() {
  check_os
  ensure_homebrew

  log_info "Starting parallel installation of applications..."

  # Phase 1: Install applications in parallel (can run independently)
  install_cursor &
  install_nvim &
  install_1password &
  install_fira_code_nerd_font &
  install_iterm2 &
  install_docker &
  wait

  # Phase 2: Install shell tools that modify .zshrc
  install_starship
  install_zinit
  install_fzf

  # Phase 3: Install Node.js tools
  install_node_tools

  # Phase 4: Install additional developer tools
  install_dev_tools

  # Phase 5: Set up configurations
  setup_git
  setup_editor

  restart_notice
}

# Run the main function
main

