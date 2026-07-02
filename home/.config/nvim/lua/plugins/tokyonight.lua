--- @docstring
--- Core Colorscheme with Deep Customization (Overrides).
return {
  'folke/tokyonight.nvim',
  priority = 1000, -- Loads first to avoid UI flickering
  config = function()
    require('tokyonight').setup {
      style = 'night', -- Our base
      transparent = false, -- Set true if you want the terminal background

      -- Text style overrides (AST Nodes)
      styles = {
        comments = { italic = false },
        keywords = { italic = true },
        functions = { bold = true },
      },

      -- 1. PALETTE (Global Variables)
      -- Change color roots here
      on_colors = function(colors)
        colors.bg = '#1e1e1e' -- Main background (VS Code style)
        colors.bg_dark = '#1e1e1e' -- Background for NvimTree/Oil
        colors.bg_float = '#1e1e1e' -- Background for popup windows
        colors.bg_sidebar = '#1e1e1e' -- Sidebar background

        -- You can also define custom variables
        colors.my_custom_grey = '#5c6370'
        colors.my_custom_gold = '#e5c07b'
      end,

      -- 2. HIGHLIGHT GROUPS (UI Elements & Syntax)
      -- Override how specific elements are painted
      on_highlights = function(hl, colors)
        local my_custom_grey = '#5c6370'
        -- 1. Base Comments (Vim & Treesitter Global)
        hl.Comment = { fg = my_custom_grey }
        hl['@comment'] = { fg = my_custom_grey }

        -- 2. Documentation Comments (JSDoc, JavaDoc, Rust Docs)
        hl['@comment.documentation'] = { fg = my_custom_grey }

        -- 3. Documentation Strings (Python Docstrings, Ruby)
        hl['@string.documentation'] = { fg = my_custom_grey }

        -- 4. LSP Semantic Tokens (Global Override for any Language Server)
        hl['@lsp.type.comment'] = { fg = my_custom_grey }
        hl['@lsp.mod.documentation'] = { fg = my_custom_grey }

        -- Line Numbers & UI
        hl.LineNr = { fg = '#4b5263' }
        hl.CursorLineNr = { fg = colors.my_custom_gold, bold = true }

        -- Telescope
        hl.TelescopeBorder = { fg = my_custom_grey, bg = colors.bg }
        hl.TelescopeNormal = { bg = colors.bg }
        hl.TelescopePromptBorder = { fg = colors.my_custom_gold, bg = colors.bg }
        hl.TelescopePromptTitle = { fg = colors.bg, bg = colors.my_custom_gold, bold = true }
      end,
    }

    -- NOTE: The colorscheme call happens once at the end of init.lua
    -- (together with saved_theme). Skipping it here avoids startup flash.
  end,
}
