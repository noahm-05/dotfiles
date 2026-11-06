# Build notes

Assumptions and decisions made while building from plan.md. Nothing here was run
against a real home directory.

## Decisions from Noah
- nvim: kickstart.nvim is an `archive` external into `~/.config/nvim`; `palette.lua.tmpl`,
  `plugin/custom.lua` and `lua/custom/init.lua` are overlay files.
- No base-layer script; README documents per-OS commands and chezmoi install without curl.

## Assumptions (plan defaults)
1. `mise activate zsh` only; shims are not on PATH.
2. `.chezmoi.toml.tmpl` also prompts for git `name` and `email`; all three prompts have
   defaults (gui=false, empty name/email) so non-interactive runs do not hang.
3. `<github-user>` is `noahm-05`.
4. Linux font: archive external of the Nerd Fonts JetBrainsMono tarball (gui only).
   macOS font and Ghostty: brew casks, documented in README only.
5. nvim, zsh, tmux, nano, ghostty, tinty are not delivered to Windows. starship, git,
   yazi and mise configs live in `~/.config`; the pwsh profile points
   `STARSHIP_CONFIG` and `YAZI_CONFIG_HOME` there. Git for Windows reads `~/.config/git`.
6. `/usr/sbin` appended to PATH as written (design-notes section 5 was not available).
7. `rbw` and `wl-copy` are not installed by this repo; `bwf` and `SSH_AUTH_SOCK` are
   guarded. `bwf` falls back to `pbcopy` when `wl-copy` is missing (X11 Linux has neither).
8. Plugins and kickstart use `archive` externals of `HEAD.tar.gz` (no git needed, refresh
   every 168h), not git-repo.
9. `tun0` function uses `ip`, so it prints nothing on macOS. Starship `tun0` module included
   (default per plan), guarded by a `when` check.

## Deviations worth knowing
- Installer is `run_onchange_after_install-mise.*` (not `run_onchange_install-mise.*`) so
  the mise config is written before `mise install` runs.
- Added `dot_config/nvim/plugin/custom.lua` (one line). Stock kickstart `init.lua` cannot
  be edited, but nvim sources `plugin/*.lua` after it, so this loads `lua/custom` without
  touching kickstart.
- Windows Terminal has no per-profile cursor-blink setting; only `cursorShape: bar` is set.
- The installer exits 0 with a warning if neither mise nor curl exists (bare box), so
  `chezmoi apply` still finishes cleanly.

## Risks (unverified)
- `mise` registry names (btop on Windows, sesh, tinty via `github:`) not checked.
- `mini.base16` via `require` relies on kickstart's installed mini.nvim being loadable by
  lazy.nvim on demand.

## Spec open items (left open)
Ghostty on Debian 13; tinty x86_64 asset; mise tools on Windows; Windows Terminal
fragment `schemes`; Nerd Font on Windows; keep/cut Starship `tun0`.

## Revision history
- PATH deviation: spec step 3 says "mise shims"; this build uses `mise activate zsh` only.
  Non-interactive callers (nvim LSPs, scripts, cron) will not see mise tools.
- Installer renamed `run_onchange_after_install-mise.*` (spec layout: `run_onchange_install-mise.*`)
  so it runs after the mise config is written.
- Ghostty theme is rendered from the palette by `dot_config/ghostty/themes/create_tinted-theming.tmpl`
  (tinty has no prebuilt files for the custom scheme); `run_after_tinty-apply.sh.tmpl` removed.
