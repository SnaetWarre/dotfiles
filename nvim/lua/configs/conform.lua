local options = {
  formatters_by_ft = {
    -- Lua
    lua = { "stylua" },

    -- Web development
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    css = { "prettier" },
    html = { "prettier" },
    json = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },

    -- Rust
    rust = { "rustfmt" },

    -- Python
    python = { "black", "isort" },

    -- Go
    go = { "gofmt", "goimports" },

    -- C/C++
    c = { "clang-format" },
    cpp = { "clang-format" },

    -- Shell
    sh = { "shfmt" },
    bash = { "shfmt" },

    -- TOML
    toml = { "taplo" },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
