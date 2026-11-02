vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local opt = vim.opt

opt.updatetime = 250
opt.timeoutlen = 300
opt.undofile = true
opt.undolevels = 10000
opt.clipboard = 'unnamedplus'

opt.number = true
opt.relativenumber = true
opt.cursorline = true

opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.wrap = true
opt.breakindent = true
opt.scrolloff = 12
opt.sidescrolloff = 8
opt.termguicolors = true

opt.splitright = true
opt.splitbelow = true

opt.fillchars = { eob = ' ' }
opt.shortmess:append('I')

vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

vim.api.nvim_create_autocmd('VimEnter', {
  desc = 'Change cwd to directory passed as argument',
  callback = function()
    local arg = vim.fn.argv(0)
    if arg ~= '' and vim.fn.isdirectory(arg) == 1 then
      vim.cmd('cd ' .. vim.fn.fnameescape(arg))
    end
  end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    local hl = function(name, val) vim.api.nvim_set_hl(0, name, val) end
    hl('CursorLine',    { bg = '#501150' })
    hl('LineNrBelow',   { fg = '#00ffaa' })
    hl('LineNrAbove',   { fg = '#ffaaff' })
    hl('CursorLineNr',  { fg = '#B3FF00', bold = true })
    hl('SignColumn',    { bg = 'NONE' })
    hl('Normal',        { bg = 'NONE' })
    hl('NormalNC',      { bg = 'NONE' })
    hl('NormalFloat',   { bg = 'NONE' })
    hl('EndOfBuffer',   { bg = 'NONE' })
  end,
})
vim.cmd.colorscheme 'murphy'

opt.list = true
opt.listchars = {
  tab = '→ ',
  trail = '•',
}

local keymap = vim.keymap

local function term(cmd)
  vim.cmd('tabnew')
  vim.fn.jobstart(cmd, {
    term = true,
    on_exit = function() vim.cmd('tabclose'); vim.cmd('checktime') end,
  })
  vim.cmd('startinsert')
end

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
keymap.set('n', '<leader>gg', function() term({ 'lazygit' }) end, { desc = 'Lazygit' })

keymap.set('n', '<leader>S', function() term({ 'scooter' }) end, { desc = 'Scooter Search/Replace' })

keymap.set('n', '<leader>fm', 'mzgg=G`z', { desc = 'Format Buffer (Indent)' })
keymap.set('v', '<leader>fm', '=', { desc = 'Format Selection (Indent)' })

keymap.set('n', '<leader>u', '<cmd>UndotreeToggle<CR>', { desc = 'Toggle Undotree' })

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
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
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {},
  },

  {
    'nvim-lualine/lualine.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        section_separators = { '', '' },
        component_separators = { '|', '|' },
        globalstatus = false,
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
    cmd = 'NvimTreeToggle',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      view = { side = 'right', width = 30 },
      sync_root_with_cwd = true,
      hijack_netrw = true,
      filters = {
        git_ignored = false,
        dotfiles = false,
      },
      git = { enable = true, ignore = false },
    },
  },

  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'dashboard',
        callback = function()
          vim.opt.guicursor:append('a:Cursor/lCursor')
          vim.opt.ruler = false
          local hl = vim.api.nvim_get_hl(0, { name = 'Cursor' })
          hl.blend = 100
          vim.api.nvim_set_hl(0, 'Cursor', hl)
          vim.api.nvim_create_autocmd('BufUnload', {
            buffer = 0,
            once = true,
            callback = function()
              vim.opt.guicursor:remove('a:Cursor/lCursor')
              vim.opt.ruler = true
              hl.blend = 0
              vim.api.nvim_set_hl(0, 'Cursor', hl)
            end,
          })
        end,
      })
    end,
    opts = {
      theme = 'hyper',
      hide = { statusline = true, tabline = true },
      config = {
        week_header = { enable = false },
        header = {
          '⠀⠀⠀⠀⢠⡶⠚⢷⣤⡀⠀⠀⠀⠀⠀⣲⡶⠛⠻⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
          '⠀⠀⠀⢠⡿⠁⠀⠀⠙⣷⣄⠀⢀⣴⡟⠁⠀⠀⢷⢹⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀',
          '⠀⠀⠀⣾⠃⠀⠠⠶⠚⠛⠛⠛⠛⠋⠀⠀⣀⡀⢸⠈⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀',
          '⠀⠀⢸⣏⡔⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠚⠉⠉⣿⠀⢹⠀⠀⠀⠀⠀⠀⠀⠀⠀',
          '⠀⠀⢾⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀',
          '⠀⢠⣿⢠⣶⡆⠀⠀⠀⠀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀',
          '⢒⡾⠁⠘⠟⠁⠀⠀⠀⠀⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀',
          '⠉⣧⠀⠀⠀⠀⠃⠀⠀⠀⠈⠉⠠⣍⠀⠀⠀⠀⠀⠀⣸⡇⢀⣤⠶⠛⠛⠻⢦⣄',
          '⠀⠸⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⡟⣴⠟⠁⠀⠀⠀⠀⠀⢻',
          '⠀⠀⠀⠛⣷⡦⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣤⡴⠞⠋⢠⡟⠀⠀⠀⠀⠀⠀⢀⡾',
          '⠀⠀⠀⢰⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠳⣤⡀⢸⠃⠀⠀⠀⠀⢠⡶⠟⠁',
          '⠀⠀⠀⣸⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢷⣹⡄⠀⠀⠀⠀⣼⠀⠀⠀',
          '⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣇⠀⠀⠀⠀⢹⡄⠀⠀',
          '⠀⠀⠀⢸⡀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⡇⠀⠀⠀⠈⣧⠀⠀',
          '⠀⠀⠀⢸⡇⠘⡇⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀⢹⡇⠀',
          '⠀⠀⠀⢸⡇⠀⠙⠀⠀⠀⠀⠀⢠⠞⠁⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⢸⡇⠀',
          '⠀⠀⠀⢸⡇⠀⢸⡆⠀⠀⠀⠀⣟⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⠀⠀⠀⠀⣸⠇⠀',
          '⠀⠀⠀⢸⣿⠀⠀⡇⠀⠀⠀⠀⣿⡀⠀⠀⠀⠀⠀⠀⣠⢇⡿⠀⠀⢀⣴⡟⠁⠀',
          '⠀⠀⠀⠘⠿⠶⢶⢧⣦⣦⡴⢾⣥⣽⣤⣤⣤⣤⣤⣤⡿⣯⡤⠴⠶⠛⠋⠀⠀⠀',
        },
        shortcut = {},
        packages = { enable = false },
        project = { enable = false, limit = 0 },
        mru = { enable = false },
        footer = {},
      },
    },
  },

  {
    'smoka7/hop.nvim',
    cmd = { 'HopWord', 'HopLine', 'HopChar1' },
    opts = { multi_windows = true },
  },

  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      pickers = {
        find_files = {
          hidden = true,
        },
      },
    },
  },

  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },

  {
    'saghen/blink.cmp',
    event = 'InsertEnter',
    version = '1.*',
    dependencies = { 'mikavilpas/blink-ripgrep.nvim' },
    opts = {
      keymap = {
        preset = 'default',
        ['<Tab>'] = { 'accept', 'fallback' },
      },
      sources = {
        default = { 'buffer', 'path', 'ripgrep' },
        providers = {
          ripgrep = {
            module = 'blink-ripgrep',
            name = 'Ripgrep',
            score_offset = 100,
          },
        },
      },
    },
  },

  {
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    main = 'ibl',
    opts = {
      indent = { char = '│' },
      scope = { enabled = true },
    },
  },

  {
    'mbbill/undotree',
    cmd = { 'UndotreeToggle', 'UndotreeShow', 'UndotreeFocus' },
    init = function()
      vim.g.undotree_WindowLayout = 2
      vim.g.undotree_SplitWidth = 35
      vim.g.undotree_DiffpanelHeight = 12
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_ShortIndicators = 1
    end,
  },

  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {
      check_ts = true,
      disable_filetype = { 'TelescopePrompt', 'spectre_panel' },
    },
  },

  {
    'catgoose/nvim-colorizer.lua',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },

}, {
  ui = { border = 'rounded' },
  performance = {
    rtp = {
      reset = false,
      disabled_plugins = {
        'gzip',
        'netrwPlugin',
        'rplugin',
        'spellfile',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
})
