#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Colors ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${BLUE}[info]${NC} $*"; }
success() { echo -e "${GREEN}[ok]${NC} $*"; }
warn()    { echo -e "${YELLOW}[warn]${NC} $*"; }
error()   { echo -e "${RED}[error]${NC} $*" >&2; }

# ── Helpers ───────────────────────────────────────────────────────────────────
link() {
  local src="$1" dst="$2"
  local dst_dir
  dst_dir="$(dirname "$dst")"

  mkdir -p "$dst_dir"

  if [[ -L "$dst" ]]; then
    if [[ "$(readlink "$dst")" == "$src" ]]; then
      success "already linked: $dst"
      return
    fi
    warn "replacing existing symlink: $dst"
    rm "$dst"
  elif [[ -e "$dst" ]]; then
    local backup="${dst}.bak.$(date +%Y%m%d%H%M%S)"
    warn "backing up existing file: $dst → $backup"
    mv "$dst" "$backup"
  fi

  ln -s "$src" "$dst"
  success "linked: $dst → $src"
}

# ── Homebrew ──────────────────────────────────────────────────────────────────
install_homebrew() {
  if command -v brew &>/dev/null; then
    info "Homebrew already installed"
    return
  fi
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for the rest of this script (Apple Silicon)
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  success "Homebrew installed"
}

install_packages() {
  info "Installing packages from Brewfile..."
  brew bundle --file="$DOTFILES/Brewfile"
  success "Packages installed"
}

# ── Symlinks ──────────────────────────────────────────────────────────────────
link_configs() {
  info "Linking config files..."

  # Zsh
  link "$DOTFILES/zsh/.zshrc"    "$HOME/.zshrc"
  link "$DOTFILES/zsh/.zprofile" "$HOME/.zprofile"

  # Git
  link "$DOTFILES/git/.gitconfig"        "$HOME/.gitconfig"
  link "$DOTFILES/git/.gitignore_global" "$HOME/.gitignore_global"

  # Ghostty
  link "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"

  # Starship
  link "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"

  # Neovim
  link "$DOTFILES/nvim" "$HOME/.config/nvim"

  success "All configs linked"
}

# ── Git local identity ────────────────────────────────────────────────────────
setup_git_identity() {
  if [[ -f "$HOME/.gitconfig.local" ]]; then
    success "~/.gitconfig.local already exists — skipping"
    return
  fi

  warn "No ~/.gitconfig.local found."
  info "Copying template → ~/.gitconfig.local"
  cp "$DOTFILES/git/.gitconfig.local.template" "$HOME/.gitconfig.local"
  warn "Edit ~/.gitconfig.local to set your name and email before committing."
}

# ── fzf shell integration ─────────────────────────────────────────────────────
setup_fzf() {
  if command -v fzf &>/dev/null; then
    info "Configuring fzf shell integration..."
    "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish 2>/dev/null || true
    success "fzf configured"
  fi
}

# ── macOS defaults ────────────────────────────────────────────────────────────
setup_macos() {
  info "Applying macOS defaults..."

  # Faster key repeat
  defaults write NSGlobalDomain KeyRepeat -int 2
  defaults write NSGlobalDomain InitialKeyRepeat -int 15

  # Show all filename extensions in Finder
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  # Show hidden files in Finder
  defaults write com.apple.finder AppleShowAllFiles -bool true

  # Disable the "Are you sure you want to open this application?" dialog
  defaults write com.apple.LaunchServices LSQuarantine -bool false

  # Disable automatic capitalization
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

  # Disable smart dashes
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

  # Disable smart quotes
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

  success "macOS defaults applied (some need a logout to take effect)"
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
  echo ""
  echo "  dotfiles installer"
  echo "  =================="
  echo ""

  local skip_brew=false
  local skip_macos=false

  for arg in "$@"; do
    case "$arg" in
      --skip-brew)   skip_brew=true ;;
      --skip-macos)  skip_macos=true ;;
      --help|-h)
        echo "Usage: $0 [--skip-brew] [--skip-macos]"
        exit 0
        ;;
    esac
  done

  if [[ "$skip_brew" == false ]]; then
    install_homebrew
    install_packages
  fi

  link_configs
  setup_git_identity
  setup_fzf

  if [[ "$skip_macos" == false ]]; then
    setup_macos
  fi

  echo ""
  success "Done! Open a new terminal to pick up the changes."
  echo ""
  echo "  Next steps:"
  echo "  1. Edit ~/.gitconfig.local with your name and email"
  echo "  2. Restart Ghostty to apply the config"
  echo "  3. Tweak starship/starship.toml to your taste"
  echo ""
}

main "$@"
