$env:STARSHIP_CONFIG = "$HOME/.config/starship.toml"
$env:YAZI_CONFIG_HOME = "$HOME/.config/yazi"
if (Get-Command mise -ErrorAction SilentlyContinue) { (& mise activate pwsh) -join "`n" | Invoke-Expression }
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
