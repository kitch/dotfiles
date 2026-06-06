# dotfiles

Personal dotfiles for macOS — shell, Go, Kubernetes, and general dev work.

## Stack

- **Terminal**: [Ghostty](https://ghostty.org/)
- **Prompt**: [Starship](https://starship.rs/)
- **Shell**: zsh
- **Package manager**: [Homebrew](https://brew.sh/)

## Quick start

```sh
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
./install.sh
```

The installer will:
1. Install Homebrew (if missing)
2. Install all packages from `Brewfile`
3. Symlink configs to their expected locations
4. Apply sensible macOS defaults

## Flags

```sh
./install.sh --skip-brew    # skip Homebrew install + bundle
./install.sh --skip-macos   # skip macOS defaults
```

## Local machine config (keep private)

Git identity (name, email, signing key) lives in `~/.gitconfig.local` — this file
is gitignored and never committed. On a new machine, the installer copies the
template for you:

```sh
cp git/.gitconfig.local.template ~/.gitconfig.local
# then edit ~/.gitconfig.local
```

## Structure

```
dotfiles/
├── Brewfile                      # all Homebrew packages
├── install.sh                    # bootstrap script
├── git/
│   ├── .gitconfig                # global git config (no identity)
│   ├── .gitconfig.local.template # copy to ~/.gitconfig.local
│   └── .gitignore_global         # global gitignore
├── ghostty/
│   └── config                    # Ghostty terminal config
├── starship/
│   └── starship.toml             # Starship prompt config
└── zsh/
    ├── .zprofile                 # Homebrew env (login shells)
    └── .zshrc                    # main shell config
```

## Adding a new machine

```sh
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/projects/dotfiles
~/projects/dotfiles/install.sh
echo "Edit ~/.gitconfig.local with your name and email"
```
