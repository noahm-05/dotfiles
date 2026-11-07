$env:STARSHIP_CONFIG = "$HOME/.config/starship.toml"
$env:YAZI_CONFIG_HOME = "$HOME/.config/yazi"
# mise activate takes ~280 ms to generate, so cache it and rebuild only when mise.exe changes
$mise = Get-Command mise -ErrorAction SilentlyContinue
if ($mise) {
  $cache = "$env:LOCALAPPDATA\mise-activate.ps1"
  if (-not (Test-Path $cache) -or (Get-Item $cache).LastWriteTime -lt (Get-Item $mise.Source).LastWriteTime) { (& mise activate pwsh) -join "`n" | Set-Content $cache }
  . $cache
}
if (Get-Command starship -ErrorAction SilentlyContinue) { Invoke-Expression (& starship init powershell) }
if (Get-Command zoxide -ErrorAction SilentlyContinue) { Invoke-Expression (& { (zoxide init powershell | Out-String) }) }
Set-PSReadLineOption -EditMode Emacs
function ll { eza -l --git @args }
function la { eza -la --git @args }
function lt { eza --tree -L 2 @args }
function lg { lazygit @args }
function y {
  $tmp = New-TemporaryFile
  yazi @args --cwd-file="$tmp"
  $cwd = Get-Content -Path $tmp -Encoding UTF8
  if ($cwd -and (Test-Path -LiteralPath $cwd -PathType Container)) { Set-Location -LiteralPath $cwd }
  Remove-Item -Path $tmp
}
