-- -----------------------------------------------------------------------------
-- 1. LEADER KEY
-- -----------------------------------------------------------------------------
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- -----------------------------------------------------------------------------
-- 2. CORE NEOCIM OPTIONS
-- -----------------------------------------------------------------------------
local opt = vim.opt -- for conciseness

-- General
opt.mouse = 'a'
opt.clipboard = 'unnamedplus'
vim.cmd.colorscheme 'murphy'

-- Numbers
opt.number = true
opt.relativenumber = true
opt.cursorline = true

-- Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- Appearance
opt.wrap = true
opt.breakindent = true
opt.scrolloff = 12 -- Keep cursor away from top/bottom edge

-- CursorLine colors
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#49115b" }) -- Subtle cursor line highlight
vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#00FFFF" })
vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#FFFF00" })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#B3FF00", bold=true })

-- Whitespace Characters
opt.list = true
opt.listchars = {
  eol = '↵',
  tab = '→ ',
  leadmultispace = '·',
  trail = '•',
}

-- -----------------------------------------------------------------------------
-- 3. GLOBAL KEYMAPS
-- -----------------------------------------------------------------------------
local keymap = vim.keymap
local keymap_opts = { noremap = true, silent = true }

-- File Explorer
keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', keymap_opts)

-- Telescope Fuzzy Finder
keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = "Find Files" })
keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = "Live Grep" })
keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = "Find Buffers" })
keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = "Help Tags" })

-- Hop Motions
keymap.set('n', '<leader>hw', '<cmd>HopWord<CR>', { desc = "Hop to Word" })
keymap.set('n', '<leader>hl', '<cmd>HopLine<CR>', { desc = "Hop to Line" })
keymap.set('n', '<leader>hc', '<cmd>HopChar1<CR>', { desc = "Hop to Character" })

-- Gitsigns
keymap.set('n', '<leader>gp', '<cmd>Gitsigns preview_hunk_inline<CR>', { desc = "Preview Hunk" })
keymap.set('n', '<leader>gt', '<cmd>Gitsigns toggle_current_line_blame<CR>', { desc = "Toggle Blame" })

-- Spectre Search and Replace
keymap.set('n', '<leader>S', '<cmd>Spectre<CR>', { desc = "Open Spectre" })
keymap.set('n', '<leader>sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', { desc = "Search Word" })
keymap.set('v', '<leader>sw', '<esc><cmd>lua require("spectre").open_visual()<CR>', { desc = "Search Selection" })
keymap.set('n', '<leader>sp', '<cmd>lua require("spectre").open_file_search({path = "%:p"})<CR>', { desc = "Search in File" })

-- -----------------------------------------------------------------------------
-- 4. PLUGIN MANAGER (LAZY.NVIM)
-- -----------------------------------------------------------------------------
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  ---------------------
  -- Core & UI
  ---------------------
  { 'nvim-lua/plenary.nvim' }, -- A dependency for many plugins

  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy', -- Load on a delayed event after startup
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        section_separators = { '', '' },
        component_separators = { '|', '|' },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff' },
        lualine_c = { { 'filename', path = 3 } },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
    },
  },

  {
    'nvim-tree/nvim-tree.lua',
    cmd = 'NvimTreeToggle', -- Load only when you run the command
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      view = { side = 'right', width = 30 },
      update_cwd = true,
      hijack_netrw = true,
    },
  },

  ---------------------
  -- Motions
  ---------------------
  {
    'phaazon/hop.nvim',
    branch = 'v2',
    cmd = { 'HopWord', 'HopLine', 'HopChar1' },
    config = function()
      require('hop').setup {
        multi_windows = true
      }
    end,
  },

  ---------------------
  -- Fuzzy Finding
  ---------------------
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },

  ---------------------
  -- Git Integration
  ---------------------
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },

  ---------------------
  -- Search & Replace
  ---------------------
  {
    'nvim-pack/nvim-spectre',
    cmd = 'Spectre',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },

  ---------------------
  -- Completion
  ---------------------
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
    end,
  },
})
