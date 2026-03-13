if has('nvim')
lua <<EOF
require'alpha'.setup(require'alpha.themes.dashboard'.config)
require('session_manager').setup({autoload_mode = require('session_manager.config').AutoloadMode.Disabled})
require'nvim-web-devicons'.get_icons()
require('supermaven-nvim').setup({})
EOF
nnoremap <silent> <A-,> <Cmd>BufferPrevious<CR>
nnoremap <silent> <A-.> <Cmd>BufferNext<CR>
nnoremap <silent> <A-1> <Cmd>BufferGoto 1<CR>
nnoremap <silent> <A-2> <Cmd>BufferGoto 2<CR>
nnoremap <silent> <A-3> <Cmd>BufferGoto 3<CR>
nnoremap <silent> <A-4> <Cmd>BufferGoto 4<CR>
nnoremap <silent> <A-5> <Cmd>BufferGoto 5<CR>
nnoremap <silent> <A-6> <Cmd>BufferGoto 6<CR>
nnoremap <silent> <A-7> <Cmd>BufferGoto 7<CR>
nnoremap <silent> <A-8> <Cmd>BufferGoto 8<CR>
nnoremap <silent> <A-9> <Cmd>BufferGoto 9<CR>
nnoremap <silent> <A-0> <Cmd>BufferLast<CR>
endif
" colors
" let g:equinusocio_material_style = 'darker'
" let g:equinusocio_material_hide_vertsplit = 1
" colorscheme equinusocio_material
colorscheme srcery
"hi Normal guibg=NONE ctermbg=NONE
let g:rainbow_active = 1

" omnifuncs
augroup omnifuncs
  au!
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=python3complete#Complete
augroup end

" completions
set completeopt=menuone,noselect
let b:vcm_tab_complete = 'omni'
set omnifunc=syntaxcomplete#Complete
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" treesitter
if has('nvim')
lua <<EOF
require'nvim-treesitter.configs'.setup {
    ensure_installed = {
        "bash",
        "c",
        "cpp",
        "css",
        "dockerfile",
        "go",
        "gomod",
        "html",
        "javascript",
        "json",
        "lua",
        "python",
        "rust",
        "ruby",
        "toml",
        "yaml",
    },
    highlight = {
        enable = true,
    },
    indent = {
        enable = true,
        disable = {"python"}
    },
    incremental_selection = {
        enable = true,
    },
}
require'nvim-treesitter.install'.compilers = { "gcc" }
require'lspconfig'.terraformls.setup{}
EOF
autocmd BufWritePre *tfvars lua vim.lsp.buf.format()
autocmd BufWritePre *.tf lua vim.lsp.buf.format()
endif

" nvim-cmp
if has('nvim')
lua <<EOF
local cmp = require('cmp')
cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif vim.fn['vsnip#available'](1) == 1 then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Plug>(vsnip-expand-or-jump)', true, true, true), '', true)
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif vim.fn['vsnip#jumpable'](-1) == 1 then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Plug>(vsnip-jump-prev)', true, true, true), '', true)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),
})
EOF
endif

" dashboard
let g:mapleader="\<Space>"
let g:dashboard_default_executive ='telescope'
nnoremap <Leader>ss :<C-u>SessionManager save_current_session<CR>
nnoremap <silent> <Leader>sl :<C-u>SessionManager load_last_session<CR>
nnoremap <silent> <Leader>ff :Telescope find_files<CR>
nnoremap <silent> <Leader>fh :Telescope oldfiles<CR>
nnoremap <silent> <Leader>fr :Telescope frecency<CR>
nnoremap <silent> <Leader>fg :Rg<CR>
nnoremap <silent> <Leader>fm :Marks<CR>

" signify diff
let g:signify_realtime = 1
let g:signify_skip = {'vcs': { 'allow': ['git'] }}

" indent lines
let g:indentLine_char = '│'
let g:indentLine_first_char = '│'
let g:indentLine_showFirstIndentLevel = 1
let g:indentLine_fileTypeExclude = ['dashboard']
let g:indent_blankline_use_treesitter = 1
let g:indent_blankline_show_current_context = 1
let g:indent_blankline_show_end_of_line = 1
let g:indent_blankline_char = '│'

" linting
let g:ale_sign_column_always = 1
let g:ale_sign_error = ' '
let g:ale_sign_warning = ' '
let g:ale_fixers = {
  \ 'python': ['black'],
  \ 'go': ['gofmt'],
  \ }
let g:ale_fix_on_save = 1
let g:ale_linters = {
  \'clojure': ['clj-kondo']
  \ }

" limit modelines
set nomodeline
let g:secure_modelines_verbose = 0
let g:secure_modelines_modelines = 15

" lightline http://git.io/lightline
let g:lightline = {
  \ 'colorscheme': 'srcery',
  \ 'active': {
  \   'left': [ [ 'mode', 'paste' ],
  \             [ 'fugitive', 'readonly', 'filename', 'modified' ]
  \           ],
  \   'right': [
  \     ['ale'],
  \     ['lineinfo'],
  \     ['percent'],
  \     ['charcode', 'fileformat', 'filetype'],
  \   ]
  \ },
  \ 'inactive': {
  \   'left': [ [ 'fugitive', 'readonly', 'filename', 'modified' ] ]
  \ },
  \ 'component': {
  \   'filename': '%f'
  \ },
  \ 'component_function': {
  \   'fugitive': 'MyFugitive',
  \   'readonly': 'MyReadonly',
  \   'modified': 'MyModified',
  \   'ale': 'ALEGetStatusLine'
  \ },
  \ 'separator': { 'left': '', 'right': '' },
  \ 'subseparator': { 'left': '', 'right': '' }
  \ }

function! MyModified()
  if &filetype == "help"
    return ""
  elseif &modified
    return "+"
  elseif &modifiable
    return ""
  else
    return ""
  endif
endfunction

function! MyReadonly()
  if &filetype == "help"
    return ""
  elseif &readonly
    return "\u2b64"
  else
    return ""
  endif
endfunction

function! MyFugitive()
  if exists("*Fugitive#Head")
    let _ = Fugitive#Head()
    return strlen(_) ? ' '._ : ''
  endif
  return ''
endfunction

set noshowmode

augroup alestatus
  au!
  autocmd User ALELint call lightline#update()
augroup end

