# dotfiles

My terminal setup for Linux, macOS and Windows, managed with [chezmoi](https://www.chezmoi.io). One command turns a fresh machine into the same shell, prompt, editor, colors and tools I use everywhere. On a bare box with nothing but `zsh`, it still starts cleanly.

- **One palette everywhere.** Pick a color scheme once and the terminal, tmux, fzf, bat, btop, yazi and Neovim follow.
- **Tools installed for you.** A single list in [mise](https://mise.jdx.dev) installs everything, the same way on every OS.
- **Safe to re-run.** Applying twice changes nothing. Updating another machine is one command.
- **Degrades gracefully.** Missing tools are skipped, not errors.

## Install

> Run each command on its own. Pasting several at once lets the prompts (git name, email) swallow the next line.

**Linux and macOS**

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/noahm-05/dotfiles/main/install.sh)"
```

The script asks `1) GUI machine` or `2) Headless`, installs the base packages (needs `sudo`), installs chezmoi, applies everything, and makes zsh your login shell. It also asks for your git name and email. When it finishes, **log out and back in**.

| | Needs |
|---|---|
| Linux | Debian or Ubuntu (apt), `sudo`, `curl` |
| macOS | [Homebrew](https://brew.sh) installed first |
| GUI machine | Adds Ghostty, the Nerd Font and tinty. Skip the menu with `DOTFILES_GUI=1`, or `DOTFILES_GUI=0` for headless, in front of the command |

**Windows** (PowerShell)

```powershell
winget install Git.Git twpayne.chezmoi
```

Open a new terminal, then:

```powershell
chezmoi init https://github.com/noahm-05/dotfiles.git
```

```powershell
winget import -i "$HOME\.local\share\chezmoi\packages\winget.json"
```

```powershell
chezmoi apply
```

Install [JetBrainsMono Nerd Font](https://www.nerdfonts.com/font-downloads) by hand, then in Windows Terminal set **PowerShell (dotfiles)** as the default profile.

**Already have dotfiles?** Move them aside first. chezmoi writes real files, so if `~/.zshenv` or `~/.config/zsh` is a symlink into another repo, applying would edit that repo. Remove the symlinks (`rm` on a link leaves its target alone), then install.

Prefer to see every step, or install offline? See [docs/manual-install.md](docs/manual-install.md).

## After installing

1. Log out and back in so zsh is your login shell. The first prompt may pause once while Powerlevel10k downloads its git helper.
2. GUI machines: run `tinty install` once. It downloads the color themes.
3. Using Bitwarden? [`rbw`](https://github.com/doy/rbw) needs a pinentry program, see [below](#rbw-needs-a-pinentry-program).

## Daily use

| Keys | What it does |
|---|---|
| `Esc Esc` | Put `sudo` in front of the line (or the last command, if the line is empty) |
| `Ctrl-R` / `Ctrl-T` / `Alt-C` | Fuzzy search history / files / directories |
| `Tab` | Completion as a fuzzy menu |
| `z proj` | Jump to a directory you've used before |
| `Ctrl-B` then `\|` / `-` | tmux: split right / below |
| `Ctrl-B` then `P` | tmux: start or stop logging this pane to `~/logs` |
| `Ctrl-B` then `T` | tmux: pick a session or project with sesh |
| `Ctrl-B` then `r` | tmux: reload the config |

| Command | What it does |
|---|---|
| `ll`, `la`, `lt` | List files: long, all, tree |
| `lg` | lazygit |
| `y` | yazi file manager, and `cd` to where you quit |
| `serve [port]` | Web server in this folder, prints your VPN address |
| `listen [port]` | Netcat listener with arrow keys |
| `tun0` | Print your VPN IP (Linux) |
| `urlenc`, `urldec` | URL-encode or decode text |
| `bwf` | Pick a password from `rbw` and copy it |
| `ports`, `ipa` | Listening ports, IP addresses (Linux) |
| `dots` | Open a shell in this repo's local clone |
| `reload` | Restart zsh |

## Make it yours

Your home directory holds **copies** of these files, so edit them through chezmoi and the change lands in this repo:

```sh
chezmoi edit ~/.config/tmux/tmux.conf   # edit the source file
chezmoi diff                            # preview what would change
chezmoi apply                           # apply it
dots                                    # go to the repo, then: git add -A && git commit && git push
```

| I want to... | Do this |
|---|---|
| Add a tool | `chezmoi edit ~/.config/mise/config.toml`, add `toolname = "latest"`, then `chezmoi apply`. Find names with `mise search` |
| Change the color scheme | `tinty gallery` (web page), or `tinty list` then `tinty apply base16-<name>`. `tinty apply base16-isotope` goes back to Isotope |
| Add machine-only settings | Put them in `~/.config/zsh/local.zsh`. It is never committed |
| Tweak the prompt | `chezmoi edit ~/.config/zsh/.p10k.zsh` (Linux, macOS). On Windows it is `~/.config/starship.toml` |
| Edit Neovim | Your changes go in `lua/custom/`. kickstart.nvim itself is never edited |
| Pull changes on another machine | `chezmoi update`, then `mise up` for the tools |

How colors flow: Isotope is defined once in `.chezmoidata/palette.toml`. tinty sets the terminal's 16 colors, and tmux, bat, delta, eza, yazi, lazygit, btop, fzf and the prompt all use those, so they change together. Neovim reads tinty's current scheme when it starts. tinty runs on Linux and macOS GUI machines only.

More detail, including what every file does, is in [docs/how-it-works.md](docs/how-it-works.md).

## What's included

### Shell and prompt

| | What it does |
|---|---|
| [zsh](https://zsh.sourceforge.io/Doc/) | The shell, with a 100k-entry shared history |
| [Powerlevel10k](https://github.com/romkatv/powerlevel10k) | The prompt on Linux and macOS |
| [Starship](https://starship.rs/config/) | The prompt on Windows |
| [fzf-tab](https://github.com/Aloxaf/fzf-tab) | Tab completion as a fuzzy menu |
| [zsh-autopair](https://github.com/hlissner/zsh-autopair) | Auto-closes `(`, `[` and quotes |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Commands turn red before you hit Enter if they don't exist |
| [PowerShell 7](https://learn.microsoft.com/powershell/) | The Windows shell, set up to match |

### Terminal, multiplexer and theme

| | What it does |
|---|---|
| [Ghostty](https://ghostty.org/docs) | Terminal on Linux and macOS (GUI machines) |
| [Windows Terminal](https://learn.microsoft.com/windows/terminal/) | Terminal on Windows |
| [tmux](https://github.com/tmux/tmux/wiki) | Sessions and panes (Linux and macOS) |
| [tinty](https://github.com/tinted-theming/tinty) | Switches color schemes (GUI machines) |
| [Isotope](https://github.com/tinted-theming/home) | The default color scheme |
| [JetBrainsMono Nerd Font](https://www.nerdfonts.com) | The font |

### Everyday tools (installed by mise)

| | What it does |
|---|---|
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `cd` that learns |
| [ripgrep](https://github.com/BurntSushi/ripgrep), [fd](https://github.com/sharkdp/fd) | Fast replacements for grep and find |
| [bat](https://github.com/sharkdp/bat), [eza](https://eza.rocks) | Better `cat` and `ls` |
| [yazi](https://yazi-rs.github.io/docs/quick-start) | File manager with previews |
| [jq](https://jqlang.org/manual/) | Work with JSON |
| [btop](https://github.com/aristocratos/btop), [tealdeer](https://tealdeer-rs.github.io/tealdeer/) | System monitor, and short `tldr` man pages |
| [lazygit](https://github.com/jesseduffield/lazygit), [delta](https://dandavison.github.io/delta/) | Git TUI and readable diffs |
| [sesh](https://github.com/joshmedeski/sesh) | Session picker |
| [doggo](https://doggo.mrkaran.dev), [trippy](https://trippy.cli.rs) | DNS lookups, and a traceroute + ping TUI |
| [rbw](https://github.com/doy/rbw) | Bitwarden CLI (installed by mise on Linux, by brew on macOS) |

On Windows, mise installs the ones that exist there. sesh, tinty, btop and rbw are skipped.

### Editors

| | What it does |
|---|---|
| [nano](https://www.nano-editor.org/docs.php) | Default editor |
| [Neovim](https://neovim.io/doc/) with [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) | Ready when you want it |

### Base packages (from apt, brew or winget)

[ansifilter](https://gitlab.com/saalen/ansifilter) cleans tmux logs, [rlwrap](https://github.com/hanslub42/rlwrap) gives arrow keys in netcat shells, [ncdu](https://dev.yorhel.nl/ncdu) finds what's using disk, and [pipx](https://pipx.pypa.io) installs Python tools. The lists are in [`packages/`](packages/).

### rbw needs a pinentry program

`rbw` asks for your master password through a pinentry program. Nothing installs one for you on Linux, so without it `rbw unlock` fails with a pinentry error.

| Setup | Install | Then |
|---|---|---|
| Headless (SSH) | `sudo apt install pinentry-curses` | `rbw config set pinentry pinentry-curses` |
| Linux desktop | `sudo apt install pinentry-gnome3` | `rbw config set pinentry pinentry-gnome3` |
| macOS | Comes with rbw (terminal prompt). For the native dialog: `brew install pinentry-mac` | `rbw config set pinentry pinentry-mac` |

## Platform notes

- **Windows** gets PowerShell, Windows Terminal, git and the mise tools. It does not get zsh, tmux, Ghostty or tinty, because they don't run natively there. For tmux, use Windows Terminal's own panes (`Alt+Shift+-` and `Alt+Shift+Plus`), or install WSL and run the Linux install inside it.
- **macOS** needs Homebrew. The font and Ghostty come from brew casks. If a new color scheme doesn't show at once, press `Cmd+Shift+,` to reload Ghostty.
- **Linux** is tested on Debian 13. Other apt-based distros should work. Ghostty comes from the free [griffo.io](https://deb-free.griffo.io) apt mirror, added after its signing key is checked.

## Troubleshooting

| Problem | Fix |
|---|---|
| Plain prompt, tools missing | Run `mise install`, then open a new shell |
| Still in bash after install | `chsh -s "$(command -v zsh)"`, then log out and in |
| `git commit` says identity unknown | `chezmoi init --prompt` to re-enter name and email, then `chezmoi apply` |
| tinty says a theme path doesn't exist | Run `tinty install` |
| Ghostty shows a config error | Run `ghostty +validate-config` |
| Wrong colors over SSH | In Ghostty: `infocmp -x xterm-ghostty \| ssh host -- tic -x -` |
| `chezmoi apply` wants to overwrite files | Back up the old ones first. See "Already have dotfiles?" above |
| `rbw unlock` fails | Install a pinentry program, see above |

## More

- [How it works](docs/how-it-works.md): how chezmoi manages everything, and what each tool and setting is for
- [Manual install](docs/manual-install.md): step-by-step, offline and non-interactive installs
- [Build notes](docs/build-notes.md): decisions, deviations and open items

## Status

Tested on Debian 13 (headless and GNOME desktop in a VM), macOS (Apple Silicon) and Windows 11. Not yet tested: the one-line installer on a completely bare machine.
