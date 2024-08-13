require("sp00py.set")
require("sp00py.remap")
require("sp00py.lazy_init")


local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local MainGroup = augroup('MainGroup', {})
local YankGroup = augroup('HighlightYank', {})

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

autocmd({"BufWritePre"}, {
	group = MainGroup,
	pattern = "*",
	command = [[%s/\s\+$//e]],
})

autocmd('LspAttach', {
    group = MainGroup,
    callback = function(e)
        local opts = { buffer = e.buf }
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

-- setup for Godot LSP
local port = os.getenv('GDScript_Port') or '6005'
local cmd = {'ncat', '127.0.0.1', port}
local pipe = [[\\.\pipe\godot.pipe]]

vim.lsp.start({
  name = 'Godot',
  cmd = cmd,
  root_dir = vim.fs.dirname(vim.fs.find({ 'project.godot', '.git' }, { upward = true })[1]),
  on_attach = function(client, bufnr)
    vim.api.nvim_command([[echo serverstart(']] .. pipe .. [[')]])
  end
})
