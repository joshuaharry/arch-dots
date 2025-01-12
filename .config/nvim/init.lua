-- Always display line numbers.
vim.opt.number = true
-- Use spaces instead of tabs, and make 2 spaces one tab
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
-- Set some nice keybindings
vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.keymap.set("n", "q", ":q<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>w", "<C-w><C-w>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>j", ":bnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>k", ":bprev<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>f", "za", { noremap = true, silent = true })

-- Make sure that vim-closetag works on ERB files. We have to set this
-- global variable *before* we configure our plugin manager; otherwise,
-- the plugin doesn't actually work for mysterious raisins.
vim.g.closetag_filetypes = "astro,eruby,template,typescriptreact,javascriptreact,vue,html,heex"

-- First, bootstrap lazy.nvim, our plugin manager.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
	-- Auto pairs
	"cohama/lexima.vim",
	-- Formatting
	"stevearc/conform.nvim",
	-- Comments
	"numToStr/Comment.nvim",
	-- Language servers
	"neovim/nvim-lspconfig",
	-- YATS
	"HerringtonDarkholme/yats.vim",
	-- JSX Indentation
	"MaxMEllon/vim-jsx-pretty",
	-- Manage close tags
	"alvan/vim-closetag",
	-- Language server installation
	{ "williamboman/mason.nvim", opts = {} },
	-- Fuzzy searching
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	-- Autocomplete
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
		},
		config = function()
			local cmp = require("cmp")
			-- Set up jump to definition
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, { noremap = true, silent = true })

			-- Make error messages appear inside popups
			vim.o.updatetime = 250

			vim.diagnostic.config({
				virtual_text = true,
				float = {
					source = "always",
					width = 80,
					border = border,
				},
			})

			vim.api.nvim_create_autocmd({
				"CursorHold",
				"CursorHoldI",
			}, {
				callback = function()
					if not cmp.visible() then
						vim.diagnostic.open_float(nil, { focus = false })
					end
				end,
			})

			cmp.setup({
				snippet = {
					expand = function(args)
						require("snippy").expand_snippet(args.body)
					end,
				},
				completion = {
					autocomplete = false,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-n>"] = cmp.mapping(function()
						if cmp.visible() then
							cmp.select_next_item()
						else
							cmp.complete()
						end
					end),
					["<C-e>"] = cmp.mapping.abort(),
					["<C-space>"] = cmp.mapping.complete(),
					["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
					-- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "snippy" },
					{ name = "path" },
					{ name = "buffer" },
				}),
			})
		end,
	},
	-- Snippets
	"dcampos/nvim-snippy",
	"dcampos/cmp-snippy",
	-- Language server config
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"pyright",
				"gopls",
				"ts_ls",
				"eslint",
				"tailwindcss",
				"astro",
			},
			handlers = {
				function(server_name)
					require("lspconfig")[server_name].setup({})
				end,
				["tailwindcss"] = function()
					require("lspconfig").tailwindcss.setup({
						filetypes = { "heex", "eruby", "typescriptreact", "html", "astro" },
					})
				end,
			},
		},
	},
})

-- Configure telescope.nvim
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>sf", builtin.find_files, {})
vim.keymap.set("n", "<leader>sg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>sb", builtin.buffers, {})

-- Configure conform, our formatting plugin
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "ruff_format" },
		rust = { "rustfmt", lsp_format = "fallback" },
		go = { "gofmt", lsp_format = "fallback" },
		javascript = { "prettier", stop_after_first = true },
		typescriptreact = { "prettier", stop_after_first = true },
		json = { "prettier", stop_after_first = true },
		markdown = { "prettier", stop_after_first = true },
		astro = { "prettier", stop_after_first = true },
		yaml = { "prettier", stop_after_first = true },
		html = { "prettier", stop_after_first = true },
	},
})
vim.keymap.set("n", "<leader>p", function()
	require("conform").format()
end, { noremap = true, silent = true, desc = "Format code" })

-- Configure our commenting plugin
require("Comment").setup()

-- Use a light colorscheme.
vim.cmd([[ colorscheme zellner ]])
