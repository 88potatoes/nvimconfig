-- Bootstrap lazy.nvim
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
    tag = '0.1.5',  -- or try 'master' if you want the latest
    dependencies = {
        'nvim-lua/plenary.nvim',
        {'nvim-telescope/telescope-fzf-native.nvim', build = 'make'},
    },
	-- Treesitter setup
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "vim", "javascript", "python" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  },

  -- LSP setup
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      local lspconfig = require('lspconfig')
      
      lspconfig.pyright.setup{}
      lspconfig.ts_ls.setup{}
      
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {})
    end
  }
})

vim.api.nvim_set_keymap('n', 'n', 'i', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'i', 'k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'j', 'h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'k', 'j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'l', 'l', { noremap = true, silent = true })

vim.api.nvim_set_keymap('v', 'n', 'i', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'i', 'k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'j', 'h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'k', 'j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'l', 'l', { noremap = true, silent = true })

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4	
vim.shiftwidth = 4

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

vim.cmd[[autocmd FileType netrw nnoremap <buffer> i k]]
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set('n', '<leader>pf', telescope.find_files, {})
vim.keymap.set('n', '<leader>fg', telescope.live_grep)

require('telescope').setup({
  defaults = {
    mappings = {
      i = {
        ["<M-BS>"] = function()
          vim.api.nvim_input("<C-w>")  -- Ctrl-w is the default vim command to delete a word backward
        end,
		["<D-BS>"] = function()
		  vim.api.nvim_input("dd")
		end
      }
    }
  }
})


