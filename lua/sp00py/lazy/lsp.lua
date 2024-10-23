return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        local spell_words = {}
        for word in io.open(vim.fn.stdpath("config") .. "/spell/en.utf-8.add", "r"):lines() do
            table.insert(spell_words, word)
        end
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require("fidget").setup({})
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "rust_analyzer",
                "eslint",
                "tsserver",
                "angularls",
                "arduino_language_server",
                "cssls",
                "html",
                "jsonls",
                "marksman",
                "pyright",
                "sqlls",
                "yamlls",
                "powershell_es",
                "omnisharp",
                "ltex-ls"
            },
            handlers = {
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,
                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                runtime = { version = "Lua 5.1" },
                                diagnostics = {
                                    globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                                }
                            }
                        }
                    }
                end,
                ['omnisharp'] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.omnisharp.setup {
                        capabilities = capabilities,
                        use_mono = false,
                    }
                end,
['ltex'] = function()
local lspconfig = require("lspconfig")
    lspconfig.ltex.setup({
            language = "en-US",
            enabled = true,
            dictionary = {
            ["en-US"] = spell_words,
            }
            })
                end
                ['powershell_es'] = function ()
                    --this only works on Windows (I think?) with the repo installed on the desktop
                    --https://github.com/PowerShell/PowerShellEditorServices/releases
                    --need to figure out how to manage this dependency, installing it into this
                    --config seems bad
                    --also this LSP requires PowerShell 7.2 or higher, which ironically shouldn't be a problem
                    --on linux
                    local home_directory = os.getenv('HOME')
                    if home_directory == nil then
                        home_directory = os.getenv('USERPROFILE')
                    end
                    local bundle_path = home_directory .. '/Desktop/PowerShellEditorServices'
                    local lspconfig = require("lspconfig")
                    lspconfig.powershell_es.setup {
                        bundle_path = bundle_path,
                    }
                end,
            }
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
                ['<Tab>'] = cmp.mapping.confirm({ select = true }),
                ['<Enter>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
                { name = 'nvim_lsp_signature_help' },
            }, {
                { name = 'buffer' },
            })
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
