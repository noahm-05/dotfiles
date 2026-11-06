# dotfiles

chezmoi repo for Linux, macOS and Windows. See `BUILD_NOTES.md` for assumptions
and unverified items.

## Install

Linux / macOS (needs `curl`):

    sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply noahm-05/dotfiles

Bare box without curl (pick one; none of these were tested here):

    apt install chezmoi                       # if your release packages it
    wget -qO- get.chezmoi.io | sh             # wget instead of curl
    # offline: copy a chezmoi release binary (or .deb) from another machine, then
    chezmoi init --apply --source /media/<stick>/dotfiles

Windows (PowerShell): `winget install twpayne.chezmoi`, then
`chezmoi init --apply noahm-05/dotfiles`.

Non-interactive: `chezmoi init --apply --promptBool gui=true --promptString name=...,email=...`.

Day to day: `chezmoi update` (configs + plugin refresh), `mise up` (tools).

## Base layer (run once, needs root; nothing installs this for you)

    # Debian / Ubuntu
    sudo apt install zsh git curl tmux nano unzip ansifilter rlwrap ncdu python3 pipx
    # macOS
    brew install zsh git curl tmux nano unzip ansifilter rlwrap ncdu python3 pipx
    # Windows
    winget install Microsoft.PowerShell Git.Git twpayne.chezmoi

Then `chezmoi apply` installs mise and runs `mise install` (re-runs only when
`dot_config/mise/config.toml.tmpl` changes).

## GUI machines (gui=true)

- Ghostty: Debian 13 install method is an open item (not in Debian repos);
  record it here once found. macOS: `brew install --cask ghostty`.
- Font: Linux, fetched by chezmoi (JetBrainsMono Nerd Font tarball into
  `~/.local/share/fonts`; run `fc-cache -f` once). macOS:
  `brew install --cask font-jetbrains-mono-nerd-font`. Windows: open item
  (winget package vs. zip).
- Before the first apply on the old ThinkPad: remove the dotbot symlinks and
  take a snapper snapshot.

## Windows Terminal

The fragment adds the Isotope scheme and a pwsh profile. Set that profile as
default by hand once (fragments cannot change the default).

## Open items (unresolved on purpose)

Ghostty on Debian 13; tinty x86_64 via mise `github:` backend; mise resolving
yazi/eza/delta/lazygit/doggo/trippy on Windows; Windows Terminal honoring
fragment `schemes`; Nerd Font on Windows; keep or cut the Starship `tun0`
module after a week.
