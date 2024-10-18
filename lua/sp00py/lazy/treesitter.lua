local M = {
    "nvim-treesitter/nvim-treesitter",
    build = function()
        require("nvim-treesitter.install").update({ with_sync = true })()
    end,
    config = function()
        local configs = require("nvim-treesitter.configs")

        configs.setup({
            ensure_installed = { "lua", "vim", "vimdoc", "javascript", "html", "rust", "c_sharp", "python", "markdown", "htmldjango" },
            sync_install = true,
            highlight = { enable = true },
            indent = { enable = true },
        })
        local treesitter_parser_config = require("nvim-treesitter.parsers").get_parser_configs()
        treesitter_parser_config.powershell = {
            install_info = {
                url = "~/tsparsers/tree-sitter-powershell",
                files = {"src/parser.c", "src/scanner.c"},
                branch = "main",
                generate_requires_npm = false,
                requires_generate_from_grammar = false
            },
            filetype = "ps1",
        }
    end
}

return { M }
