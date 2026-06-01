# ==============================================================================
# 1. THEME INITIALIZATION (Instant Prompt OFF to fix Kitty graphics)
# ==============================================================================
# "quiet" or "verbose" will strip your anime image. "off" is the only 100% fix.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ==============================================================================
# 2. STARTUP (Run FIRST after preamble)
# ==============================================================================
if [[ -z "$TMUX" ]]; then
    clear
    fastfetch --logo-type kitty --logo /home/kushagra/.config/fastfetch/Sailor_moon-removebg-preview.png
fi

# ==============================================================================
# 3. ENVIRONMENT & PATHS
# ==============================================================================
[ -f /etc/zshrc ] && source /etc/zshrc

export EDITOR="nvim"
export VISUAL="nvim"
export MANGA_TUI_DATA_DIR="$HOME/Downloads/MangaImport"

export PATH="$HOME/dotfiles/bin:$PATH"
export PATH="$HOME/.local/kitty.app/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"

export OLLAMA_MODELS="/run/media/kushagra/SharedLinux/ollama-models"
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git" 

[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ] && source "$HOME/.nix-profile/etc/profile.d/nix.sh"

# ==============================================================================
# 4. MODULAR CONFIGS & SECRETS
# ==============================================================================
if [ -d "$HOME/.zshrc.d" ]; then
  for rc in "$HOME"/.zshrc.d/*; do
    [ -f "$rc" ] && source "$rc"
  done
fi

[ -f "$HOME/.zsh_secrets" ] && source "$HOME/.zsh_secrets"

# ==============================================================================
# 5. CORE SETTINGS & ALIASES
# ==============================================================================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_find_no_dups
setopt hist_verify
setopt hist_ignore_space 

autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' rehash true 

bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

eval "$(zoxide init zsh)"
eval "$(fzf --zsh)"

alias ls='eza --color=always --long --git --icons=always --no-time --no-user --no-permissions --no-filesize'
alias lt='eza --tree --icons=always --color=always --git-ignore'
alias la='eza -a --color=always --long --git --icons=always --no-time --no-user --no-permissions --no-filesize'
alias l='eza --icons=always' 

alias cphone="sshfs myphone:/storage/emulated/0 ~/mnt/myphone -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3 && echo '📱 Phone Connected!'"
alias dphone="fusermount3 -u ~/mnt/myphone && echo '🔌 Phone Disconnected!'"

alias cd='z'
alias chat='aichat'
alias aic="aichat -m openrouter:qwen/qwen3-coder:free -c"
alias python="python3"
alias venv="source .venv/bin/activate"
alias anki='flatpak run net.ankiweb.Anki >/dev/null 2>&1 & disown'
alias upscale='/home/kushagra/Downloads/waifu2x-ncnn-vulkan/build/waifu2x-ncnn-vulkan -n 2 -s 2 -m /home/kushagra/Downloads/waifu2x-ncnn-vulkan/models/models-cunet'

y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    # Use 'command' to ensure we call the binary, not an alias/function
    command yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# ==============================================================================
# 6. PLUGINS & THEME (Must be at the very bottom)
# ==============================================================================
[ -f ~/fzf-git.sh/fzf-git.sh ] && source ~/fzf-git.sh/fzf-git.sh

[ -f ~/.config/aichat/aichat-zsh-integration ] && source ~/.config/aichat/aichat-zsh-integration
[ -f ~/.config/aichat/aichat-zsh-completion ] && source ~/.config/aichat/aichat-zsh-completion 

[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^f' vi-forward-word 
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source ~/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[[ -f ~/.p10k_wallust.zsh ]] && source ~/.p10k_wallust.zsh
