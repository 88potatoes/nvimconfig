vim.api.nvim_set_keymap('i', '<D-s>', '<C-c>:w<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<D-s>', ':w<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<D-o>', '<Cmd>lua vim.lsp.buf.format()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<D-o>', '<Cmd>lua vim.lsp.buf.format()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-l>', '<C-o>$', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-j>', '<C-o>^', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<D-.>', '<Cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })

-- Move chunks of lines up/down
-- Normal mode
vim.keymap.set('n', '<C-j>', ':m .+1<CR>==', { noremap = true, silent = true })
vim.keymap.set('n', '<C-k>', ':m .-2<CR>==', { noremap = true, silent = true })

-- Insert mode
vim.keymap.set('i', '<C-j>', '<Esc>:m .+1<CR>==gi', { noremap = true, silent = true })
vim.keymap.set('i', '<C-k>', '<Esc>:m .-2<CR>==gi', { noremap = true, silent = true })

-- Visual mode
vim.keymap.set('v', '<C-j>', ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set('v', '<C-k>', ":m '<-2<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set('n', '<D-S-w>', function()
	local current_buf = vim.api.nvim_get_current_buf()
	vim.cmd('bdelete ' .. current_buf)
end, { noremap = true, silent = true })

-- vim.keymap.set('n', '<leader>e', function()
-- 	local diagnostics = vim.diagnostic.get(0)
-- 	if #diagnostics > 0 then
-- 		vim.fn.setreg('+', diagnostics[1].message)
-- 	end
-- end)

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local telescope = require('telescope.builtin')

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Set up plugins
require("lazy").setup({
		'nvim-telescope/telescope.nvim',
		tag = '0.1.5', -- or try 'master' if you want the latest
		dependencies = {
			'nvim-lua/plenary.nvim',
			{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }, "nvim-tree/nvim-web-devicons", -- optional
		},
		-- Bufferline
		{
			'akinsho/bufferline.nvim',
			version = "*",
			dependencies = 'nvim-tree/nvim-web-devicons',
			config = function()
				require("bufferline").setup({
					options = {
						-- Basic settings
						mode = "buffers", -- can be "buffers" or "tabs"
						numbers = "none", -- can be "none" | "ordinal" | "buffer_id"

						-- Position settings
						position = "bottom", -- top | bottom

						-- Style
						separator_style = "thin", -- "slant" | "thick" | "thin" | { 'any', 'any' }

						-- Colors and highlighting
						indicator = {
							style = 'underline' -- style for the indicator
						},

						-- Behavior
						close_command = "bdelete! %d",
						diagnostics = "nvim_lsp"
					}
				})
			end,
		},
		-- Treesitter setup
		{
			"nvim-treesitter/nvim-treesitter",
			opts = {
				auto_install = true,
				autotag = {
					enable = true,
					filetypes = {
						'html', 'javascript', 'typescript', 'svelte', 'vue', 'tsx', 'jsx',
						'rescript',
						'css', 'lua', 'xml', 'php', 'markdown'
					},
				},
				indent = { enable = true },
				ensure_installed = {
					-- defaults
					"vim",
					"lua",
					"vimdoc",

					-- web dev
					"html",
					"css",
					"javascript",
					"typescript",
					"tsx",
					"astro",
					"vue",
					"svelte",
					"markdown",
					"markdown_inline",
					"json",
					"scss",
					"yaml"
				}
			}
		},
		{
			"windwp/nvim-ts-autotag",
			dependencies = "nvim-treesitter/nvim-treesitter",
			config = function()
				require('nvim-ts-autotag').setup()
			end,
			lazy = true,
			event = "VeryLazy"
		},
		{
			"rstacruz/vim-closer",
			event = "InsertEnter", -- Load when entering insert mode
		},
		-- LSP setup
		{
			"neovim/nvim-lspconfig",
			dependencies = {
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-buffer",
				"hrsh7th/cmp-path",
				"hrsh7th/nvim-cmp",
				"L3MON4D3/LuaSnip",
				"saadparwaiz1/cmp_luasnip",
				"williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim"
			},
			config = function()
				local lspconfig = require('lspconfig')
				local cmp = require('cmp')
				local luasnip = require('luasnip')
				require("mason").setup()
				require("mason-lspconfig").setup({
					ensure_installed = { "lua_ls" },
					automatic_installation = true,
				})
				-- Set up nvim-cmp
				cmp.setup({
					snippet = {
						expand = function(args)
							luasnip.lsp_expand(args.body)
						end,
					},
					mapping = cmp.mapping.preset.insert({
						['<C-b>'] = cmp.mapping.scroll_docs(-4),
						['<C-f>'] = cmp.mapping.scroll_docs(4),
						['<C-Space>'] = cmp.mapping.complete(),
						['<C-e>'] = cmp.mapping.abort(),
						['<CR>'] = cmp.mapping.confirm({ select = true }),
						['<Tab>'] = cmp.mapping(function(fallback)
							if cmp.visible() then
								cmp.select_next_item()
							elseif luasnip.expand_or_jumpable() then
								luasnip.expand_or_jump()
							else
								fallback()
							end
						end, { 'i', 's' }),
						['<S-Tab>'] = cmp.mapping(function(fallback)
							if cmp.visible() then
								cmp.select_prev_item()
							elseif luasnip.jumpable(-1) then
								luasnip.jump(-1)
							else
								fallback()
							end
						end, { 'i', 's' }),
					}),
					sources = cmp.config.sources({
						{ name = 'nvim_lsp' },
						{ name = 'luasnip' },
						{ name = 'buffer' },
						{ name = 'path' }
					})
				})

				local capabilities = require('cmp_nvim_lsp').default_capabilities()
				lspconfig.pyright.setup {
					capabilities = capabilities
				}
				lspconfig.ts_ls.setup {
					capabilities = capabilities
				}
				vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
				vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
				vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {})
				lspconfig.lua_ls.setup({
					settings = {
						Lua = {
							runtime = {
								-- Tell the language server which version of Lua you're using
								version = 'LuaJIT',
							},
							diagnostics = {
								-- Get the language server to recognize the `vim` global
								globals = { 'vim' },
							},
							workspace = {
								-- Make the server aware of Neovim runtime files
								library = vim.api.nvim_get_runtime_file("", true),
								checkThirdParty = false, -- Disable third party checks
							},
							telemetry = {
								enable = false,
							},
						},
					},
				})
			end

		},
		{
			"nvimtools/none-ls.nvim",
			config = function()
				local null_ls = require("null-ls")
				null_ls.setup({
					sources = {
						-- js / ts
						null_ls.builtins.formatting.prettier,
						null_ls.builtins.diagnostics.eslint,
						-- Lua
						null_ls.builtins.formatting.prettier,

					}
				})
			end
		},
		{
			'numToStr/Comment.nvim', opts = {}
		},
		"nvim-tree/nvim-tree.lua",

		config = function()
			require("nvim-tree").setup()
		end
	},
	{ 'akinsho/toggleterm.nvim', version = "*", config = true }, {
		"williamboman/mason.nvim",
		build = ":MasonUpdate", -- :MasonUpdate updates registry contents
		config = function()
			require("mason").setup()
		end,
	}, {
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls" },
				automatic_installation = true,
			})
		end,
	})
vim.opt.number = true

vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.shiftwidth = 2

vim.expandtab = true

vim.keymap.set('n', '<D-Space>', 'o<Esc>', { noremap = true, silent = true })
vim.opt.clipboard = 'unnamedplus'
vim.keymap.set('i', '<A-BS>', '<C-w>')

vim.api.nvim_create_autocmd('FileType', {
	pattern = 'netrw',
	callback = function()
		local buf = vim.api.nvim_get_current_buf()
		-- Just try one simple mapping first
		vim.keymap.set('n', 'i', 'k', { buffer = buf })
	end
})

vim.cmd [[autocmd FileType netrw nnoremap <buffer> i k]]
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set('n', '<leader>pf', telescope.find_files, {})
vim.keymap.set('n', '<leader>fg', telescope.live_grep)
vim.keymap.set('n', '<leader>fd', function() telescope.diagnostics({ bufnr = 0 }) end, {})

require('telescope').setup({
	defaults = {
		mappings = {
			i = {
				["<M-BS>"] = function()
					vim.api.nvim_input("<C-w>") -- Ctrl-w is the default vim command to delete a word backward
				end,
				["<D-BS>"] = function()
					vim.api.nvim_input("dd")
				end
			}
		}
	}
})

require('Comment').setup()

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

require("nvim-tree").setup({
	sort = {
		sorter = "case_sensitive",
	},
	view = {
		width = 30,
	},
	renderer = {
		group_empty = true,
	},
	filters = {
		dotfiles = true,
	},
})

vim.treesitter.language.register('tsx', 'typescriptreact')

-- require('nvim-ts-autotag').setup({
-- 	opts = {
-- 		-- Defaults
-- 		enable_close = true, -- Auto close tags
-- 		enable_rename = true, -- Auto rename pairs of tags
-- 		enable_close_on_slash = false -- Auto close on trailing </
-- 	},
-- 	per_filetype = {
-- 		["html"] = {
-- 			enable_close = false
-- 		}
-- 	}
-- })
