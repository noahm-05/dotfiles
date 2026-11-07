# each function body stays <= 5 lines
y() {
	local tmp=$(mktemp -t yazi-cwd.XXXXXX) cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[[ -d $cwd && $cwd != $PWD ]] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
tun0() { ip -4 -br addr show tun0 2>/dev/null | awk '{sub(/\/.*/,"",$3); print $3}'; }
serve() {
	local p=${1:-8000} ip=$(tun0)
	echo "http://${ip:-localhost}:$p/"
	python3 -m http.server "$p"
}
listen() { rlwrap -cAr nc -lvnp "${1:-4444}"; }
urlenc() { python3 -c 'import sys,urllib.parse as u;print(u.quote(sys.argv[1],safe=""))' "$*"; }
urldec() { python3 -c 'import sys,urllib.parse as u;print(u.unquote(sys.argv[1]))' "$*"; }
bwf() {
	local e clip=pbcopy
	(( $+commands[wl-copy] )) && clip=wl-copy
	e=$(rbw list | fzf) || return
	rbw get "$e" | $clip
}

# Esc Esc: prepend sudo to the line (or the last command if empty)
sudo-line() { [[ -z $BUFFER ]] && BUFFER=$history[$((HISTCMD-1))]; [[ $BUFFER == sudo\ * ]] || BUFFER="sudo $BUFFER"; CURSOR=$#BUFFER; }
zle -N sudo-line && bindkey '\e\e' sudo-line
