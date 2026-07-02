--- @docstring
--- Neovim plugin to manage the file system and other tree like structures.
return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons', 'MunifTanjim/nui.nvim' },
  keys = { { '\\', '<cmd>Neotree toggle<cr>', desc = 'Toggle NeoTree Explorer' } },
  opts = {
    close_if_last_window = true,
    filesystem = {
      filtered_items = { visible = true, hide_dotfiles = false },
      follow_current_file = { enabled = true },
      hijack_netrw_behavior = 'disabled', -- CRITICAL: Allows Oil.nvim to handle 'nvim .'
    },
    window = { position = 'left', width = 30 },
  },
}
