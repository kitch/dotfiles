# ── Homebrew ──────────────────────────────────────────────────────────────────
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ── Go ────────────────────────────────────────────────────────────────────────
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH="$GOBIN:/usr/local/go/bin:$PATH"

# ── PATH additions ─────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# ── History ───────────────────────────────────────────────────────────────────
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY

# ── Options ───────────────────────────────────────────────────────────────────
setopt AUTO_CD
setopt GLOB_DOTS
setopt NO_BEEP

# ── Completion ────────────────────────────────────────────────────────────────
autoload -Uz compinit
compinit -i
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ── fzf ───────────────────────────────────────────────────────────────────────
if command -v fzf &>/dev/null; then
  source <(fzf --zsh)
fi
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview-window=right:50%'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# ── zoxide (smart cd) ─────────────────────────────────────────────────────────
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# ── direnv ────────────────────────────────────────────────────────────────────
if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

# ── General aliases ───────────────────────────────────────────────────────────
alias ls='eza --icons'
alias ll='eza -la --icons --git'
alias lt='eza --tree --icons -L 2'
alias cat='bat --style=plain'
alias grep='rg'
alias find='fd'
alias vim='nvim'

# ── Git aliases ───────────────────────────────────────────────────────────────
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate'
alias gd='git diff'

# ── Lima / k3s ───────────────────────────────────────────────────────────────
alias lstart='limactl start k3s'
alias lstop='limactl stop k3s'
alias ldelete='limactl delete k3s'
alias lls='limactl list'
alias lshell='limactl shell k3s'

# Merge k3s kubeconfig into ~/.kube/config on demand
kmerge-k3s() {
  local lima_cfg="$HOME/.lima/k3s/copied-from-guest/kubeconfig.yaml"
  if [[ ! -f "$lima_cfg" ]]; then
    echo "k3s VM not running — start it with: lstart"
    return 1
  fi
  mkdir -p "$HOME/.kube"
  if [[ ! -f "$HOME/.kube/config" ]]; then
    cp "$lima_cfg" "$HOME/.kube/config"
  else
    KUBECONFIG="$HOME/.kube/config:$lima_cfg" kubectl config view --flatten > "$HOME/.kube/config.merged"
    mv "$HOME/.kube/config.merged" "$HOME/.kube/config"
  fi
  kubectl config use-context default
  echo "Merged k3s context → ~/.kube/config"
}

# ── Kubernetes aliases ────────────────────────────────────────────────────────
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias kex='kubectl exec -it'
alias kdel='kubectl delete'
alias kns='kubens'
alias kctx='kubectx'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods -A'
alias kgs='kubectl get svc'
alias kgn='kubectl get nodes'
alias kga='kubectl get all'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'

# Quickly get a shell in a pod
ksh() { kubectl exec -it "$1" -- /bin/sh; }
kbash() { kubectl exec -it "$1" -- /bin/bash; }

# tail logs across multiple pods matching a label selector
klabel() { stern -l "$@"; }

# ── Go aliases ────────────────────────────────────────────────────────────────
alias got='go test ./...'
alias gotr='go test -run'
alias gob='go build ./...'
alias gom='go mod tidy'
alias gor='go run .'

# ── Misc helpers ──────────────────────────────────────────────────────────────
alias reload='source ~/.zshrc'
alias dotfiles='cd ~/projects/dotfiles'

# Open current dir in Finder
alias finder='open .'

# Show/hide hidden files in Finder
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'

# Quick HTTP server in current directory
serve() { python3 -m http.server "${1:-8000}"; }

# ── Python (uv) ───────────────────────────────────────────────────────────────
if command -v uv &>/dev/null; then
  eval "$(uv generate-shell-completion zsh)"
  export UV_PYTHON_DOWNLOADS=auto
fi

# ── Podman / local AI ─────────────────────────────────────────────────────────
alias pm='podman'
alias pmc='podman-compose'

OPEN_WEBUI_COMPOSE="$HOME/projects/dotfiles/services/open-webui/compose.yml"

webui-start() {
  podman machine start 2>/dev/null || true
  podman-compose -f "$OPEN_WEBUI_COMPOSE" up -d
  echo "Open WebUI → http://localhost:3000"
}
webui-stop()   { podman-compose -f "$OPEN_WEBUI_COMPOSE" down; }
webui-logs()   { podman-compose -f "$OPEN_WEBUI_COMPOSE" logs -f; }
webui-update() {
  podman pull ghcr.io/open-webui/open-webui:main
  podman-compose -f "$OPEN_WEBUI_COMPOSE" up -d --force-recreate
}

# ── Starship prompt ───────────────────────────────────────────────────────────
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi
