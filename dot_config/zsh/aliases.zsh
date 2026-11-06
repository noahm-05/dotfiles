# every alias is defined only if its tool exists; no builtin is shadowed
if (( $+commands[eza] )); then
  alias ll='eza -l --git' la='eza -la --git' lt='eza --tree -L 2'
fi
(( $+commands[lazygit] )) && alias lg=lazygit
alias ..='cd ..' ...='cd ../..'
(( $+commands[ss] ))      && alias ports='ss -tulpn'
(( $+commands[ip] ))      && alias ipa='ip -br -c a'
(( $+commands[chezmoi] )) && alias dots='chezmoi cd'
alias reload='exec zsh'
