# dotfiles

A [chezmoi](https://www.chezmoi.io) repo that turns a Linux, macOS or Windows machine into one consistent terminal environment with a single command. It is built for daily IT/security work and HTB/CPTS study, and it **degrades gracefully**: on a bare box with only `zsh` and `git`, the shell still loads with zero errors and a fallback prompt.

| | |
|---|---|
| **Shell** | zsh (Linux, macOS), PowerShell 7 (Windows) |
| **Prompt** | [Starship](https://starship.rs), one line, shows only what matters right now |
| **Terminal** | [Ghostty](https://ghostty.org) (Linux, macOS), Windows Terminal |
| **Theme** | Isotope (base16), one palette file feeds every renderer |
| **Multiplexer** | tmux, default `Ctrl-B` prefix, toggleable pane logging |
| **Editor** | nano by default, Neovim ([kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)) ready |
| **CLI tools** | installed and updated by [mise](https://mise.jdx.dev) from one list |

How it works, and what every tool and plugin is for: [docs/how-it-works.md](docs/how-it-works.md).

## Install

### Quick install (Linux and macOS)

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/noahm-05/dotfiles/main/install.sh)"
```

The script asks **1) GUI machine** or **2) Headless**, then installs the base packages (it asks for your `sudo` password), installs chezmoi, applies the dotfiles and sets zsh as your login shell. chezmoi will also ask for your git name and email. On a GUI Debian/Ubuntu machine it also installs Ghostty from the free [griffo.io](https://deb-free.griffo.io) apt mirror, checking the repo's signing-key fingerprint first.

Skip the menu with `DOTFILES_GUI=1` (GUI) or `DOTFILES_GUI=0` (headless):

```sh
DOTFILES_GUI=0 sh -c "$(curl -fsSL https://raw.githubusercontent.com/noahm-05/dotfiles/main/install.sh)"
```

macOS needs Homebrew installed first. The script only supports apt-based Linux; for Windows, use the steps below. Read the script before running it: [install.sh](install.sh).

### Manual install

Every OS follows the same three steps: install `git` and chezmoi, install the base packages from this repo's `packages/` folder (needs root, so it is a separate step), then apply. chezmoi asks three questions once: is this a GUI machine, your git name, your git email.

The commands below clone the repo into `~/.local/share/chezmoi`, which is where `packages/` ends up. The repo is public and cloned over HTTPS, so no GitHub account, `gh` login or SSH key is needed.

Run each command on its own. Pasting several at once makes the later lines get typed into chezmoi's prompts.

### Debian / Ubuntu

```sh
sudo apt install -y git curl
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin init https://github.com/noahm-05/dotfiles.git
xargs -a ~/.local/share/chezmoi/packages/apt.txt sudo apt install -y
~/.local/bin/chezmoi apply
```

### macOS

```sh
brew install git chezmoi
chezmoi init https://github.com/noahm-05/dotfiles.git
brew bundle --file ~/.local/share/chezmoi/packages/Brewfile
brew bundle --file ~/.local/share/chezmoi/packages/Brewfile.gui   # GUI machines: Ghostty + font
chezmoi apply
```

Homebrew itself must already be installed: https://brew.sh.

### Windows (PowerShell)

```powershell
winget install Git.Git twpayne.chezmoi
# open a new terminal so git and chezmoi are on PATH
chezmoi init https://github.com/noahm-05/dotfiles.git
winget import -i "$HOME\.local\share\chezmoi\packages\winget.json" --accept-package-agreements --accept-source-agreements
chezmoi apply
```

Install JetBrainsMono Nerd Font by hand (no automated method yet), then set the "PowerShell (dotfiles)" profile as the Windows Terminal default once.

### Offline / flash drive

Copy the repo to the drive, then use `--source` in place of the repo URL and run the package step from the drive's `packages/` folder:

```sh
chezmoi init --source /media/<stick>/dotfiles
xargs -a /media/<stick>/dotfiles/packages/apt.txt sudo apt install -y
chezmoi apply
```

### Non-interactive (servers, VMs, CI)

Replace the `init` step with:

```sh
chezmoi init --promptDefaults \
  --promptBool "GUI machine (Ghostty, tinty, font)=false" \
  --promptString "Git name=Your Name,Git email=you@example.com" \
  https://github.com/noahm-05/dotfiles.git
```

### What the package files contain

| File | Used by | Contents |
|---|---|---|
| `packages/apt.txt` | Debian / Ubuntu | `zsh git curl tmux nano unzip ansifilter rlwrap ncdu python3 pipx` |
| `packages/Brewfile` | macOS | the same list, plus chezmoi |
| `packages/Brewfile.gui` | macOS, GUI machines | Ghostty and JetBrainsMono Nerd Font |
| `packages/winget.json` | Windows | PowerShell 7, Git, chezmoi |

`ansifilter` strips color and cursor escape codes from tmux pane logs. Everything else (mise, the CLI tools, zsh plugins, kickstart.nvim, the Linux font) is fetched by `chezmoi apply`, so it is not in these files. Add or remove a base package by editing the file for that OS. These files are not deployed to your home directory.

**Ghostty on Debian/Ubuntu** (GUI machines) is not in Debian's repos. `install.sh` adds the free griffo.io mirror; to do it by hand:

```sh
sudo apt install -y gpg
curl -fsSL https://deb-free.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc -o /tmp/griffo.asc
gpg --show-keys --with-fingerprint /tmp/griffo.asc   # must show EA0F 721D 231F DD3A 0A17  B9AC 7808 B4DD 62C4 1256
sudo install -d -m 0755 /etc/apt/keyrings
sudo gpg --dearmor --yes -o /etc/apt/keyrings/deb-free.griffo.io.gpg /tmp/griffo.asc
echo "deb [signed-by=/etc/apt/keyrings/deb-free.griffo.io.gpg] https://deb-free.griffo.io/apt $(. /etc/os-release; echo $VERSION_CODENAME) main" | sudo tee /etc/apt/sources.list.d/deb-free.griffo.io.list
sudo apt update && sudo apt install -y ghostty
```

This is a single maintainer's repo, and the free mirror lags upstream by up to two months. Run `fc-cache -f` once after the font is fetched.

Finally, make zsh your login shell with `chsh -s "$(command -v zsh)"` and log in again (`install.sh` does this for you).

## Day to day

```sh
chezmoi update   # pull the repo, apply configs, refresh plugins
mise up          # update CLI tools
chezmoi diff     # preview what an apply would change
dots             # cd into this repo's local clone
reload           # restart zsh
```

Machine-only settings go in `~/.config/zsh/local.zsh`. It is sourced if present and never committed.

## What you get

### CLI tools (mise)

| Tool | Use |
|---|---|
| fzf, zoxide | fuzzy finder; `cd` that learns (`z proj`, `zi`) |
| ripgrep, fd | fast grep and find |
| bat, eza | `cat` and `ls` with highlighting, git status and tree view |
| yazi | file manager with previews (`y` cd's on exit) |
| jq, doggo, trippy | JSON, DNS lookups, traceroute + ping TUI |
| btop, tealdeer | system monitor; example-first man pages (`tldr`) |
| neovim, lazygit, delta | editor, git TUI (`lg`), readable diffs |
| starship, sesh | prompt; tmux/zoxide session picker |
| tinty | theme switcher (GUI machines only) |

Windows skips sesh and tinty.

### Aliases and functions

No alias ever shadows a builtin, and each is defined only if its tool exists.

`ll` `la` `lt` (eza) · `lg` (lazygit) · `..` `...` · `ports` · `ipa` · `dots` · `reload`
`y` (yazi) · `tun0` (VPN IP) · `serve [port]` · `listen [port]` · `urlenc` / `urldec` · `bwf` (rbw picker)

### Key bindings

| Keys | Action |
|---|---|
| `Ctrl-B` | tmux prefix |
| `Ctrl-R` / `Ctrl-T` / `Alt-C` | fzf history / insert path / cd |
| `Tab` | fzf-tab fuzzy completion |
| `prefix` `P` | toggle pane logging to `~/logs/` (status bar shows `● REC`) |
| `prefix` `T` | sesh session picker |
| `prefix` `\|` / `-` | split right / below |
| `prefix` `r` | reload tmux config |
| `Ctrl-Space` | unused, left to macOS input switching |

## Repository layout

```
.chezmoi.toml.tmpl            first-run prompts (gui, name, email)
.chezmoidata/palette.toml     the one copy of the Isotope palette
.chezmoiexternal.toml.tmpl    zsh plugins, kickstart.nvim, Nerd Font
.chezmoiignore.tmpl           per-OS and gui/headless file filtering
run_onchange_after_install-mise.*   installs mise, runs `mise install`
dot_zshenv                    sets XDG vars and ZDOTDIR (the only file in ~)
dot_config/                   zsh, tmux, starship, git, mise, yazi, nano, nvim, ghostty, tinty
dot_local/share/tinted-theming/     custom base16 scheme
Documents/PowerShell/         PowerShell profile (Windows)
AppData/Local/.../Fragments/  Windows Terminal color scheme + profile
docs/                         documentation (not deployed)
```

## Customizing

- **Add or remove a CLI tool:** edit `dot_config/mise/config.toml.tmpl`, then `chezmoi apply`. The installer re-runs when that file changes.
- **Change the palette:** edit `.chezmoidata/palette.toml`, then `chezmoi apply`. Ghostty, Windows Terminal, tinty and Neovim all re-render from it.
- **Neovim changes:** put them in `dot_config/nvim/lua/custom/`. kickstart.nvim is an external and is never edited.
- **Switch the default editor:** change `EDITOR`/`VISUAL` in `dot_config/zsh/dot_zshrc`.

## Troubleshooting

| Symptom | Fix |
|---|---|
| Shell prompt looks plain | Starship isn't installed yet. Run `mise install`, open a new shell. |
| `mise: command not found` after apply | Open a new shell; mise installs to `~/.local/bin`. |
| `chezmoi apply` warns `curl missing` | Install the base packages (see Install), then re-run `chezmoi apply`. |
| Tools missing in scripts / nvim LSPs | mise is activated for interactive shells only (no shims). |
| Ghostty can't find the theme | `gui` was false at init. Re-run `chezmoi init` and answer yes. |
| Over SSH, colors or backspace are wrong | From Ghostty's shell: `infocmp -x xterm-ghostty \| ssh host -- tic -x -` |

## Known gaps

Tracked in [docs/build-notes.md](docs/build-notes.md): Nerd Font on Windows, mise tool resolution on Windows, Windows Terminal honoring fragment schemes, and whether to keep the Starship `tun0` module.

## Migrating from the old dots TUI (ThinkPad)

Remove the old dotbot symlinks in `~` and take a snapper snapshot **before** the first `chezmoi init --apply`. chezmoi will not silently overwrite files, but a half-migrated home is miserable to debug.

## Status

Verified: `chezmoi init --apply` on Linux with `gui=true` and `gui=false` in a throwaway home, interactive zsh without errors, all mise tools resolving. Not yet verified: macOS, Windows, bare Debian VM, tmux logging with real `ansifilter`, Ghostty on screen.
