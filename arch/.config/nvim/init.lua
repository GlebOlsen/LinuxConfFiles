-- Plugin-free, Neovim 0.12+. Needs: ripgrep fzf git lazygit scooter glow xclip (wl-clipboard on Wayland)

vim.g.mapleader = ' '
vim.g.loaded_tutor_mode_plugin = 1

local opt = vim.opt
local map = vim.keymap.set
local autocmd = vim.api.nvim_create_autocmd

opt.undofile = true
opt.undolevels = 10000
opt.clipboard = 'unnamedplus'
opt.updatetime = 250

opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.breakindent = true

opt.ignorecase = true
opt.smartcase = true
if vim.fn.executable('rg') == 1 then
  opt.grepprg = 'rg --vimgrep --smart-case'
end

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.scrolloff = 12
opt.sidescrolloff = 8
opt.termguicolors = true
opt.showtabline = 0
opt.splitright = true
opt.splitbelow = true
opt.fillchars = { eob = ' ' }
opt.shortmess:append('I')
opt.list = true
opt.listchars = {
  tab = '→ ',
  trail = '•',
}

opt.autocomplete = true
opt.completeopt = { 'menu', 'fuzzy' }
opt.pumheight = 12
opt.pummaxwidth = 40

opt.wildmode = 'longest:full,full'
opt.wildoptions = { 'pum', 'fuzzy' }
opt.wildignorecase = true
opt.wildignore:append({ '*/.git/*', '*/node_modules/*', '*/.venv/*' })

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 25
vim.g.netrw_bufsettings = 'noma nomod nu rnu nobl nowrap ro'

autocmd('ColorScheme', {
  callback = function()
    local function hl(key, colors)
      for color, groups in pairs(colors) do
        for _, group in ipairs(groups) do vim.api.nvim_set_hl(0, group, { [key] = color }) end
      end
    end
    hl('bg', {
      ['#1e2d22'] = { 'CursorLine', 'Pmenu' },
      ['#3A4A00'] = { 'Visual', 'PmenuSel' },
      NONE = { 'SignColumn', 'Normal', 'NormalNC', 'NormalFloat', 'EndOfBuffer' },
    })
    -- javaScriptBraces: JS has no bundled treesitter parser; legacy syntax links braces to Function
    hl('fg', {
      ['#FFFFFF'] = { 'Identifier', 'Special', 'Delimiter', '@variable', 'javaScriptBraces' },
      ['#FF00FF'] = { 'Statement', 'PreProc' },
      ['#00FF00'] = { 'Function', '@function.builtin' },
      ['#3399FF'] = { 'Type', '@type.builtin' },
      ['#FFFF00'] = { 'Constant', '@constant.builtin' },
      ['#FF8000'] = { 'String', 'Character' },
      ['#00FFFF'] = { 'Operator' },
      ['#808080'] = { 'Comment' },
      ['#00ffaa'] = { 'LineNrBelow' },
      ['#ffaaff'] = { 'LineNrAbove' },
    })
    vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#B3FF00', bold = true })
  end,
})
vim.cmd.colorscheme 'vim'

for i, c in ipairs({
  '#242424', '#f62b5a', '#47b413', '#e3c401', '#24acd4', '#f2affd', '#13c299', '#e6e6e6',
  '#616161', '#ff4d51', '#35d450', '#e9e836', '#5dc5f8', '#feabf2', '#24dfc4', '#ffffff',
}) do
  vim.g['terminal_color_' .. (i - 1)] = c
end

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

-- BufEnter: branch is per buffer; FocusGained: branch switched outside nvim; DirChanged: unnamed buffers
autocmd({ 'BufEnter', 'FocusGained', 'DirChanged' }, {
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

autocmd('VimEnter', {
  desc = 'Change cwd to directory passed as argument',
  callback = function()
    local arg = vim.fn.argv(0)
    if arg ~= '' and vim.fn.isdirectory(arg) == 1 then
      vim.cmd('cd ' .. vim.fn.fnameescape(arg))
    end
  end,
})

-- BufEnter: built-in autoread only rechecks the buffer being entered, not files open in other windows
autocmd({ 'FocusGained', 'BufEnter' }, {
  desc = 'Reload files changed outside Neovim',
  callback = function()
    if vim.fn.getcmdwintype() == '' then vim.cmd('checktime') end
  end,
})

autocmd('FileType', {
  pattern = 'netrw',
  desc = 'Stop double-click from going up a directory (netrw maps <2-LeftMouse> to -)',
  callback = function(args)
    map('n', '<2-LeftMouse>', '<Nop>', { buffer = args.buf })
  end,
})

autocmd('QuickFixCmdPost', {
  pattern = { 'grep', 'grepadd' },
  command = 'cwindow',
})

local function open_pick(s)
  local file, lnum, col = s:match('^(.-):(%d+):(%d+)')
  if not file then file, lnum = s:match('^(.-):(%d+)$') end
  vim.cmd.drop(vim.fn.fnameescape(file or s))
  if lnum then
    pcall(vim.api.nvim_win_set_cursor, 0, { tonumber(lnum), math.max((tonumber(col) or 1) - 1, 0) })
    vim.cmd('normal! zz')
  end
end

-- Runs a TUI in its own tab; a path[:line[:col]] written to $LIM_PICK is opened on exit
local function term(cmd)
  local pick = vim.fn.tempname()
  vim.cmd('tabnew')
  local buf = vim.api.nvim_get_current_buf()
  vim.o.laststatus = 0
  vim.fn.jobstart(cmd, {
    term = true,
    env = { LIM_PICK = pick },
    on_exit = function()
      if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
      vim.o.laststatus = 2
      vim.cmd('checktime')
      local picked = vim.fn.filereadable(pick) == 1 and vim.fn.readfile(pick)[1]
      vim.fn.delete(pick)
      if picked and picked ~= '' then open_pick(picked) end
    end,
  })
  vim.cmd('startinsert')
end

local fzf_preview = " --preview 'head -n 200 -- {}'"

local function pick_files()
  term('rg --files --hidden --glob "!.git" | fzf' .. fzf_preview .. ' > "$LIM_PICK"')
end

-- Paths are shown relative to cwd
local function pick_list(paths)
  local src = vim.fn.tempname()
  vim.fn.writefile(vim.tbl_map(function(p) return vim.fn.fnamemodify(p, ':.') end, paths), src)
  term('fzf' .. fzf_preview .. ' < ' .. vim.fn.shellescape(src) .. ' > "$LIM_PICK"')
end

local function pick_buffers()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  table.sort(bufs, function(a, b) return a.lastused > b.lastused end)
  local names = vim.tbl_map(function(b) return b.name end, bufs)
  pick_list(vim.tbl_filter(function(name) return name ~= '' end, names))
end

local function pick_recent()
  pick_list(vim.tbl_filter(function(f) return vim.fn.filereadable(f) == 1 end, vim.v.oldfiles))
end

-- Live grep: rg reruns on every keystroke, Enter jumps to the match
local function pick_grep(query)
  local rg = '[ -n {q} ] && rg --column --line-number --no-heading --color=always --smart-case'
    .. ' --hidden --glob "!.git" -- {q} || true'
  term(': | fzf --disabled --ansi --delimiter : --query ' .. vim.fn.shellescape(query or '')
    .. " --bind 'start:reload:" .. rg .. "' --bind 'change:reload:" .. rg .. "'"
    .. " --preview 'cat -n -- {1}' --preview-window '+{2}/2' > \"$LIM_PICK\"")
end

local function blame_line()
  local out = vim.fn.systemlist({
    'git', '-C', vim.fn.expand('%:p:h'), 'blame', '-L', vim.fn.line('.') .. ',+1', '--', vim.fn.expand('%:p'),
  })
  vim.notify(out[1] or 'no blame')
end

map('n', '<leader>e', '<cmd>Lexplore!<CR>', { desc = 'Toggle File Explorer' })
map('n', '<leader>ff', pick_files, { desc = 'Find Files' })
map('n', '<leader>fg', pick_grep, { desc = 'Live Grep' })
map('n', '<leader>fc', function() pick_grep(vim.fn.expand('<cword>')) end, { desc = 'Grep Word Under Cursor' })
map('n', '<leader>fb', pick_buffers, { desc = 'Find Buffers' })
map('n', '<leader>fr', pick_recent, { desc = 'Recent Files' })
map('n', '<leader>fh', ':help ', { desc = 'Help Tags' })

map('n', '<leader>gg', function() term({ 'lazygit' }) end, { desc = 'Lazygit' })
map('n', '<leader>gb', blame_line, { desc = 'Git Blame Line' })
-- silent!: plain wall aborts with E141 when an unnamed buffer is modified
map('n', '<leader>S', function() vim.cmd('silent! wall') term({ 'scooter' }) end, { desc = 'Scooter Search/Replace' })
map('n', '<leader>M', function() term({ 'glow', '-s', 'dark', '-p', vim.fn.expand('%:p') }) end, { desc = 'Markdown Preview (glow)' })

map('n', '<leader>fm', 'mzgg=G`z', { desc = 'Format Buffer (Indent)' })
map('v', '<leader>fm', '=', { desc = 'Format Selection (Indent)' })
map('n', '<leader>u', '<cmd>packadd nvim.undotree | Undotree<CR>', { desc = 'Undo Tree' })

for key, side in pairs({ h = 'left', j = 'bottom', k = 'top', l = 'right' }) do
  map('n', '<C-' .. key .. '>', '<C-w>' .. key, { desc = 'Move to ' .. side .. ' window' })
end
for key, cmd in pairs({ Up = 'resize +2', Down = 'resize -2', Left = 'vertical resize -2', Right = 'vertical resize +2' }) do
  map('n', '<C-' .. key .. '>', '<cmd>' .. cmd .. '<CR>', { desc = 'Window: ' .. cmd })
end

map('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up and center' })
map('n', 'n', 'nzzzv', { desc = 'Next search result and center' })
map('n', 'N', 'Nzzzv', { desc = 'Previous search result and center' })
map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlighting' })
-- remap: % is itself a matchit mapping (if/endif, tags)
map({ 'n', 'x', 'o' }, 'mm', '%', { remap = true, desc = 'Jump to matching bracket' })

map('n', '<A-j>', '<cmd>m .+1<CR>==', { desc = 'Move line down' })
map('n', '<A-k>', '<cmd>m .-2<CR>==', { desc = 'Move line up' })
map('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move text down' })
map('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move text up' })
map('v', '<', '<gv', { desc = 'Indent left and reselect' })
map('v', '>', '>gv', { desc = 'Indent right and reselect' })

map('i', '<Tab>', function()
  if vim.fn.pumvisible() == 1 then
    return vim.fn.complete_info({ 'selected' }).selected ~= -1 and '<C-y>' or '<C-n>'
  end
  return '<Tab>'
end, { expr = true, desc = 'Accept or select next completion' })

map('i', '<S-Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>'
end, { expr = true, desc = 'Select previous completion' })
