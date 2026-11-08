-- personal changes live here; kickstart (an external) is never edited
-- mini.base16 ships inside mini.nvim, which stock kickstart already installs
-- follow tinty's current scheme (read at startup); fall back to the repo palette
local function tinty_palette()
  local root = vim.fn.expand '~/.local/share/tinted-theming/tinty'
  local f = io.open(root .. '/current_scheme')
  if not f then return end
  local name = (f:read '*l' or ''):gsub('^base16%-', '')
  f:close()
  for _, path in ipairs { root .. '/custom-schemes/base16/' .. name .. '.yaml', root .. '/scheme-repos/schemes/base16/' .. name .. '.yaml' } do
    local y = io.open(path)
    if y then
      local p = {}
      for k, v in y:read('*a'):gmatch '(base%x%x):%s*"?#?(%x%x%x%x%x%x)' do p[k] = '#' .. v end
      y:close()
      if p.base00 and p.base0F then return p end
    end
  end
end

local ok, base16 = pcall(require, 'mini.base16')
if ok then
  base16.setup { palette = tinty_palette() or dofile(vim.fn.stdpath 'config' .. '/palette.lua') }
end
