--- @docstring
--- Automatically close and rename HTML/JSX tags.
return {
  'windwp/nvim-ts-autotag',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {},
}
