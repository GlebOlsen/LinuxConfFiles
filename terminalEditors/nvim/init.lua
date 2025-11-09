-- -----------------------------------------------------------------------------
-- 1. LEADER KEY
-- -----------------------------------------------------------------------------
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- -----------------------------------------------------------------------------
-- 2. CORE NEOVIM OPTIONS
-- -----------------------------------------------------------------------------
local opt = vim.opt

opt.mouse = 'a'
opt.clipboard = 'unnamedplus'
opt.undofile = true
opt.updatetime = 250
opt.timeoutlen = 300
vim.cmd.colorscheme 'murphy'

opt.number = true
opt.relativenumber = true
opt.cursorline = true

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

opt.wrap = true
opt.breakindent = true
opt.scrolloff = 12
opt.sidescrolloff = 8
opt.termguicolors = true

opt.splitright = true
opt.splitbelow = true

opt.lazyredraw = false
opt.swapfile = false
opt.backup = false

vim.api.nvim_set_hl(0, "CursorLine", { bg = "#49115b" })
vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#00FFFF" })
vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#FFFF00" })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#B3FF00", bold = true })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })

opt.list = true
opt.listchars = {
  -- eol = '↵',
  tab = '→ ',
  leadmultispace = '·',
  trail = '•',
}

-- -----------------------------------------------------------------------------
-- 3. GLOBAL KEYMAPS
-- -----------------------------------------------------------------------------
local keymap = vim.keymap

keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom window' })
keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to top window' })
keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

keymap.set('n', '<C-Up>', ':resize +2<CR>', { desc = 'Increase window height' })
keymap.set('n', '<C-Down>', ':resize -2<CR>', { desc = 'Decrease window height' })
keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', { desc = 'Decrease window width' })
keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', { desc = 'Increase window width' })

keymap.set('v', '<', '<gv', { desc = 'Indent left and reselect' })
keymap.set('v', '>', '>gv', { desc = 'Indent right and reselect' })

keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move text down' })
keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move text up' })

keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center' })
keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up and center' })
keymap.set('n', 'n', 'nzzzv', { desc = 'Next search result and center' })
keymap.set('n', 'N', 'Nzzzv', { desc = 'Previous search result and center' })

keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlighting' })

keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { desc = 'Toggle File Explorer' })

keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = 'Find Files' })
keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = 'Live Grep' })
keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = 'Find Buffers' })
keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = 'Help Tags' })
keymap.set('n', '<leader>fr', '<cmd>Telescope oldfiles<cr>', { desc = 'Recent Files' })
keymap.set('n', '<leader>fc', '<cmd>Telescope grep_string<cr>', { desc = 'Find String Under Cursor' })

keymap.set('n', '<leader>hw', '<cmd>HopWord<CR>', { desc = 'Hop to Word' })
keymap.set('n', '<leader>hl', '<cmd>HopLine<CR>', { desc = 'Hop to Line' })
keymap.set('n', '<leader>hc', '<cmd>HopChar1<CR>', { desc = 'Hop to Character' })

keymap.set('n', '<leader>gp', '<cmd>Gitsigns preview_hunk_inline<CR>', { desc = 'Preview Hunk' })
keymap.set('n', '<leader>gt', '<cmd>Gitsigns toggle_current_line_blame<CR>', { desc = 'Toggle Blame' })
keymap.set('n', '<leader>gd', '<cmd>Gitsigns diffthis<CR>', { desc = 'Diff This' })
keymap.set('n', '<leader>gr', '<cmd>Gitsigns reset_hunk<CR>', { desc = 'Reset Hunk' })
keymap.set('n', '<leader>gR', '<cmd>Gitsigns reset_buffer<CR>', { desc = 'Reset Buffer' })

keymap.set('n', '<leader>S', '<cmd>Spectre<CR>', { desc = 'Open Spectre' })
keymap.set('n', '<leader>sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', { desc = 'Search Word' })
keymap.set('v', '<leader>sw', '<esc><cmd>lua require("spectre").open_visual()<CR>', { desc = 'Search Selection' })
keymap.set('n', '<leader>sp', '<cmd>lua require("spectre").open_file_search({path = "%:p"})<CR>', { desc = 'Search in File' })

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
  { 'nvim-lua/plenary.nvim' },

  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        section_separators = { '', '' },
        component_separators = { '|', '|' },
        globalstatus = true,
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

  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      indent = {
        char = '│',
        tab_char = '│',
      },
      scope = { enabled = false },
    },
    config = function(_, opts)
      local hooks = require('ibl.hooks')
      local highlight = {
        'RainbowRed',
        'RainbowYellow',
        'RainbowBlue',
        'RainbowOrange',
        'RainbowGreen',
        'RainbowViolet',
        'RainbowCyan',
      }

      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, 'RainbowRed', { fg = '#E06C75' })
        vim.api.nvim_set_hl(0, 'RainbowYellow', { fg = '#E5C07B' })
        vim.api.nvim_set_hl(0, 'RainbowBlue', { fg = '#61AFEF' })
        vim.api.nvim_set_hl(0, 'RainbowOrange', { fg = '#D19A66' })
        vim.api.nvim_set_hl(0, 'RainbowGreen', { fg = '#98C379' })
        vim.api.nvim_set_hl(0, 'RainbowViolet', { fg = '#C678DD' })
        vim.api.nvim_set_hl(0, 'RainbowCyan', { fg = '#56B6C2' })
      end)

      opts.indent.highlight = highlight
      require('ibl').setup(opts)
    end,
  },

  {
    'phaazon/hop.nvim',
    branch = 'v2',
    cmd = { 'HopWord', 'HopLine', 'HopChar1' },
    config = function()
      require('hop').setup({ multi_windows = true })
    end,
  },

  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },

  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },

  {
    'nvim-pack/nvim-spectre',
    cmd = 'Spectre',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },

  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        }),
        sources = {
          { name = 'buffer', keyword_length = 4 },
          { name = 'path' },
        },
      })
    end,
  },

  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {
      check_ts = true,
      disable_filetype = { 'TelescopePrompt' },
    },
    config = function(_, opts)
      local npairs = require('nvim-autopairs')
      npairs.setup(opts)
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      local cmp = require('cmp')
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },

  {
    'numToStr/Comment.nvim',
    keys = {
      { 'gcc', mode = 'n', desc = 'Comment toggle current line' },
      { 'gc', mode = { 'n', 'o' }, desc = 'Comment toggle linewise' },
      { 'gc', mode = 'x', desc = 'Comment toggle linewise (visual)' },
      { 'gbc', mode = 'n', desc = 'Comment toggle current block' },
      { 'gb', mode = { 'n', 'o' }, desc = 'Comment toggle blockwise' },
      { 'gb', mode = 'x', desc = 'Comment toggle blockwise (visual)' },
    },
    opts = {},
  },
}, {
  ui = { border = 'rounded' },
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
})
