--- @docstring
--- Java FileType Plugin.
--- Bootstraps the Eclipse JDTLS OSGi server, configures Workspaces, and injects DAP bundles.

local jdtls = require 'jdtls'

-- 1. Calculate isolated workspace path for the current project
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = vim.fn.stdpath 'data' .. '/site/java/workspace-root/' .. project_name

-- 2. Deterministic Pathing for Mason Installations (Bypasses Lazy-Load Race Conditions)
local mason_path = vim.fn.stdpath 'data' .. '/mason/packages'
local jdtls_path = mason_path .. '/jdtls'

-- 3. Determine the OS platform for Eclipse configuration
local os_config = 'linux'
if vim.fn.has 'mac' == 1 then os_config = 'mac' end

-- 4. Inject OSGi Bundles for Debugging and Testing
local bundles = {}
local debug_path = mason_path .. '/java-debug-adapter'
local test_path = mason_path .. '/java-test'

-- Only inject if the jars actually exist on disk, preventing runtime injection faults
if vim.fn.isdirectory(debug_path) == 1 and vim.fn.isdirectory(test_path) == 1 then
  table.insert(bundles, vim.fn.glob(debug_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar', true))
  vim.list_extend(bundles, vim.split(vim.fn.glob(test_path .. '/extension/server/*.jar', true), '\n'))
end

-- 5. Construct the Server configuration matrix
local config = {
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens',
    'java.base/java.util=ALL-UNNAMED',
    '--add-opens',
    'java.base/java.lang=ALL-UNNAMED',
    '-jar',
    vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
    '-configuration',
    jdtls_path .. '/config_' .. os_config,
    '-data',
    workspace_dir,
  },
  root_dir = require('jdtls.setup').find_root { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' },
  init_options = { bundles = bundles },
  settings = {
    java = {
      eclipse = { downloadSources = true },
      configuration = { updateBuildConfiguration = 'interactive' },
      maven = { downloadSources = true },
      implementationsCodeLens = { enabled = true },
      referencesCodeLens = { enabled = true },
      references = { includeDecompiledSources = true },
    },
  },
  on_attach = function(client, bufnr)
    -- Hook the Debug Adapter Protocol (DAP) into the server
    jdtls.setup_dap { hotcodereplace = 'auto' }
    require('jdtls.dap').setup_dap_main_class_configs()

    -- Semantic Keybinds mapped exclusively for Java buffers
    local opts = { buffer = bufnr }
    vim.keymap.set('n', '<leader>co', jdtls.organize_imports, vim.tbl_extend('force', opts, { desc = 'Organize Imports' }))
    vim.keymap.set('n', '<leader>cv', jdtls.extract_variable, vim.tbl_extend('force', opts, { desc = 'Extract Variable' }))
    vim.keymap.set('x', '<leader>cv', function() jdtls.extract_variable(true) end, vim.tbl_extend('force', opts, { desc = 'Extract Variable' }))
    vim.keymap.set('n', '<leader>cM', jdtls.extract_method, vim.tbl_extend('force', opts, { desc = 'Extract Method' }))
    vim.keymap.set('x', '<leader>cM', function() jdtls.extract_method(true) end, vim.tbl_extend('force', opts, { desc = 'Extract Method' }))

    -- Testing Keybinds
    vim.keymap.set('n', '<leader>dpt', jdtls.test_class, vim.tbl_extend('force', opts, { desc = 'Debug Java Test Class' }))
    vim.keymap.set('n', '<leader>dpm', jdtls.test_nearest_method, vim.tbl_extend('force', opts, { desc = 'Debug Java Test Method' }))
  end,
}

-- 6. Ignite the Engine
jdtls.start_or_attach(config)
