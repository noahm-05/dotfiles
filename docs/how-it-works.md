# How this repo works

This document explains how chezmoi manages the machine, what is managed, and what each tool, plugin and customization is for.

## 1. How chezmoi manages everything

### The model

chezmoi keeps a **source directory** (this repo, cloned to `~/.local/share/chezmoi`) and computes a **target state** from it: the files that should exist in your home directory. `chezmoi apply` compares the target state with what is actually on disk and changes only what differs. Nothing is symlinked. Files are real copies, so a half-applied repo can never leave dangling links.

```
 repo (source)            templates + data            home (destination)
 dot_config/zsh/...  ──►  rendered per machine  ──►  ~/.config/zsh/...
 .chezmoidata/        ──►  variables              
 .chezmoiexternal     ──►  downloaded archives ──►  ~/.config/zsh/plugins/...
 run_onchange_*       ──►  scripts run when their content changes
```

### Naming conventions (the "magic" file names)

chezmoi reads attributes from file name prefixes and suffixes.

| Name | Meaning | Example here |
|---|---|---|
| `dot_` | target name starts with `.` | `dot_zshenv` → `~/.zshenv`; `dot_config/` → `~/.config/` |
| `.tmpl` suffix | file is a Go template, rendered before writing | `config.toml.tmpl` |
| `create_` | write only if the target does **not** exist | `create_tinted-theming.tmpl`, so tinty can later overwrite the theme and chezmoi won't undo it |
| `run_onchange_` | script runs when its rendered content changes | `run_onchange_after_install-mise.sh.tmpl` |
| `after_` | script runs after files are written | needed so the mise config exists before `mise install` |
| `.chezmoi*` files | chezmoi's own control files, never deployed | `.chezmoiignore.tmpl` |

Folders that are not `dot_` mapped (`Documents/`, `AppData/`) deploy to the same path under `~`, which is how the Windows files land correctly.

### The control files

**`.chezmoi.toml.tmpl`** runs once at `chezmoi init`. It asks three questions (`gui`, git `name`, git `email`) with `promptBoolOnce`/`promptStringOnce`, and writes the answers to `~/.config/chezmoi/chezmoi.toml`. "Once" means chezmoi reuses saved answers on later runs instead of asking again. Defaults exist so non-interactive runs never hang.

**`.chezmoidata/palette.toml`** is static data available to every template as `.palette`. It holds the 16 Isotope colors. This is the single source of truth for colors.

**`.chezmoiignore.tmpl`** is a template that outputs a list of target paths to skip. It is how one repo serves four machine types:

- On Windows it skips zsh, tmux, nano, nvim, Ghostty, tinty and `.zshenv`.
- On Linux/macOS it skips `Documents/`, `AppData/` and the PowerShell installer.
- When `gui` is false it skips Ghostty, tinty, the custom scheme and fonts.
- It always skips `README.md`, `docs/` and repo-only files, so they are never deployed.

Patterns are written as **target** names (`.config/ghostty`), not source names (`dot_config/ghostty`).

**`.chezmoiexternal.toml.tmpl`** declares things chezmoi downloads rather than stores. Each entry is an `archive` external: chezmoi fetches a tarball, extracts it into the target path, and refreshes it every `refreshPeriod` (168 h for plugins, 720 h for the font). Archives need no `git` on the machine and no plugin manager.

**`run_onchange_after_install-mise.*`** are the only scripts. The first line after the shebang embeds a hash of the rendered mise config:

```
# tool list hash: {{ includeTemplate "dot_config/mise/config.toml.tmpl" . | sha256sum }}
```

chezmoi stores a hash of each script it has run. When the tool list (including the `gui`/OS conditionals) changes, the script's content changes, so it runs again. If nothing changed, it is skipped, which keeps `chezmoi apply` fast.

### Layers of a run

`chezmoi init --apply <repo>` does, in order:

1. Clones the repo to `~/.local/share/chezmoi`.
2. Renders `.chezmoi.toml.tmpl`, asking the three questions, and saves the answers.
3. Loads `.chezmoidata/`, evaluates the ignore file for this OS and `gui` value.
4. Writes managed files (templates rendered with the data above).
5. Downloads externals (zsh plugins, kickstart.nvim, font).
6. Runs `run_onchange_after_*` scripts: installs mise, then `mise install`.

`chezmoi update` = `git pull` in the source + `chezmoi apply`. That is also how plugins refresh: externals past their `refreshPeriod` are re-downloaded.

### Why no symlinks, no plugin manager

- **Copies, not links:** the repo can move or vanish and the machine keeps working. chezmoi shows drift with `chezmoi diff` and refuses to silently overwrite files you edited elsewhere.
- **Externals instead of a zsh plugin manager:** three plugins don't justify oh-my-zsh, antidote or similar. A tarball plus a `source` line is the whole mechanism.
- **mise instead of per-OS package managers:** one tool list works on Linux, macOS and Windows. apt/brew/winget only provide the base layer.

## 2. What is managed

| Area | Source file(s) | Deployed to | Machines |
|---|---|---|---|
| zsh bootstrap | `dot_zshenv` | `~/.zshenv` | Linux, macOS |
| zsh config | `dot_config/zsh/{dot_zshrc,aliases.zsh,functions.zsh}` | `~/.config/zsh/` | Linux, macOS |
| zsh plugins | `.chezmoiexternal` | `~/.config/zsh/plugins/` | Linux, macOS |
| Prompt | `dot_config/starship.toml` | `~/.config/starship.toml` | all |
| tmux | `dot_config/tmux/tmux.conf` | `~/.config/tmux/` | Linux, macOS |
| nano | `dot_config/nano/nanorc` | `~/.config/nano/` | Linux, macOS |
| Neovim | external + `palette.lua.tmpl`, `plugin/custom.lua`, `lua/custom/` | `~/.config/nvim/` | Linux, macOS |
| git | `dot_config/git/config.tmpl` | `~/.config/git/config` | all |
| yazi | `dot_config/yazi/yazi.toml` | `~/.config/yazi/` | all |
| mise tool list | `dot_config/mise/config.toml.tmpl` | `~/.config/mise/config.toml` | all |
| Ghostty | `dot_config/ghostty/config`, `themes/create_tinted-theming.tmpl` | `~/.config/ghostty/` | GUI Linux/macOS |
| tinty | `dot_config/tinted-theming/tinty/config.toml`, custom scheme | `~/.config/tinted-theming/`, `~/.local/share/tinted-theming/` | GUI Linux/macOS |
| Nerd Font | external | `~/.local/share/fonts/` | GUI Linux |
| PowerShell | `Documents/PowerShell/...profile.ps1` | `~/Documents/PowerShell/` | Windows |
| Windows Terminal | `AppData/.../Fragments/dotfiles/isotope.json.tmpl` | same path | Windows |
| Tool installers | `run_onchange_after_install-mise.{sh,ps1}.tmpl` | (run, not deployed) | all |

Only `~/.zshenv` lives directly in `~`. Everything else is under XDG locations.

### The color flow: one palette, four renderers

```
.chezmoidata/palette.toml  (Isotope, blue lifted to #3388ff)
   ├─► ghostty/themes/create_tinted-theming.tmpl   → Ghostty (Linux/macOS)
   ├─► tinty custom scheme yaml                     → tinty (switch schemes later)
   ├─► Windows Terminal fragment                    → Windows Terminal
   └─► nvim/palette.lua.tmpl → mini.base16          → Neovim

tmux · fzf · bat · eza · yazi · starship · delta
   └─► ANSI color numbers only → follow whatever the terminal shows
```

Headless servers need **no** palette: ANSI colors are drawn by the terminal you connect from. Isotope's ANSI "yellow" is hot pink, so warnings show pink. The blue was lifted from `#0066ff` to `#3388ff` to raise contrast against the directory color from 4.3:1 to 6.1:1.

## 3. Shell: zsh

**Bootstrap.** `~/.zshenv` is read by every zsh. It sets the XDG variables (with defaults) and `ZDOTDIR=$XDG_CONFIG_HOME/zsh`, which redirects zsh to read `~/.config/zsh/.zshrc` instead of `~/.zshrc`. That keeps `~` clean.

**`.zshrc` sections, in order:**

1. **Options:** `AUTO_CD` (type a directory to cd), `INTERACTIVE_COMMENTS` (`#` works at the prompt), `NO_BEEP`. Sets `EDITOR=nano`.
2. **History:** 100k entries in `$XDG_STATE_HOME/zsh/history`. `EXTENDED_HISTORY` stores timestamps (useful for report timelines). `SHARE_HISTORY` syncs across panes. `HIST_IGNORE_SPACE` lets you keep a secret out of history by starting the command with a space. `HIST_IGNORE_ALL_DUPS` removes repeats.
3. **PATH:** `~/.local/bin` first (where mise lives), `/usr/sbin` last. `typeset -U path` de-duplicates.
4. **Completion:** `compinit` with its dump cached in `$XDG_CACHE_HOME`. The full security check runs at most once a day; otherwise `-C` skips it. This is the main startup-time saver.
5. **Tool inits, each guarded by `(( $+commands[x] ))`:** mise, zoxide, fzf, starship. If a tool is missing the line is skipped, which is the "degrade gracefully" mechanism. `bat` sets `BAT_THEME=ansi` and the man pager.
6. **Aliases and functions** are sourced after the inits so their guards see mise's PATH.
7. **Plugins** (load order matters): fzf-tab → zsh-autopair → zsh-syntax-highlighting (must be last).
8. **Fallback prompt** if Starship is absent: `~ ❯` with the arrow green on success, red on failure.
9. **rbw SSH agent:** exports `SSH_AUTH_SOCK` only if `rbw` exists.
10. **`local.zsh`:** machine-only overrides, sourced if present.

**Emacs keys** are zsh's default, the same as every box you SSH into, so no vi-mode.

### zsh plugins (fetched as tarballs)

| Plugin | What it does | How |
|---|---|---|
| **fzf-tab** | Replaces the Tab completion menu with an fzf popup: type to filter options, flags and paths | Binds Tab to a widget that captures zsh's completion candidates and pipes them to fzf |
| **zsh-autopair** | Typing `(`, `"` or `[` inserts the closing pair and puts the cursor between | Rebinds those keys with ZLE widgets |
| **zsh-syntax-highlighting** | Colors the command line as you type; unknown commands go red before you press Enter | Hooks ZLE redraw and re-tokenizes the buffer; must load last so it wraps all widgets |

### Aliases (never shadow a builtin)

An earlier setup aliased `df` to `duf` and broke pasted commands. The rule now: aliases are new names only, and each is defined only if its tool exists.

`ll`/`la`/`lt` → `eza -l --git`, `eza -la --git`, `eza --tree -L 2` · `lg` → lazygit · `..`, `...` · `ports` → `ss -tulpn` · `ipa` → `ip -br -c a` · `dots` → `chezmoi cd` · `reload` → `exec zsh`

### Functions (each ≤ 5 lines on purpose)

| Function | Purpose |
|---|---|
| `y` | Runs yazi with `--cwd-file`, then `cd`s to the folder you were in when you quit (the official yazi snippet) |
| `tun0` | Prints the VPN interface IPv4 (your LHOST on HTB) |
| `serve [port]` | `python3 -m http.server`, printing `http://<tun0 or localhost>:<port>/` first |
| `listen [port]` | `rlwrap -cAr nc -lvnp <port>`: a netcat listener with arrow-key editing and history |
| `urlenc` / `urldec` | URL-encode / decode a string with a Python one-liner |
| `bwf` | fzf picker over `rbw list`, copies the chosen secret to the clipboard (`wl-copy` or `pbcopy`) |

The ≤ 5 line rule enforces "no custom programs": if something needs more, a tool should already exist for it.

## 4. Prompt: Starship

One line, no newline gap. Shows only what is useful at that moment:

- `directory` (truncated to 3 components), `git_branch` + `git_status`
- `python` virtualenv name, only inside one
- `cmd_duration`, only when a command took more than 2 s
- `status`: the exit code, only on failure
- `username@hostname` **only over SSH or as root**, so you always know when you're not on your own machine
- A custom `tun0` module that shows the VPN IP only while the `tun0` interface exists (a single `when` check; keep or cut after a week of use)

Starship is a single Rust binary that works in both zsh and PowerShell, so the prompt looks identical on all machines. It is configured entirely in `starship.toml`.

## 5. CLI tools (installed by mise)

mise is a version manager and tool installer. `~/.config/mise/config.toml` lists tools with `"latest"`; `mise install` downloads each from GitHub releases (via the aqua registry or the `github:` backend) into `~/.local/share/mise`. `mise activate` adds the right directories to PATH in interactive shells. `mise up` upgrades them.

| Tool | Purpose | How it's used here |
|---|---|---|
| **fzf** | General fuzzy finder | `Ctrl-R` history, `Ctrl-T` insert path, `Alt-C` cd; also powers fzf-tab, `bwf`, sesh picker |
| **zoxide** | `cd` that learns your frequent directories | `z proj` jumps; `zi` picks with fzf; also feeds sesh |
| **ripgrep** (`rg`) | Fast recursive grep honoring `.gitignore` | `rg 'password' -i` |
| **fd** | Simple, fast `find` | `fd -e kdbx`, `fd config ~` |
| **bat** | `cat` with syntax highlighting and paging | `bat file.py`; also the man pager |
| **eza** | `ls` with git status, icons, tree view | `ll`, `la`, `lt` |
| **yazi** | Terminal file manager with previews | `y`; image previews work in tmux via passthrough |
| **jq** | Slice JSON | `curl … \| jq '.[].name'` for APIs, BloodHound, nmap output |
| **btop** | Process, CPU, RAM, network monitor | `btop` |
| **tealdeer** (`tldr`) | Short, example-first man pages | `tldr tar` |
| **neovim** | Editor | `nvim` |
| **starship** | Prompt | automatic |
| **lazygit** | Git TUI: stage hunks, rebase visually | `lg` |
| **delta** | Readable `git diff` / `git log -p` | automatic git pager; falls back to `less`/`cat` if missing |
| **sesh** | Session picker over tmux + zoxide | `prefix T` |
| **doggo** | Readable DNS lookups (`dig` stays for exam muscle memory) | `doggo A example.com @1.1.1.1` |
| **trippy** | traceroute + ping in one TUI (replaces mtr) | `sudo trip 10.10.10.5` (needs admin on Windows) |
| **tinty** | base16 scheme manager (GUI only, not Windows) | switches the Ghostty theme |

Cut on purpose: dust (overlaps ncdu), gping (trippy covers it), duf (shadowing), atuin, oh-my-posh, zsh-autosuggestions.

**Base layer from apt/brew/winget** (needs root, so not mise): `zsh git curl tmux nano unzip` plus `ncdu` (find what's eating disk), `ansifilter` (strips escape codes from logs), `rlwrap` (arrow keys in netcat shells), `pipx`, `python3`.

## 6. tmux

tmux keeps sessions alive across disconnects and splits one terminal into panes. Config highlights:

- `tmux-256color` plus RGB feature flags for Ghostty and xterm-256color, for true color.
- Mouse on; windows and panes start at 1; windows renumber when one closes; 50k scrollback.
- `escape-time 10` removes the lag after pressing Esc (matters in nvim).
- `set-clipboard on` uses OSC52, so copying in tmux over SSH lands in your **local** clipboard.
- `allow-passthrough on` lets yazi draw image previews inside tmux.
- Default prefix `Ctrl-B` is kept, so tmux behaves the same on every machine and avoids macOS conflicts. Cost: zsh's `Ctrl-B` (back one char) is taken; use the left arrow, or `Ctrl-B Ctrl-B`.
- Splits: `prefix |` and `prefix -` keep the current directory. The defaults `%` and `"` still work.
- Status bar uses ANSI colors only. Left: session name. Right: REC indicator and host (useful when nested over SSH).

**Pane logging (`prefix P`).** Uses tmux's built-in `pipe-pane -o`, which toggles: on if off, off if on. Pane output goes through `ansifilter` (strips color and cursor escapes) into `~/logs/YYYY-MM-DD_<session>-<window>-<pane>.log`. The status bar shows a red `● REC` while `#{pane_pipe}` is true. No plugin. It is for lab and engagement timelines.

**Session picker (`prefix T`).** A popup runs `sesh list | fzf` and `sesh connect`, listing tmux sessions and zoxide directories.

## 7. Editors

- **nano** is the default `EDITOR`/`VISUAL`. `nanorc` enables line numbers, soft wrap, 4-space indents, auto-indent and an indicator, and includes the system syntax files (Linux and Homebrew paths).
- **Neovim** uses kickstart.nvim, a readable single-file starter config. It is downloaded as an **external**, so chezmoi owns `~/.config/nvim` and refreshes it weekly. Your changes never touch it; instead three overlay files are merged into the same directory:
  - `lua/custom/init.lua`: personal changes, plus applying the palette through `mini.base16`.
  - `plugin/custom.lua`: one line, `require 'custom'`. Neovim sources `plugin/*.lua` *after* `init.lua`, so this loads your overrides without editing kickstart's `init.lua`.
  - `palette.lua.tmpl`: renders the Isotope palette as a Lua table.

  Switch to nvim later by changing `EDITOR` in `.zshrc`.

## 8. Terminal and theming (GUI machines)

**Ghostty** (`dot_config/ghostty/config`): JetBrainsMono Nerd Font 12, a blinking bar cursor, 6×4 padding, and `shell-integration-features = ssh-terminfo,ssh-env`. The last one makes `ssh` from your shell install Ghostty's terminfo on the remote host automatically, so colors and keys work there. It only works when `ssh` runs from your own shell; for ProxyJump wrappers or IDE remotes, use `infocmp -x xterm-ghostty | ssh host -- tic -x -`. On macOS, `macos-option-as-alt` makes `Alt-C` (fzf cd) work.

**Ghostty theme file.** `themes/create_tinted-theming.tmpl` renders `palette 0-15`, background, foreground, cursor and selection from `palette.toml`. It uses `create_` so it is written once and tinty may overwrite it later without chezmoi reverting it.

**tinty** is a base16 theme manager. This repo gives it a custom scheme (`isotope-noah.yaml`, rendered from the palette) and a config whose hook copies a rendered theme into `~/.config/ghostty/themes/tinted-theming` and sends Ghostty `SIGUSR2` to reload. Practical use: switch schemes with one command whenever you want. Note that tinted-terminal ships prebuilt themes for official schemes only, which is why the custom scheme's Ghostty theme is rendered by chezmoi instead.

**Windows Terminal** reads a *fragment*: a JSON file in `AppData/Local/Microsoft/Windows Terminal/Fragments/dotfiles/` that adds the Isotope color scheme and a pwsh profile with JetBrainsMono Nerd Font and a beam cursor. Fragments can't change the default profile, so set it once by hand. Fragments also can't set cursor blink.

## 9. Windows (PowerShell 7)

No zsh, tmux, nvim, Ghostty or tinty on Windows. The profile (`Microsoft.PowerShell_profile.ps1`) points `STARSHIP_CONFIG` and `YAZI_CONFIG_HOME` at the shared `~/.config` files, activates mise, starship and zoxide, sets PSReadLine to **Emacs** mode (the same keys as zsh), and defines `ll`, `la`, `lt`, `lg`, `y` as functions. The Windows installer script uses `winget install jdx.mise` when mise is missing, then `mise install`.

## 10. Git

`config.tmpl` writes `[user]` only if you gave a name/email (an empty `[user]` would break commits). The pager is `delta` if present, otherwise `$PAGER`/`less`; `diffFilter` likewise falls back to `cat`, so `git log` and `git add -p` work on a bare box. `merge.conflictstyle = zdiff3` shows the common ancestor in conflicts. `init.defaultBranch = main`.

## 11. Common operations

| Task | Command |
|---|---|
| Preview changes before applying | `chezmoi diff` |
| Apply | `chezmoi apply` |
| Pull + apply | `chezmoi update` |
| Edit a managed file at its source | `chezmoi edit ~/.config/tmux/tmux.conf` |
| Pull a local edit back into the repo | `chezmoi re-add` |
| See why a path is (not) managed | `chezmoi managed`, `chezmoi ignored` |
| Inspect template data (`gui`, `os`, palette) | `chezmoi data` |
| Test rendering a template | `chezmoi execute-template < file.tmpl` |
| Test safely without touching your home | `HOME=$(mktemp -d) chezmoi init --apply --source <repo>` |
| Go to the source clone | `dots` (or `chezmoi cd`) |
| Update CLI tools | `mise up` |

When testing in a throwaway HOME, unset any `XDG_*` variables first. If `XDG_CONFIG_HOME` points at your real config, chezmoi reads your real saved answers and writes there instead.
