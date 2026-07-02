--- @docstring
--- Universal Formatting Engine with Safety Valves.
return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo', 'FormatToggle' },
  keys = {
    { '<leader>f', function() require('conform').format { async = true, lsp_format = 'fallback' } end, mode = { 'n', 'v' }, desc = '[F]ormat buffer' },
    { '<leader>uf', '<cmd>FormatToggle<cr>', desc = 'Toggle Auto-[F]ormat on Save (buffer)' },
    { '<leader>uF', '<cmd>FormatToggle!<cr>', desc = 'Toggle Auto-[F]ormat on Save (global)' },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
      return { timeout_ms = 500, lsp_format = 'fallback' }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'ruff_format', 'ruff_organize_imports' },
      javascript = { 'prettier' },
      javascriptreact = { 'prettier' },
      typescript = { 'prettier' },
      typescriptreact = { 'prettier' },
      css = { 'prettier' },
      html = { 'prettier' },
      c = { 'clang-format' },
      cpp = { 'clang-format' },
      java = { 'google-java-format' },
    },
    formatters = {
      ['clang-format'] = { prepend_args = { '-style={BasedOnStyle: LLVM, IndentWidth: 4}' } },
    },
  },
  init = function()
    vim.api.nvim_create_user_command('FormatToggle', function(args)
      local is_global = args.bang
      if is_global then
        vim.g.disable_autoformat = not vim.g.disable_autoformat
        if vim.g.disable_autoformat then
          vim.notify('Auto-format Disabled (Global)', vim.log.levels.INFO)
        else
          vim.notify('Auto-format Enabled (Global)', vim.log.levels.INFO)
        end
      else
        vim.b.disable_autoformat = not vim.b.disable_autoformat
        if vim.b.disable_autoformat then
          vim.notify('Auto-format Disabled (Buffer)', vim.log.levels.INFO)
        else
          vim.notify('Auto-format Enabled (Buffer)', vim.log.levels.INFO)
        end
      end
    end, { desc = 'Toggle autoformat-on-save', bang = true })
  end,
}
