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
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/nvim-cmp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip"
    },
    config = function()
      local lspconfig = require('lspconfig')
      local cmp = require('cmp')
      local luasnip = require('luasnip')

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
      vim.keymap.set('n', '<D-o>', vim.lsp.buf.format, { noremap = true })
    end
  },
		{
  "nvimtools/none-ls.nvim",
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.prettier
      }
    })
  end
}
})

vim.api.nvim_set_keymap('n', 'n', 'i', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'i', 'k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'j', 'h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'k', 'j', { noremap = true, silent = true })

vim.api.nvim_set_keymap('v', 'n', 'i', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'i', 'k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'j', 'h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'k', 'j', { noremap = true, silent = true })

vim.api.nvim_set_keymap('i', '<D-s>', '<C-c>:w<CR>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('n', '<D-s>', ':w<CR>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('i', '<D-o>', '<Cmd>lua vim.lsp.buf.format()<CR>', {noremap=true, silent=true})
-- vim.api.nvim_set_keymap('n', '<D-o>', ':w<CR>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('n', '<S-l>', '<C-o>$', {noremap=true, silent=true})
vim.api.nvim_set_keymap('n', '<S-j>', '<C-o>^', {noremap=true, silent=true})
vim.api.nvim_set_keymap('n', '<D-.>', '<Cmd>lua vim.lsp.buf.code_action()<CR>', {noremap=true, silent=true})

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


