--- @docstring
--- Execute buffer code asynchronously.
return {
  'CRAG666/code_runner.nvim',
  config = true,
  keys = { { '<leader>rr', ':RunCode<CR>', desc = 'Run Code Current File' }, { '<leader>rc', ':RunClose<CR>', desc = 'Run Close' } },
  opts = {
    mode = 'float',
    float = { close_key = '<ESC>', window_border = 'rounded' },
    filetype = {
      java = { 'cd $dir &&', 'javac $fileName &&', 'java $fileNameWithoutExt' },
      python = 'python3 -u',
      typescript = 'deno run',
      javascript = 'node',
      c = { 'cd $dir &&', 'gcc $fileName -o $fileNameWithoutExt &&', '$dir/$fileNameWithoutExt' },
      cpp = { 'cd $dir &&', 'g++ $fileName -o $fileNameWithoutExt &&', '$dir/$fileNameWithoutExt' },
    },
  },
}
