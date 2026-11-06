-- personal changes live here; kickstart (an external) is never edited
-- mini.base16 ships inside mini.nvim, which stock kickstart already installs
local ok, base16 = pcall(require, 'mini.base16')
if ok then
  base16.setup { palette = dofile(vim.fn.stdpath 'config' .. '/palette.lua') }
end
