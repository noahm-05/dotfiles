## What was built
chezmoi source repo on branch pipeline/v1 (not pushed), phases 1-5 and 7 as commits, phase 6 (macOS) covered by branches already in the templates. Files: chezmoi config/ignore/externals, zsh (zshenv, zshrc, aliases, functions), mise config + installers (sh/ps1), starship, git, yazi, tmux (logging, sesh), nanorc, Isotope palette + nvim overlay (palette.lua, plugin/custom.lua, lua/custom/init.lua), Ghostty, tinty config + custom scheme + first-run apply, PowerShell profile, Windows Terminal fragment, README, BUILD_NOTES.md.

## Deviations from plan.md
- Installer named run_onchange_after_install-mise.* so the mise config exists first.
- Added run_after_tinty-apply.sh.tmpl, plugin/custom.lua; plugins/kickstart use archive externals.
- Full list and assumptions in BUILD_NOTES.md.

## Acceptance check result
FAIL / NOT RUN for hardware checks (#1-#7 need a Debian VM, ThinkPad, Mac, Windows PC). chezmoi could not be installed here (curl|sh and source build were blocked), so no `chezmoi execute-template` or `apply --destination` was run.
Verified locally: `zsh -n` on all zsh files; zshrc/aliases/functions in a clean HOME under a pty open with zero errors, fallback prompt shown, urlenc/urldec work; TOML parses (starship, yazi); tmux.conf loads in a real tmux, prefix+P command toggles pipe-pane, creates ~/logs and a dated log (tested with a stand-in ansifilter; real ansifilter not installed, so escape-code cleanliness unverified); nanorc loads in nano 8.4 with line numbers; templates rendered with a Go text/template stand-in (stub funcs, not chezmoi) and outputs parsed as TOML/YAML/JSON/sh.
Not verified: chezmoi semantics (ignore patterns, external overlay on nvim), starship/mise/tinty/sesh behavior, nvim colors, Ghostty, Windows pieces, startup time.
