--- @docstring
--- Snacks.nvim — collection of essential Neovim QoL modules by folke.
--- Replaces: neoscroll.nvim + indent-blankline.nvim + nvim-notify.
--- Adds: bigfile / quickfile / bufdelete / lazygit / words / input.
--- (Session management stays in persistence.nvim — snacks has no session module.)
return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    -- ==========================================
    -- STARTUP / PERFORMANCE
    -- ==========================================
    bigfile = {
      enabled = true,
      -- >1.5MB -> disable treesitter/LSP/syntax for responsive editing
      notify = true,
      size = 1.5 * 1024 * 1024,
    },
    quickfile = { enabled = true }, -- First line renders before loading plugins

    -- ==========================================
    -- SMOOTH SCROLLING (replaces neoscroll.nvim)
    -- ==========================================
    scroll = {
      enabled = true,
      animate = {
        duration = { step = 15, total = 150 },
        easing = 'linear',
      },
      spamming = 10, -- Faster on repeated scroll (e.g. sustained <C-d>)
    },

    -- ==========================================
    -- INDENT GUIDES (replaces indent-blankline.nvim)
    -- ==========================================
    indent = {
      enabled = true,
      indent = {
        char = '▏',
        only_scope = false,
        only_current = false,
      },
      scope = {
        enabled = false, -- No dynamic scope highlight (personal preference)
      },
      chunk = { enabled = false },
      filter = function(buf)
        local ft = vim.bo[buf].filetype
        local excluded = {
          help = true,
          alpha = true,
          dashboard = true,
          ['neo-tree'] = true,
          trouble = true,
          lazy = true,
          mason = true,
          notify = true,
          toggleterm = true,
          lspinfo = true,
          checkhealth = true,
          oil = true,
        }
        return vim.g.snacks_indent ~= false and vim.b[buf].snacks_indent ~= false and vim.bo[buf].buftype == '' and not excluded[ft]
      end,
    },

    -- ==========================================
    -- NOTIFICATIONS (replaces nvim-notify)
    -- ==========================================
    notifier = {
      enabled = true,
      timeout = 2500,
      style = 'compact',
      top_down = false, -- Bottom-up stacking (more discreet)
    },

    -- ==========================================
    -- CURSOR WORD HIGHLIGHT (new)
    -- ==========================================
    words = {
      enabled = true, -- Highlight identical words under cursor
      debounce = 200,
    },

    -- ==========================================
    -- OTHER
    -- ==========================================
    bufdelete = { enabled = false }, -- mini.bufremove handles it
    lazygit = { enabled = true }, -- Integrated lazygit float
    input = { enabled = true }, -- Better vim.ui.input (rename dialogs)
    statuscolumn = { enabled = false }, -- Leave to mini.statusline

    -- ==========================================
    -- PRO WORKFLOWS (dashboard / zen / scratch)
    -- ==========================================
    dashboard = {
      enabled = true,
      preset = {
        header = [[
        ╔╗╔┌─┐┌─┐┬  ┬┬┌┬┐    A  n  g  e  l
        ║║║├┤ │ │└┐┌┘│││├┤    · WSL2 · Ubuntu ·
        ╝╚╝└─┘└─┘ └┘ ┴┴ ┴
        ]],
        keys = {
          { icon = ' ', key = 'f', desc = 'Find File', action = ':Telescope find_files' },
          { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
          { icon = ' ', key = 'g', desc = 'Grep Text', action = ':Telescope live_grep' },
          { icon = ' ', key = 'r', desc = 'Recent Files', action = ':Telescope oldfiles' },
          { icon = ' ', key = 'c', desc = 'Config', action = ":lua require('telescope.builtin').find_files({ cwd = vim.fn.stdpath('config') })" },
          { icon = ' ', key = 's', desc = 'Restore Session', action = ':lua require("persistence").load()' },
          { icon = ' ', key = 'l', desc = 'Lazy', action = ':Lazy' },
          { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
        },
      },
      sections = {
        { section = 'header' },
        { section = 'keys', gap = 1, padding = 1 },
        { section = 'startup' },
      },
    },
    zen = { enabled = true }, -- Focused editing float
    scratch = { enabled = true }, -- Ephemeral scratch buffers per-project

    styles = {
      notification = { wo = { wrap = true } },
    },
  },

  keys = {
    -- LazyGit (replaces the toggleterm lazygit call)
    { '<leader>gg', function() Snacks.lazygit() end, desc = 'Lazy[G]it (float)' },
    { '<leader>gl', function() Snacks.lazygit.log() end, desc = 'Lazygit [L]og (cwd)' },
    -- Toggle indent guides
    { '<leader>ui', function() Snacks.toggle.indent():toggle() end, desc = 'Toggle [I]ndent guides' },
    -- Notification history
    { '<leader>un', function() Snacks.notifier.show_history() end, desc = 'Show [N]otification history' },
    -- Zen mode
    { '<leader>z', function() Snacks.zen() end, desc = '[Z]en mode (focused editing)' },
    { '<leader>Z', function() Snacks.zen.zoom() end, desc = '[Z]oom current split' },
    -- Scratch buffer
    { '<leader>.', function() Snacks.scratch() end, desc = 'Scratch buffer (toggle)' },
    { '<leader>S', function() Snacks.scratch.select() end, desc = '[S]elect scratch buffer' },
  },

  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        -- Toggle mappings for Snacks
        Snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>us'
        Snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>uw'
        Snacks.toggle.line_number():map '<leader>ul'
        Snacks.toggle.diagnostics():map '<leader>ud'
        Snacks.toggle.treesitter():map '<leader>uT'
      end,
    })
  end,
}
