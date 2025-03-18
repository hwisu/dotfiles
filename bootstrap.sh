#!/bin/sh
# It is for macos
OS="$(uname)"
echo "Detected OS: $OS"

install_cursor() {
  echo "Installing CURSOR (VSCode base editor)..."
  brew install --cask cursor
}


install_nvim() {
  echo "Installing Neovim..."
  brew install neovim
}

install_1password() {
  echo "Installing 1Password..."
  brew install --cask 1password
}

install_starship() {
  echo "Installing starship prompt..."
  brew install starship

  echo "" >> ~/.zshrc
  echo "# Starship prompt initialization" >> ~/.zshrc
  echo "export STARSHIP_CONFIG=~/.config/starship.toml" >> ~/.zshrc
  echo "export STARSHIP_CACHE=~/.starship/cache" >> ~/.zshrc
  echo 'eval "$(starship init zsh)"' >> ~/.zshrc
}

install_zinit() {
  echo "Installing zinit..."
  brew install zinit

  echo "" >> ~/.zshrc
  echo "# Zinit initialization" >> ~/.zshrc
  echo "source $(brew --prefix)/opt/zinit/zinit.zsh" >> ~/.zshrc
  echo "" >> ~/.zshrc
  echo "# Zinit plugins" >> ~/.zshrc
  echo "zinit light zsh-users/zsh-autosuggestions" >> ~/.zshrc
  echo "zinit light zdharma-continuum/fast-syntax-highlighting" >> ~/.zshrc
  echo "zinit light zdharma-continuum/history-search-multi-word" >> ~/.zshrc
}

install_fzf() {
  echo "Installing fzf..."
  brew install fzf

  echo "" >> ~/.zshrc
  echo "# fzf initialization" >> ~/.zshrc
  echo '[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh' >> ~/.zshrc

  # Run fzf install script
  $(brew --prefix)/opt/fzf/install --all
}

install_fira_code_nerd_font() {
  echo "Installing Fira Code Nerd Font..."
  brew install --cask font-fira-code-nerd-font
}

install_iterm2() {
  echo "Installing iTerm2..."
  brew install --cask iterm2
}

install_docker() {
  echo "Installing Docker..."
  brew install --cask docker

  echo "" >> ~/.zshrc
  echo "# Docker completion" >> ~/.zshrc
  echo "zinit snippet OMZP::docker" >> ~/.zshrc
}

install_node_tools() {
  echo "Installing Node.js and related tools..."
  # Install nvm (Node Version Manager)
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

  # Add nvm to zshrc if not already present
  if ! grep -q "nvm initialization" ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "# nvm initialization" >> ~/.zshrc
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.zshrc
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.zshrc
  fi

  # Source nvm directly
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

  # Install latest LTS version
  nvm install --lts
  nvm use --lts

  # Install pnpm globally
  curl -fsSL https://get.pnpm.io/install.sh | sh -

  # Add pnpm to path directly
  export PNPM_HOME="$HOME/Library/pnpm"
  case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
  esac

  # Install global development tools using full path to pnpm
  $PNPM_HOME/pnpm install -g typescript ts-node
  $PNPM_HOME/pnpm install -g @antfu/ni # Smart npm/yarn/pnpm command dispatcher
}

install_dev_tools() {
  echo "Installing additional development tools..."
  # Install ripgrep for better search
  brew install ripgrep

  # Install lazygit for better git UI
  brew install lazygit

  # Install bat (better cat)
  brew install bat
  echo "" >> ~/.zshrc
  echo "# bat alias" >> ~/.zshrc
  echo 'alias cat="bat"' >> ~/.zshrc

  # Install exa (modern ls replacement)
  brew install exa
  echo "" >> ~/.zshrc
  echo "# exa aliases" >> ~/.zshrc
  echo 'alias ls="exa"' >> ~/.zshrc
  echo 'alias ll="exa -l"' >> ~/.zshrc
  echo 'alias la="exa -la"' >> ~/.zshrc
  echo 'alias lt="exa --tree"' >> ~/.zshrc

  # Install tldr for better man pages
  brew install tldr

  # Install httpie for API testing
  brew install httpie
}

setup_git() {
  echo "Setting up Git configuration..."
  # Download and execute gitset.sh
  curl -fsSL https://raw.githubusercontent.com/hwisu/REPO/main/gitset.sh -o gitset.sh
  chmod +x gitset.sh
  ./gitset.sh
  rm gitset.sh
}

setup_editor() {
  echo "Setting up Cursor editor configuration..."
  curl -fsSL https://raw.githubusercontent.com/hwisu/REPO/main/editor_setting.sh -o editor_setting.sh
  chmod +x editor_setting.sh
  ./editor_setting.sh
  rm editor_setting.sh
}

install_cursor
install_nvim
install_1password
install_starship
install_zinit
install_fzf
install_fira_code_nerd_font
install_iterm2
install_docker
install_node_tools
install_dev_tools
setup_git
setup_editor
echo "Bootstrap completed!"

