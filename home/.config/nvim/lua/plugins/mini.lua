--- @docstring
--- Collection of minimal, independent, and fast Lua modules.
--- Enabled: ai, surround, pairs, statusline, move, hipatterns, bufremove, trailspace.
return {
  'nvim-mini/mini.nvim',
  event = 'VeryLazy',
  config = function()
    -- Text objects: gaia / gaif / gaip etc.
    require('mini.ai').setup { n_lines = 500 }

    -- Surround: 'S' prefix (Sa/Sd/Sr/...) to avoid conflict with flash 's'
    require('mini.surround').setup {
      mappings = {
        add = 'Sa',
        delete = 'Sd',
        find = 'Sf',
        find_left = 'SF',
        highlight = 'Sh',
        replace = 'Sr',
        update_n_lines = 'Sn',
      },
    }

    -- Auto-pairs for brackets/quotes
    require('mini.pairs').setup()

    -- Statusline
    local statusline = require 'mini.statusline'
    statusline.setup { use_icons = vim.g.have_nerd_font }
    statusline.section_location = function() return '%2l:%-2v' end

    -- Move: Alt+j/k in normal or visual mode moves lines/blocks
    -- (Replaces custom visual J/K that was in keymaps.lua — better UX,
    -- keeps visual selection, works in normal mode too.)
    require('mini.move').setup {
      mappings = {
        left = '<M-h>',
        right = '<M-l>',
        down = '<M-j>',
        up = '<M-k>',
        line_left = '<M-h>',
        line_right = '<M-l>',
        line_down = '<M-j>',
        line_up = '<M-k>',
      },
    }

    -- Hipatterns: HEX/RGB inline color + TODO/FIXME/HACK highlighting
    -- (Replaces nvim-colorizer.lua for basic usage.)
    local hipatterns = require 'mini.hipatterns'
    hipatterns.setup {
      highlighters = {
        fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
        hack = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
        todo = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
        note = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },
        hex_color = hipatterns.gen_highlighter.hex_color(),
      },
    }

    -- Buf remove: clean delete without breaking the window layout
    require('mini.bufremove').setup()

    -- Trailspace: highlight trailing whitespace + :TrimWhitespace command
    require('mini.trailspace').setup()
    vim.api.nvim_create_user_command('TrimWhitespace', function() require('mini.trailspace').trim() end, { desc = 'Trim trailing whitespace' })
  end,
}
