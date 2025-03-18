#!/bin/sh
# It is for macos
OS="$(uname)"
echo "Detected OS: $OS"

setup_git() {
  echo "Setting up Git configuration..."
  # Download and execute gitset.sh
  curl -fsSL https://raw.githubusercontent.com/hwisu/REPO/main/gitset.sh -o gitset.sh
  chmod +x gitset.sh
  ./gitset.sh
  rm gitset.sh
}

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

install_cursor
install_nvim
install_1password
install_starship
install_zinit
install_fzf
install_fira_code_nerd_font
install_iterm2
install_docker
setup_git
echo "Bootstrap completed!"

