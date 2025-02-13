-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
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
  -- Add your plugins here:
  -- "folke/which-key.nvim",
  -- { "folke/neoconf.nvim", cmd = "Neoconf" }
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
