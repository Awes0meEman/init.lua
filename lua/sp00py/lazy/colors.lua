function ColorMyPencils(color)
	color = color or "cyberdream"
	vim.cmd.colorscheme(color)
end

return {
	{
		"folke/tokyonight.nvim",
		config = function()
			require("tokyonight").setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
				style = "storm", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
				transparent = false, -- Enable this to disable setting the background color
				terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
				styles = {
					-- Style to be applied to different syntax groups
					-- Value is any valid attr-list value for `:help nvim_set_hl`
					comments = { italic = false },
					keywords = { italic = false },
					-- Background styles. Can be "dark", "transparent" or "normal"
					sidebars = "dark", -- style for sidebars, see below
					floats = "dark", -- style for floating windows
				},
			})
        ColorMyPencils()
		end
	},
    {
        "scottmckendry/cyberdream.nvim"
    },
    {
        "eldritch-theme/eldritch.nvim",
        lazy = "false",
        priority = 1000,
        opts = {}
    }
}
