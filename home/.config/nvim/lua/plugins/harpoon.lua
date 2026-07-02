--- @docstring
--- Getting you where you want with the fewest keystrokes. O(1) file navigation.
return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
  -- CRITICAL: Define keys here. lazy.nvim handles the bindings.
  keys = {
    { '<leader>ha', function() require('harpoon'):list():add() end, desc = 'Harpoon Add File' },
    { '<leader>hl', function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end, desc = 'Harpoon List Menu' },

    -- The custom Telescope UI was safely moved inside a Closure
    {
      '<leader>ht',
      function()
        local harpoon = require 'harpoon'
        local conf = require('telescope.config').values
        local file_paths = {}
        for _, item in ipairs(harpoon:list().items) do
          table.insert(file_paths, item.value)
        end
        require('telescope.pickers')
          .new({}, {
            prompt_title = 'Harpoon',
            finder = require('telescope.finders').new_table { results = file_paths },
            previewer = conf.file_previewer {},
            sorter = conf.generic_sorter {},
          })
          :find()
      end,
      desc = 'Harpoon Telescope Menu',
    },

    -- Terminal-Safe Navigation
    { '<leader>1', function() require('harpoon'):list():select(1) end, desc = 'Harpoon File 1' },
    { '<leader>2', function() require('harpoon'):list():select(2) end, desc = 'Harpoon File 2' },
    { '<leader>3', function() require('harpoon'):list():select(3) end, desc = 'Harpoon File 3' },
    { '<leader>4', function() require('harpoon'):list():select(4) end, desc = 'Harpoon File 4' },
  },
  config = function() require('harpoon'):setup() end,
}
