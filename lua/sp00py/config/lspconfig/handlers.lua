local M = {}

function M.handlers()
    vim.lsp.handlers["textDocument/definition"] = function (_, result, ctx)
        if not result or vim.tbl_isempty(result) then
            return vim.notify("Lsp: Could not find definition")
        end
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if not client then
            return vim.notify("Lsp: could not find client")
        end

        if vim.islist(result) then
            local results = vim.lsp.util.locations_to_items(result, client.offset_encoding)
            local lnum, filename = results[1].lnum, results[1].filename
            for _, val in ipairs(results) do
                if val.lnum ~= lnum or val.filename ~= filename then
                    return require("telescope.builtin").lsp_definitions()
                end
            end
            vim.lsp.util.jump_to_location(result[1], client.offset_encoding, false)
        else
            vim.lsp.util.jump_to_location(result, client.offset_encoding, false)
        end
    end
    vim.lsp.handlers["textDocument/references"] = function (_, _, _)
        require("telescope.builtin").lsp_references()
    end
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = 'single'
    })
    vim.lsp.handlers["textDocument/signature_help"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = 'single',
        close_events = {}
    })
end

return M
