--- @docstring
--- Debug Adapter Protocol architecture for Multi-Language Debugging.
return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    'theHamsta/nvim-dap-virtual-text',
  },
  keys = {
    { '<F5>', function() require('dap').continue() end, desc = 'Debug Start/Continue' },
    { '<F10>', function() require('dap').step_over() end, desc = 'Debug Step Over' },
    { '<F11>', function() require('dap').step_into() end, desc = 'Debug Step Into' },
    { '<F12>', function() require('dap').step_out() end, desc = 'Debug Step Out' },
    { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Debug Toggle [B]reakpoint' },
    { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, desc = 'Debug Conditional [B]reakpoint' },
    { '<leader>du', function() require('dapui').toggle() end, desc = 'Debug Toggle [U]I' },
    { '<leader>dc', function() require('dap').continue() end, desc = 'Debug [C]ontinue (Start)' },
    { '<leader>dr', function() require('dap').repl.open() end, desc = 'Debug [R]EPL' },
    { '<leader>dl', function() require('dap').run_last() end, desc = 'Debug run [L]ast' },
    { '<leader>dt', function() require('dap').terminate() end, desc = 'Debug [T]erminate' },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      -- js-debug (pwa-node) replaces the deprecated 'node2'
      ensure_installed = { 'python', 'codelldb', 'js-debug-adapter', 'javadbg' },
      handlers = {}, -- Let Mason automatically configure the adapters it downloads
    }

    require('nvim-dap-virtual-text').setup {
      enabled = true,
      enabled_commands = true,
      highlight_changed_variables = true,
      highlight_new_as_changed = false,
      show_stop_reason = true,
      commented = false,
      only_first_definition = true,
      all_references = false,
      clear_on_continue = false,
    }

    dapui.setup()
    dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
    dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
    dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end

    -- C/C++ Configuration
    dap.configurations.cpp = {
      {
        name = 'Launch file',
        type = 'codelldb',
        request = 'launch',
        program = function() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file') end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
      },
    }
    dap.configurations.c = dap.configurations.cpp

    -- JavaScript/TypeScript/Node Configuration (js-debug-adapter · pwa-node)
    dap.adapters['pwa-node'] = {
      type = 'server',
      host = 'localhost',
      port = '${port}',
      executable = {
        command = 'node',
        args = {
          vim.fn.stdpath 'data' .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js',
          '${port}',
        },
      },
    }
    for _, lang in ipairs { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' } do
      dap.configurations[lang] = {
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch current file',
          program = '${file}',
          cwd = '${workspaceFolder}',
          sourceMaps = true,
          console = 'integratedTerminal',
        },
        {
          type = 'pwa-node',
          request = 'attach',
          name = 'Attach to process',
          processId = require('dap.utils').pick_process,
          cwd = '${workspaceFolder}',
        },
      }
    end
  end,
}
