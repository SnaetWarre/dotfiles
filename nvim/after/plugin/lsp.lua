local status_ok, lsp = pcall(require, 'lsp-zero')
if not status_ok then
    return
end

lsp = lsp.preset({})

lsp.on_attach(function(client, bufnr)
    lsp.default_keymaps({buffer = bufnr})
end)

-- Configure language servers
local lspconfig = require('lspconfig')

-- Lua
lspconfig.lua_ls.setup(lsp.nvim_lua_ls())

-- C/C++
lspconfig.clangd.setup({})

-- C#
lspconfig.csharp_ls.setup({
    enable_roslyn_analyzers = true,
    organize_imports_on_format = true,
    enable_import_completion = true,
})

-- Go
lspconfig.gopls.setup({})

-- Python
lspconfig.pyright.setup({})

-- YAML
lspconfig.yamlls.setup({})

-- Rust
lspconfig.rust_analyzer.setup({})

-- JavaScript/TypeScript
lspconfig.ts_ls.setup({})

-- HTML
lspconfig.html.setup({})

-- CSS
lspconfig.cssls.setup({})

-- Svelte
lspconfig.svelte.setup({})

lsp.setup() 