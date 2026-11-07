# dotfiles

My terminal setup for Linux, macOS and Windows, managed with [chezmoi](https://www.chezmoi.io). One command turns a fresh machine into the same shell, prompt, editor and tools I use everywhere. On a bare box with nothing but `zsh`, it still starts cleanly.

## Install

**Linux and macOS**

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/noahm-05/dotfiles/main/install.sh)"
```

The script asks `1) GUI machine` or `2) Headless`, then installs the base packages (needs `sudo`), installs chezmoi, applies everything, and makes zsh your login shell. It also asks for your git name and email. When it finishes, log out and back in.

- macOS needs [Homebrew](https://brew.sh) first.
- Linux must be Debian or Ubuntu (apt).
- Skip the menu with `DOTFILES_GUI=1` or `DOTFILES_GUI=0` in front of the command.

**Windows** (PowerShell)

```powershell
winget install Git.Git twpayne.chezmoi
chezmoi init https://github.com/noahm-05/dotfiles.git
winget import -i "$HOME\.local\share\chezmoi\packages\winget.json"
chezmoi apply
```

Open a new terminal after the first command. Then install [JetBrainsMono Nerd Font](https://www.nerdfonts.com/font-downloads) by hand and set the "PowerShell (dotfiles)" profile as the default in Windows Terminal.

Want to see each step, or install offline? See [docs/manual-install.md](docs/manual-install.md).

## Changing things later

Your home directory holds **copies** of these files. Edit them through chezmoi so changes land in this repo:

```sh
chezmoi edit ~/.config/tmux/tmux.conf   # edit the source file
chezmoi diff                            # preview
chezmoi apply                           # apply
dots                                    # open the repo, then: git add -A && git commit && git push
```

On other machines, `chezmoi update` pulls and applies, and `mise up` updates the tools. Anything machine-specific goes in `~/.config/zsh/local.zsh`, which is never committed. The full explanation is in [docs/how-it-works.md](docs/how-it-works.md).

## What's included

### Shell and prompt

| | What it does |
|---|---|
| [zsh](https://zsh.sourceforge.io/Doc/) | The shell, with a 100k-entry shared history |
| [Powerlevel10k](https://github.com/romkatv/powerlevel10k) | The prompt on Linux and macOS. Settings are in `~/.config/zsh/.p10k.zsh` |
| [Starship](https://starship.rs/config/) | The prompt on Windows (PowerShell) |
| [fzf-tab](https://github.com/Aloxaf/fzf-tab) | Tab completion as a fuzzy menu |
| [zsh-autopair](https://github.com/hlissner/zsh-autopair) | Auto-closes `(`, `[` and quotes |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Commands turn red before you hit Enter if they don't exist |
| [PowerShell 7](https://learn.microsoft.com/powershell/) | The Windows shell, set up to match |

### Terminal, multiplexer and theme

| | What it does |
|---|---|
| [Ghostty](https://ghostty.org/docs) | Terminal on Linux and macOS (GUI machines) |
| [Windows Terminal](https://learn.microsoft.com/windows/terminal/) | Terminal on Windows |
| [tmux](https://github.com/tmux/tmux/wiki) | Sessions and panes. `Ctrl-B P` logs a pane to `~/logs` |
| [tinty](https://github.com/tinted-theming/tinty) | Switches color schemes (GUI machines). Run `tinty install` once first |
| [Isotope](https://github.com/tinted-theming/home) | The color scheme, defined once in `.chezmoidata/palette.toml` |
| [JetBrainsMono Nerd Font](https://www.nerdfonts.com) | The font |

### Everyday tools (installed by [mise](https://mise.jdx.dev))

| | What it does |
|---|---|
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder: `Ctrl-R` history, `Ctrl-T` files, `Alt-C` cd |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `cd` that learns: `z proj` |
| [ripgrep](https://github.com/BurntSushi/ripgrep), [fd](https://github.com/sharkdp/fd) | Fast replacements for grep and find |
| [bat](https://github.com/sharkdp/bat), [eza](https://eza.rocks) | Better `cat` and `ls` (`ll`, `la`, `lt`) |
| [yazi](https://yazi-rs.github.io/docs/quick-start) | File manager with previews. Run `y` |
| [jq](https://jqlang.org/manual/) | Work with JSON |
| [btop](https://github.com/aristocratos/btop), [tealdeer](https://tealdeer-rs.github.io/tealdeer/) | System monitor, and short `tldr` man pages |
| [lazygit](https://github.com/jesseduffield/lazygit), [delta](https://dandavison.github.io/delta/) | Git TUI (`lg`) and readable diffs |
| [sesh](https://github.com/joshmedeski/sesh) | Session picker. `Ctrl-B T` in tmux |
| [doggo](https://doggo.mrkaran.dev), [trippy](https://trippy.cli.rs) | DNS lookups, and a traceroute + ping TUI |
| [rbw](https://github.com/doy/rbw) | Bitwarden CLI (mise on Linux, brew on macOS). Needs a pinentry program, see below |

**rbw needs a pinentry program** to ask for your master password. Nothing installs one for you, so without it `rbw unlock` fails with a pinentry error. Install one for your setup:

| Setup | Install | Then |
|---|---|---|
| Headless (SSH) | `sudo apt install pinentry-curses` (or `pinentry-tty`) | `rbw config set pinentry pinentry-curses` |
| Linux desktop | `sudo apt install pinentry-gnome3` | `rbw config set pinentry pinentry-gnome3` |
| macOS | Already installed with rbw (terminal prompt). For the native dialog: `brew install pinentry-mac` | `rbw config set pinentry pinentry-mac` |

### Editors

| | What it does |
|---|---|
| [nano](https://www.nano-editor.org/docs.php) | Default editor |
| [Neovim](https://neovim.io/doc/) with [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) | Ready when you want it. Your changes go in `lua/custom/` |

### Base packages (from apt, brew or winget)

[ansifilter](https://gitlab.com/saalen/ansifilter) cleans tmux logs, [rlwrap](https://github.com/hanslub42/rlwrap) gives arrow keys in netcat shells, [ncdu](https://dev.yorhel.nl/ncdu) finds what's using disk, and [pipx](https://pipx.pypa.io) installs Python tools. The lists are in [`packages/`](packages/).

## Handy commands

| Command | What it does |
|---|---|
| `ll`, `la`, `lt` | List files (long, all, tree) |
| `lg` | Open lazygit |
| `y` | Open yazi, and cd to where you quit |
| `serve [port]` | Web server in this folder, prints your VPN address |
| `listen [port]` | Netcat listener with arrow keys |
| `tun0` | Print your VPN IP |
| `urlenc`, `urldec` | URL-encode or decode text |
| `bwf` | Pick a password from `rbw` and copy it |
| `dots` | Open this repo's local clone |
| `reload` | Restart zsh |

tmux uses the default `Ctrl-B` prefix. `prefix |` and `prefix -` split panes, `prefix r` reloads the config.

## Troubleshooting

| Problem | Fix |
|---|---|
| Plain prompt, tools missing | Run `mise install`, then open a new shell |
| Still in bash after install | `chsh -s "$(command -v zsh)"`, then log out and in |
| Ghostty shows a config error | Run `ghostty +validate-config` |
| Wrong colors over SSH | In Ghostty: `infocmp -x xterm-ghostty \| ssh host -- tic -x -` |

## More

- [How it works](docs/how-it-works.md): how chezmoi manages everything, and what each tool and setting is for
- [Manual install](docs/manual-install.md): step-by-step, offline and non-interactive installs
- [Build notes](docs/build-notes.md): decisions, deviations and open items

## Status

Tested on Debian 13 (headless and GNOME desktop in a VM), macOS (Apple Silicon) and Windows 11.
