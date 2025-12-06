#  Source global zsh definitions
# Fedora provides /etc/zshrc instead of /etc/bashrc
[ -f /etc/zshrc ] && source /etc/zshrc


#  PATH Setup (order preserved)
export PATH="$HOME/.local/kitty.app/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"
export OLLAMA_MODELS="/run/media/kushagra/SharedLinux/ollama-models"

#  Load scripts from ~/.zshrc.d 
if [ -d "$HOME/.zshrc.d" ]; then
  for rc in "$HOME"/.zshrc.d/*; do
    [ -f "$rc" ] && source "$rc"
  done
fi


#  Nix environment
[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ] && source "$HOME/.nix-profile/etc/profile.d/nix.sh"


#  Editor settings
export EDITOR="nvim"
export VISUAL="nvim"


#  Yazi function 
y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && cd -- "$cwd"
    rm -f -- "$tmp"
}


#  Zsh-specific improvements
# Enable completion
autoload -Uz compinit
compinit

# Write every command to history immediately so thefuck can read it
preexec() {
  print -sr -- "$1"
}

# Faster completion
zstyle ':completion:*' menu select
zstyle ':completion:*' rehash true

# History settings (zsh defaults suck without tweaking)
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
unsetopt HIST_IGNORE_SPACE
setopt inc_append_history
setopt share_history
setopt hist_find_no_dups
setopt hist_expire_dups_first

# Allow ** for recursive globbing
setopt extended_glob
setopt glob_dots          # allow ** to match dotfiles
setopt glob_complete      # allow TAB completion on glob patterns
setopt AUTO_MENU          # show menu on partial completion

# Fix backspace/Home/End key issues
bindkey -e   # use emacs bindings (same as bash)

#  fzf key bindings for zsh
if [ -f /usr/share/fzf/shell/key-bindings.zsh ]; then
    source /usr/share/fzf/shell/key-bindings.zsh
fi

if [ -f /usr/share/fzf/shell/completion.zsh ]; then
    source /usr/share/fzf/shell/completion.zsh
fi


#  Plugins 
# Autosuggestions
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Syntax Highlighting (must be LAST)
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

#  Alisas
# eza
alias ls='eza --color=always --long --git --icons=always --no-time --no-user --no-permissions --no-filesize'
alias lt='eza --tree --icons=always --color=always --git-ignore'

alias la='eza -a --color=always --long --git --icons=always --no-time --no-user --no-permissions --no-filesize'

alias l='eza --icons=always'

#zoxide
eval "$(zoxide init zsh)"
alias cd='z'

#Ai chat
alias chat='aichat'
alias aic="aichat -m openrouter:qwen/qwen3-coder:free -c"

#Mount Phone
alias cphone="sshfs myphone:/storage/emulated/0 ~/mnt/myphone -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3 && echo '📱 Phone Connected!'"

#Unmount Phone
alias dphone="fusermount3 -u ~/mnt/myphone && echo '🔌 Phone Disconnected!'"

# AIChat Shell Integration (Alt+E)
source ~/.config/aichat/aichat-zsh-integration

# AIChat Autocompletion
source ~/.config/aichat/aichat-zsh-completion

[ -f "$HOME/.zsh_secrets" ] && source "$HOME/.zsh_secrets"

clear
fastfetch
