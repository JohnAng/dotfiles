--- @docstring
--- The undo history visualizer for VIM.
return {
  'mbbill/undotree',
  cmd = { 'UndotreeToggle', 'UndotreeShow' },
  keys = { { '<leader>uu', vim.cmd.UndotreeToggle, desc = 'Toggle [U]ndo Tree' } },
}
