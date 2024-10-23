require("sp00py.opts")
require("sp00py.remap")
require("sp00py.lazy_init")


local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local MainGroup = augroup('MainGroup', {})
local YankGroup = augroup('HighlightYank', {})

local HighlightGroup = augroup("LSPDocumentHighlight", {})
vim.opt.updatetime = 1000

autocmd('LspAttach', {
    group = HighlightGroup,
    desc = 'Setup highlight symbol',
    callback = function(e)
        local id = vim.tbl_get(e, 'data', 'client_id')
        local client = id and vim.lsp.get_client_by_id(id)
        if client == nil or not client.supports_method('textDocument/documentHighlight') then
            return
        end

        local group = vim.api.nvim_create_augroup('highlight_symbol', { clear = false })

        vim.api.nvim_clear_autocmds({ buffer = e.buf, group = group })

        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            group = group,
            buffer = e.buf,
            callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            group = group,
            buffer = e.buf,
            callback = vim.lsp.buf.clear_references,
        })
    end
})

function R(name)
    require("plenary.reload").reload_module(name)
end

vim.filetype.add({
    extension = {
        temp1 = 'temp1',
    }
})

autocmd('TextYankPost', {
    group = YankGroup,
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

autocmd({ "BufWritePre" }, {
    group = MainGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

autocmd('LspAttach', {
    group = MainGroup,
    callback = function(e)
        local opts = { buffer = e.buf }
        require("sp00py.config.lspconfig.handlers").handlers()
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    end
})

vim.api.nvim_create_autocmd('ColorScheme', {
    group = MainGroup,
    desc = 'Clear LSP highlight groups',
    callback = function()
        for _, group in ipairs(vim.fn.getcompletion('@lsp', 'highlight')) do
            vim.api.nvim_set_hl(0, group, {})
        end
    end,
})

--autocmd('LspAttach', {
--    group = MainGroup,
--    desc = 'Enable vim.lsp.completion',
--    callback = function(e)
--        local client_id = vim.tbl_get(e, 'data', 'client_id')
--        if client_id == nil then
--            return
--        end
--        vim.lsp.completion.enable(true, client_id, e.buf, { autotrigger = false })
--        vim.keymap.set('i', '<C-Space>', '<cmd>lua vim.lsp.completion.trigger()<cr>')
--    end
--})

autocmd('LspAttach', {
    group = MainGroup,
    desc = 'Enable vim.lsp.inlay_hint',
    callback = function(e)
        local id = vim.tbl_get(e, 'data', 'client_id')
        local client = id and vim.lsp.get_client_by_id(id)
        if client == nil or not client.supports_method('textDocument/inlayHint') then
            return
        end

        vim.lsp.inlay_hint.enable(true, { bufnr = e.buf })
    end
})


-- setup for Godot LSP
--
if package.config:sub(1, 1) == '\\' then
    vim.opt.shell = 'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe'
    --windows
    if os.getenv('ncat') ~= nil then
        local port = os.getenv('GDScript_Port') or '6005'

        local cmd = { 'ncat', '127.0.0.1', port }
        local pipe = [[\\.\pipe\godot.pipe]]

        vim.lsp.start({
            name = 'Godot',
            cmd = cmd,
            root_dir = vim.fs.dirname(vim.fs.find({ 'project.godot', '.git' }, { upward = true })[1]),
            on_attach = function(client, bufnr)
                vim.api.nvim_command([[echo serverstart(']] .. pipe .. [[')]])
            end
        })
    end
else
    local port = os.getenv('GDScript_Port') or '6005'

    local cmd = vim.lsp.rpc.connect('127.0.0.1', port)
    local pipe = 'tmp/godot.pipe'

    vim.lsp.start({
        name = 'Godot',
        cmd = cmd,
        root_dir = vim.fs.dirname(vim.fs.find({ 'project.godot', '.git' }, { upward = true })[1]),
        on_attach = function(client, bufnr)
            vim.api.nvim_command([[echo serverstart(']] .. pipe .. [[')]])
        end
    })
end
