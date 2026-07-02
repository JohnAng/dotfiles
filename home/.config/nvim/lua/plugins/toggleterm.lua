--- @docstring
--- Floating/split terminal wrapper with persistent sessions and lazygit integration.
return {
  'akinsho/toggleterm.nvim',
  version = '*',
  cmd = { 'ToggleTerm', 'TermExec' },
  keys = {
    -- Primary: <C-\> toggle float
    { [[<C-\>]], '<cmd>ToggleTerm direction=float<cr>', desc = 'Toggle float terminal', mode = { 'n', 't' } },
    -- <leader>T = Terminal group (uppercase to separate from <leader>t=Test)
    { '<leader>Tf', '<cmd>ToggleTerm direction=float<cr>', desc = 'Terminal [F]loat' },
    { '<leader>Th', '<cmd>ToggleTerm size=15 direction=horizontal<cr>', desc = 'Terminal [H]orizontal' },
    { '<leader>Tv', '<cmd>ToggleTerm size=60 direction=vertical<cr>', desc = 'Terminal [V]ertical' },
    -- Lazygit: provided by snacks.lazygit (<leader>gg)
  },
  opts = {
    size = function(term)
      if term.direction == 'horizontal' then return 15 end
      if term.direction == 'vertical' then return vim.o.columns * 0.4 end
      return 20
    end,
    open_mapping = nil, -- Manual mappings above for clarity
    hide_numbers = true,
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = true,
    persist_size = true,
    direction = 'float',
    close_on_exit = true,
    shell = vim.o.shell,
    float_opts = {
      border = 'rounded',
      winblend = 0,
    },
  },
  config = function(_, opts)
    require('toggleterm').setup(opts)
    -- Terminal mode escape (already set in keymaps.lua, but add pane navigation here)
    vim.api.nvim_create_autocmd('TermOpen', {
      pattern = 'term://*',
      callback = function()
        local o = { buffer = 0 }
        vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], o)
        vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], o)
        vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], o)
        vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], o)
      end,
    })
  end,
}
