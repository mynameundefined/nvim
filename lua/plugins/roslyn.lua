local function monkey_patch_semantic_tokens(client)
    -- NOTE: Super hacky... Don't know if I like that we set a random variable on
    -- the client Seems to work though ~seblj
    if client.is_hacked then
        return
    end
    client.is_hacked = true

    -- let the runtime know the server can do semanticTokens/full now
    client.server_capabilities = vim.tbl_deep_extend("force", client.server_capabilities, {
        semanticTokensProvider = {
            full = true,
        },
    })

    -- monkey patch the request proxy
    local request_inner = client.request
    client.request = function(method, params, handler, req_bufnr)
        if method ~= vim.lsp.protocol.Methods.textDocument_semanticTokens_full then
            return request_inner(method, params, handler, req_bufnr)
        end

        local target_bufnr = vim.uri_to_bufnr(params.textDocument.uri)
        local line_count = vim.api.nvim_buf_line_count(target_bufnr)
        local last_line = vim.api.nvim_buf_get_lines(target_bufnr, line_count - 1, line_count, true)[1]

        return request_inner("textDocument/semanticTokens/range", {
            textDocument = params.textDocument,
            range = {
                ["start"] = {
                    line = 0,
                    character = 0,
                },
                ["end"] = {
                    line = line_count - 1,
                    character = string.len(last_line) - 1,
                },
            },
        }, handler, req_bufnr)
    end
end

return {
    "seblj/roslyn.nvim",
    ft = { "cs", "razor" },
    dependencies = {
        {
            'tris203/rzls.nvim',
            config = function()
                require('rzls').setup({})
            end
        }
    },
    config = function()
        require("roslyn").setup {
            args = {
                '--stdio',
                '--logLevel=Information',
                '--extensionLogDirectory=' .. vim.fs.dirname(vim.lsp.get_log_path()),
                '--razorSourceGenerator='
                .. vim.fs.joinpath(vim.fn.stdpath 'data', 'mason', 'packages', 'roslyn', 'libexec', 'Microsoft.CodeAnalysis.Razor.Compiler.dll'),
                '--razorDesignTimePath=' .. vim.fs.joinpath(
                    vim.fn.stdpath('data'),
                    'mason',
                    'packages',
                    'rzls',
                    'libexec',
                    'Targets',
                    'Microsoft.NET.Sdk.Razor.DesignTime.targets'
                ),
            },
            config = {
                handlers = require 'rzls.roslyn_handlers',
                settings = {
                    ['csharp|inlay_hints'] = {
                        csharp_enable_inlay_hints_for_implicit_object_creation = true,
                        csharp_enable_inlay_hints_for_implicit_variable_types = true,

                        csharp_enable_inlay_hints_for_lambda_parameter_types = true,
                        csharp_enable_inlay_hints_for_types = true,
                        dotnet_enable_inlay_hints_for_indexer_parameters = true,
                        dotnet_enable_inlay_hints_for_literal_parameters = true,
                        dotnet_enable_inlay_hints_for_object_creation_parameters = true,
                        dotnet_enable_inlay_hints_for_other_parameters = true,
                        dotnet_enable_inlay_hints_for_parameters = true,
                        dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
                        dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
                        dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
                    },
                    ['csharp|code_lens'] = {
                        dotnet_enable_references_code_lens = true,
                    },
                },
            },
            on_attach = function(client)
                monkey_patch_semantic_tokens(client)
            end
        }
    end,
    init = function()
        -- we add the razor filetypes before the plugin loads
        vim.filetype.add {
            extension = {
                razor = 'razor',
                cshtml = 'razor'
            },
        }
    end,
}
