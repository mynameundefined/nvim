return {
    "neovim/nvim-lspconfig",

    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        "j-hui/fidget.nvim"
    },

    config = function()
        local cmp_lsp = require("cmp_nvim_lsp")
        local fidget = require("fidget")
        local mason = require("mason")
        local mason_lsp = require("mason-lspconfig")
        local mason_tool_installer = require("mason-tool-installer")

        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        fidget.setup({})

        mason.setup({
            registries = {
                "github:mason-org/mason-registry",
                "github:Crashdummyy/mason-registry"
            }
        })

        mason_lsp.setup({
            ensure_installed = {
                "lua_ls"
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
                end
            }
        })

        mason_tool_installer.setup({
            ensure_installed = {
                "roslyn"
            }
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
