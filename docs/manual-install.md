# Manual install

Use this when you want to see each step, or when `install.sh` does not fit (Windows, offline, unusual setups). The normal path is the one-liner in the [README](../README.md#install).

Every OS follows the same three steps: install `git` and chezmoi, install the base packages from this repo's `packages/` folder (needs root, so it is a separate step), then apply. chezmoi asks three questions once: is this a GUI machine, your git name, your git email.

The commands below clone the repo into `~/.local/share/chezmoi`, which is where `packages/` ends up. The repo is public and cloned over HTTPS, so no GitHub account, `gh` login or SSH key is needed.

Run each command on its own. Pasting several at once makes the later lines get typed into chezmoi's prompts.

## Debian / Ubuntu

```sh
sudo apt install -y git curl
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin init https://github.com/noahm-05/dotfiles.git
xargs -a ~/.local/share/chezmoi/packages/apt.txt sudo apt install -y
~/.local/bin/chezmoi apply
```

## macOS

```sh
brew install git chezmoi
chezmoi init https://github.com/noahm-05/dotfiles.git
brew bundle --file ~/.local/share/chezmoi/packages/Brewfile
brew bundle --file ~/.local/share/chezmoi/packages/Brewfile.gui   # GUI machines: Ghostty + font
chezmoi apply
```

Homebrew itself must already be installed: https://brew.sh.

## Windows (PowerShell)

```powershell
winget install Git.Git twpayne.chezmoi
# open a new terminal so git and chezmoi are on PATH
chezmoi init https://github.com/noahm-05/dotfiles.git
winget import -i "$HOME\.local\share\chezmoi\packages\winget.json" --accept-package-agreements --accept-source-agreements
chezmoi apply
```

Install JetBrainsMono Nerd Font by hand (no automated method yet), then set the "PowerShell (dotfiles)" profile as the Windows Terminal default once.

## Offline / flash drive

Copy the repo to the drive, then use `--source` in place of the repo URL and run the package step from the drive's `packages/` folder:

```sh
chezmoi init --source /media/<stick>/dotfiles
xargs -a /media/<stick>/dotfiles/packages/apt.txt sudo apt install -y
chezmoi apply
```

## Non-interactive (servers, VMs, CI)

Replace the `init` step with:

```sh
chezmoi init --promptDefaults \
  --promptBool "GUI machine (Ghostty, tinty, font)=false" \
  --promptString "Git name=Your Name,Git email=you@example.com" \
  https://github.com/noahm-05/dotfiles.git
```

## What the package files contain

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
