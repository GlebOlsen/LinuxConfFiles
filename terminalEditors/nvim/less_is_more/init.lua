-- Need rg, lazygit scooter for stuff to fully work

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.loaded_tutor_mode_plugin = 1

local opt = vim.opt

opt.updatetime = 250
opt.timeoutlen = 1000
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
opt.breakindent = true
opt.scrolloff = 12
opt.sidescrolloff = 8
opt.termguicolors = true

opt.splitright = true
opt.splitbelow = true

opt.fillchars = { eob = ' ' }
opt.shortmess:append('I')

opt.autocomplete = true
opt.completeopt = { 'fuzzy' }
opt.pumheight = 12
opt.pummaxwidth = 40

opt.path:append('**')
opt.wildmode = 'longest:full,full'
opt.wildoptions = { 'pum', 'fuzzy' }
opt.wildignorecase = true
opt.wildignore:append({ '*/.git/*', '*/node_modules/*', '*/.venv/*' })

if vim.fn.executable('rg') == 1 then
  opt.grepprg = 'rg --vimgrep --smart-case'
end

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 25
vim.g.netrw_bufsettings = 'noma nomod nu rnu nobl nowrap ro'

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'netrw',
  desc = 'Stop double-click from going up a directory (netrw maps <2-LeftMouse> to -)',
  callback = function(args)
    vim.keymap.set('n', '<2-LeftMouse>', '<Nop>', { buffer = args.buf })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  pattern = { 'grep', 'grepadd' },
  command = 'cwindow',
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'DirChanged' }, {
  callback = function(args)
    if vim.bo[args.buf].buftype ~= '' then return end
    local name = vim.api.nvim_buf_get_name(args.buf)
    local dir = name ~= '' and vim.fn.fnamemodify(name, ':h') or vim.fn.getcwd()
    vim.system({ 'git', '-C', dir, 'rev-parse', '--abbrev-ref', 'HEAD' }, { text = true }, function(obj)
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(args.buf) then return end
        vim.b[args.buf].git_head = obj.code == 0 and vim.trim(obj.stdout or '') or ''
      end)
    end)
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
    hl('LimTermNormal', { bg = '#000000' })
  end,
})
vim.cmd.colorscheme 'murphy'

for i, c in ipairs({
  '#242424', '#f62b5a', '#47b413', '#e3c401', '#24acd4', '#f2affd', '#13c299', '#e6e6e6',
  '#616161', '#ff4d51', '#35d450', '#e9e836', '#5dc5f8', '#feabf2', '#24dfc4', '#ffffff',
}) do
  vim.g['terminal_color_' .. (i - 1)] = c
end

opt.list = true
opt.listchars = {
  tab = '→ ',
  trail = '•',
  leadmultispace = '│ ',
}

local modes = {
  n = 'NORMAL', i = 'INSERT', v = 'VISUAL', V = 'V-LINE', ['\22'] = 'V-BLOCK',
  c = 'COMMAND', R = 'REPLACE', t = 'TERMINAL', s = 'SELECT', S = 'S-LINE',
}

function _G.LimStatuslineMode()
  return modes[vim.fn.mode()] or vim.fn.mode():upper()
end

function _G.LimStatuslineGit()
  local h = vim.b.git_head
  if h and h ~= '' then return '  ⎇ ' .. h .. ' ' end
  return ''
end

opt.statusline = table.concat({
  ' %{v:lua.LimStatuslineMode()} ',
  '%{v:lua.LimStatuslineGit()}',
  ' %<%F %m%r',
  '%=',
  '%y ',
  '%{&fileencoding} ',
  '%{&fileformat} ',
  ' %l:%c ',
  ' %P ',
})

local keymap = vim.keymap

local function term(cmd)
  local function cfg()
    return { relative = 'editor', row = 0, col = 0, width = vim.o.columns, height = vim.o.lines - 1 }
  end
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, vim.tbl_extend('force', cfg(), { style = 'minimal' }))
  vim.wo[win].winhighlight = 'NormalFloat:LimTermNormal,FloatBorder:LimTermNormal'
  local grp = vim.api.nvim_create_augroup('LimTerm', { clear = true })
  vim.api.nvim_create_autocmd('VimResized', {
    group = grp,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_set_config(win, cfg()) end
    end,
  })
  vim.fn.jobstart(cmd, {
    term = true,
    on_exit = function()
      pcall(vim.api.nvim_del_augroup_by_id, grp)
      if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
      vim.cmd('checktime')
    end,
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

keymap.set('i', '<Tab>', function()
  if vim.fn.pumvisible() == 1 then
    return vim.fn.complete_info({ 'selected' }).selected ~= -1 and '<C-y>' or '<C-n>'
  end
  return '<Tab>'
end, { expr = true, desc = 'Accept or select next completion' })

keymap.set('i', '<S-Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>'
end, { expr = true, desc = 'Select previous completion' })

keymap.set('n', '<leader>e', '<cmd>Lexplore!<CR>', { desc = 'Toggle File Explorer' })

keymap.set('n', '<leader>ff', ':find ', { desc = 'Find Files' })
keymap.set('n', '<leader>fg', ':grep ', { desc = 'Grep' })
keymap.set('n', '<leader>fb', ':buffer ', { desc = 'Find Buffers' })
keymap.set('n', '<leader>fh', ':help ', { desc = 'Help Tags' })
keymap.set('n', '<leader>fr', '<cmd>browse oldfiles<CR>', { desc = 'Recent Files' })
keymap.set('n', '<leader>fc', ':grep <C-r><C-w><CR>', { desc = 'Grep Word Under Cursor' })

keymap.set('n', '<leader>gg', function() term({ 'lazygit' }) end, { desc = 'Lazygit' })
keymap.set('n', '<leader>S', function() vim.cmd('silent! wall') term({ 'scooter' }) end, { desc = 'Scooter Search/Replace' })

keymap.set('n', '<leader>fm', 'mzgg=G`z', { desc = 'Format Buffer (Indent)' })
keymap.set('v', '<leader>fm', '=', { desc = 'Format Selection (Indent)' })

keymap.set('n', '<leader>u', '<cmd>undolist<CR>', { desc = 'Undo List' })
