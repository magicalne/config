" Fish doesn't play all that well with others
set shell=/bin/bash
let mapleader = "\<Space>"

" =============================================================================
" # PLUGINS
" =============================================================================
" Load vundle
set nocompatible
set clipboard+=unnamedplus
set cursorline
filetype off
"set rtp+=~/dev/others/base16/templates/vim/
call plug#begin()

" Load plugins
" VIM enhancements
Plug 'ciaranm/securemodelines'
Plug 'editorconfig/editorconfig-vim'
Plug 'justinmk/vim-sneak'
Plug 'windwp/nvim-autopairs'
Plug 'windwp/nvim-ts-autotag'
Plug 'terryma/vim-expand-region'
Plug 'folke/todo-comments.nvim'

" GUI enhancements
Plug 'itchyny/lightline.vim'
Plug 'machakann/vim-highlightedyank'
Plug 'andymass/vim-matchup'
Plug 'kyazdani42/nvim-web-devicons' " optional, for file icons
Plug 'kyazdani42/nvim-tree.lua'
Plug 'akinsho/bufferline.nvim', { 'commit': '73540cb' }
Plug 'ThePrimeagen/harpoon', { 'branch': 'harpoon2' }
Plug 'lukas-reineke/indent-blankline.nvim'

" Fuzzy finder
" Plug 'airblade/vim-rooter'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
Plug 'nvim-lua/plenary.nvim'

" Semantic language support
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/lsp_extensions.nvim'
Plug 'hrsh7th/cmp-nvim-lsp', {'branch': 'main'}
Plug 'hrsh7th/cmp-buffer', {'branch': 'main'}
Plug 'hrsh7th/cmp-path', {'branch': 'main'}
Plug 'hrsh7th/nvim-cmp', {'branch': 'main'}
Plug 'ray-x/lsp_signature.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Only because nvim-cmp _requires_ snippets
Plug 'hrsh7th/cmp-vsnip', {'branch': 'main'}
Plug 'hrsh7th/vim-vsnip'

" Syntactic language support
Plug 'cespare/vim-toml', {'branch': 'main'}
Plug 'stephpy/vim-yaml'
Plug 'rust-lang/rust.vim'
Plug 'rhysd/vim-clang-format'
"Plug 'fatih/vim-go'
Plug 'dag/vim-fish'
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'

" git
Plug 'f-person/git-blame.nvim'

" Theme
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
Plug 'Yazeed1s/oh-lucy.nvim'
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }

" Plug '/home/magicalne/ssd/git/opensource/fim.nvim'
Plug '/home/magicalne/workspace/opensource/fim.nvim'
call plug#end()

if has('nvim')
    set guicursor=n-v-c:block-Cursor/lCursor-blinkon0,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor
    set inccommand=nosplit
    noremap <C-q> :confirm qall<CR>
end

" deal with colors
if !has('gui_running')
  set t_Co=256
endif
if (match($TERM, "-256color") != -1) && (match($TERM, "screen-256color") == -1)
  " screen does not (yet) support truecolor
  set termguicolors
endif
"set background=dark
let base16colorspace=256
"let g:base16_shell_path="~/dev/others/base16/templates/shell/scripts/"
"colorscheme base16-gruvbox-dark-hard
syntax on
hi Normal ctermbg=NONE

" Customize the highlight a bit.
" Make comments more prominent -- they are important.
"call Base16hi("Comment", g:base16_gui09, "", g:base16_cterm09, "", "", "")
" Make it clearly visible which argument we're at.
"call Base16hi("LspSignatureActiveParameter", g:base16_gui05, g:base16_gui03, g:base16_cterm05, g:base16_cterm03, "bold", "")
" Would be nice to customize the highlighting of warnings and the like to make
" them less glaring. But alas
" https://github.com/nvim-lua/lsp_extensions.nvim/issues/21
" call Base16hi("CocHintSign", g:base16_gui03, "", g:base16_cterm03, "", "", "")

" LSP configuration
lua << END

-- Setup theme
-- vim.g.tokyonight_style = "night" -- storm or day
-- vim.g.tokyonight_italic_functions = true
-- vim.g.tokyonight_sidebars = { "qf", "vista_kind", "terminal", "packer" }

-- Change the "hint" color to the "orange" color, and make the "error" color bright red
-- vim.g.tokyonight_colors = { hint = "orange", error = "#f00056" }

-- Load the colorscheme
-- vim.cmd[[colorscheme tokyonight-night]]
-- vim.cmd[[colorscheme tokyonight-storm]]
-- vim.cmd[[colorscheme tokyonight-storm]]
-- vim.cmd[[colorscheme tokyonight-day]]

-- vim.cmd[[colorscheme oh-lucy]] -- for oh-lucy

-- vim.cmd.colorscheme "catppuccin-latte"
-- vim.cmd.colorscheme "catppuccin-frappe"
-- vim.cmd.colorscheme "catppuccin-macchiato"
vim.cmd.colorscheme "catppuccin"

-- Setup auto-pair
require("nvim-autopairs").setup {
    -- M-e to trigger fast wrap
    fast_wrap = {
      map = '<M-e>',
      chars = { '{', '[', '(', '"', "'", "`" },
      pattern = [=[[%'%"%>%]%)%}%,]]=],
      end_key = '$',
      before_key = 'h',
      after_key = 'l',
      cursor_pos_before = true,
      keys = 'qwertyuiopzxcvbnmasdfghjkl',
      manual_position = true,
      highlight = 'Search',
      highlight_grey='Comment'
    },
}

-- Setup nvim file icons

local function open_nvim_tree(data)

  -- buffer is a real file on the disk
  local real_file = vim.fn.filereadable(data.file) == 1

  -- buffer is a [No Name]
  local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

  if not real_file and not no_name then
    return
  end

end
require("nvim-web-devicons").setup{ default = true }

-- Setup nvim tree
-- open the tree, find the file but don't focus it
vim.api.nvim_create_autocmd("BufEnter", {
  nested = true,
  callback = function()
    local api = require('nvim-tree.api')

    -- Only 1 window with nvim-tree left: we probably closed a file buffer
    if #vim.api.nvim_list_wins() == 1 and api.tree.is_tree_buf() then
      -- Required to let the close event complete. An error is thrown without this.
      vim.defer_fn(function()
        -- close nvim-tree: will go to the last hidden buffer used before closing
        api.tree.toggle({find_file = true, focus = true})
        -- re-open nivm-tree
        api.tree.toggle({find_file = true, focus = true})
        -- nvim-tree is still the active window. Go to the previous window.
        vim.cmd("wincmd p")
      end, 0)
    end
  end
})
local function on_attach(bufnr)
  local api = require('nvim-tree.api')

  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  api.config.mappings.default_on_attach(bufnr)
  local function edit_or_open()
    local node = api.tree.get_node_under_cursor()
  
    if node.nodes ~= nil then
      -- expand or collapse folder
      api.node.open.edit()
    else
      -- open file
      api.node.open.edit()
      -- Close the tree if file was opened
      api.tree.close()
    end
  end
  -- open as vsplit on current node
  local function vsplit_preview()
    api.node.open.edit()
    -- Finally refocus on tree if it was lost
    api.tree.focus()
  end

  vim.keymap.set("n", "l", edit_or_open,          opts("Edit Or Open"))
  vim.keymap.set("n", "L", vsplit_preview,        opts("Vsplit Preview"))
  vim.keymap.set("n", "h", api.tree.close,        opts("Close"))
  vim.keymap.set("n", "H", api.tree.collapse_all, opts("Collapse All"))
  vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
  vim.keymap.set('n', 'C', api.tree.change_root_to_node, opts('CD'))
  vim.keymap.set('n', 'P', function()
    local node = api.tree.get_node_under_cursor()
    print(node.absolute_path)
  end, opts('Print Node Path'))

  vim.keymap.set('n', 'Z', api.node.run.system, opts('Run System'))

  vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
end
require("nvim-tree").setup({
  on_attach = on_attach,
  sort_by = "case_sensitive",
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
  },
  update_focused_file = {
    enable = true,
  },
  git = {
    enable = true,
    ignore = false,
    timeout = 500,
  }
})

vim.opt.termguicolors = true
-- Setup bufferline
require("bufferline").setup {
    options = {
        mode = "buffers",
        -- numbers = "buffer_id",
        indicator = {
            icon = '| ',
            style = 'underline',
        },
        buffer_close_icon = '',
        modified_icon = '●',
        close_icon = '',
        left_trunc_marker = '',
        right_trunc_marker = '',
        diagnostics = "nvim_lsp",
        color_icons = true,
        show_buffer_icons = true, -- disable filetype icons for buffers
        show_buffer_close_icons = false,
        show_close_icon = false,
        numbers = function(number_opts)
            local harpoon = require("harpoon.mark")
	    local buf_name = vim.api.nvim_buf_get_name(number_opts.id)
	    local harpoon_mark = harpoon.get_index_of(buf_name)
	    return harpoon_mark
	end,
        --sort_by = 'insert_after_current' -- |'insert_at_end' | 'id' | 'extension' | 'relative_directory' | 'directory' | 'tabs' | function(buffer_a, buffer_b)
    },
}
local harpoon = require("harpoon")

-- REQUIRED
harpoon:setup()
-- REQUIRED

vim.keymap.set("n", "<leader>qq", function() harpoon:list():add() end)
vim.keymap.set("n", "<space>e", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<space>1", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<space>2", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<space>3", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<space>4", function() harpoon:list():select(4) end)
vim.keymap.set("n", "<space>5", function() harpoon:list():select(5) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<space>p", function() harpoon:list():prev() end)
vim.keymap.set("n", "<space>n", function() harpoon:list():next() end)

local cmp = require'cmp'

local lspconfig = require'lspconfig'
cmp.setup({
  snippet = {
    -- REQUIRED by nvim-cmp. get rid of it once we can
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
      -- Tab immediately completes. C-n/C-p to select.
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-k>'] = cmp.mapping.select_prev_item(),
      ['<C-j>'] = cmp.mapping.select_next_item(),
      ['<C-x>'] = cmp.mapping(
          cmp.mapping.complete({
            config = {
              sources = cmp.config.sources({
                { name = 'fim' },
              }),
            },
          }),
          { 'i' }
    ),
  },
  sources = cmp.config.sources({
    -- TODO: currently snippets from lsp end up getting prioritized -- stop that!
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    -- { name = 'fim'},
  }, {
    { name = 'path' },
  }),
  experimental = {
    ghost_text = true,
  },
})

-- Enable completing paths in :
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  })
})

local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local handlers = require('nvim-autopairs.completion.handlers')
cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done({
    filetypes = {
      -- "*" is a alias to all filetypes
      ["*"] = {
        ["("] = {
          kind = {
            cmp.lsp.CompletionItemKind.Function,
            cmp.lsp.CompletionItemKind.Method,
          },
          handler = handlers["*"]
        }
      }
    }
  })
)


-- Setup lspconfig.
local builtin = require('telescope.builtin')
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  --Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>a', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap("n", "gr", "<cmd>lua require('telescope.builtin').lsp_references()<CR>", opts)
  buf_set_keymap('n', '<space>E', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.format()<CR>", opts)
  buf_set_keymap("n", "<space>l", "<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>", opts)
  -- Get signatures (and _only_ signatures) when in argument lists.
  require "lsp_signature".on_attach({
    hint_enable = true,
    doc_lines = 0,
    handler_opts = {
      border = "none"
    },
  })
end

-- Inlay hint
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true)
        end
        -- whatever other lsp config you want
    end
})

-- Auto close quickfix buffer opened by lspconfig.
local autocmd = vim.api.nvim_create_autocmd
autocmd({ "BufLeave" }, { pattern = { "*" }, command = "if &buftype == 'quickfix'|q|endif" })

local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
lspconfig.rust_analyzer.setup {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = {
          command = "clippy"
      },
      cargo = {
        features = "all",
	loadOutDirsFromCheck = true,
      },
      -- procMacro = { enable = true, },
      completion = { postfix = { enable = true, }, },
    },
  },
  capabilities = capabilities,
}
lspconfig.clangd.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}
lspconfig.gopls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}
require'lspconfig'.tsserver.setup{
  on_attach = on_attach,
  capabilities = capabilities,
}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    update_in_insert = true,
  }
)
-- pyright
local util = require('lspconfig/util')
local path = util.path

local function get_python_path(workspace)
  -- Use activated virtualenv.
  if vim.env.VIRTUAL_ENV then
    return path.join(vim.env.VIRTUAL_ENV, 'bin', 'python')
  end

  -- Find and use virtualenv from pipenv in workspace directory.
  local match = vim.fn.glob(path.join(workspace, 'Pipfile'))
  if match ~= '' then
    local venv = vim.fn.trim(vim.fn.system('PIPENV_PIPFILE=' .. match .. ' pipenv --venv'))
    return path.join(venv, 'bin', 'python')
  end

  -- Fallback to system Python.
  return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
end

lspconfig.pyright.setup{
  capabilities = capabilities,
--  on_attach = function(client)
--      client.server_capabilities.completionProvider = false
--  end,
  on_attach = on_attach,
  -- on_attach = function()
  --     require'lsp_signature'.on_attach {
  --         hint_enable = false,
  --     }
  -- end,
  on_init = function(client)
      client.config.settings.python.pythonPath = get_python_path(client.config.root_dir)
  end
}

-- ruff
require('lspconfig').ruff_lsp.setup {
  capabilities = capabilities,
  on_attach = on_attach,
  init_options = {
    settings = {
      -- Any extra CLI arguments for `ruff` go here.
      args = {},
    }
  }
}

-- treesitter
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = { "c", "lua", "rust", "python", "typescript", "solidity" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  auto_install = true,

  -- List of parsers to ignore installing (for "all")
  --ignore_install = { "javascript" },

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    disable = { },

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  -- nvim-ts-autotag
  autotag = { enable = true, }
}

local fim = require('fim.config')
fim:setup({
  max_lines = 100,
  provider = 'Ollama',
  provider_options = {
    model = 'starcoder2:7b',
    -- model = 'llama3.1',
  },
  notify = true,
  notify_callback = function(msg)
    vim.notify(msg)
  end,
  run_on_every_keystroke = false,
  ignored_file_types = {
    -- default is not to ignore
    -- uncomment to ignore in lua:
    -- lua = true
  },
})
-- indent-blankline
vim.opt.list = true
-- vim.opt.listchars:append "space:⋅"
vim.opt.listchars:append "eol:↴"
require("ibl").setup {}

local actions = require "telescope.actions"
require('telescope').setup {
    mappings = {
        i = {
            --["<C-j>"] = actions.move_selection_next,
            --["<C-k>"] = actions.move_selection_previous,
        },
    }
}

-- todo-comments
require('todo-comments').setup {}

vim.keymap.set("n", "]t", function()
  require("todo-comments").jump_next()
end, { desc = "Next todo comment" })

vim.keymap.set("n", "[t", function()
  require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })

END

" Plugin settings
let g:secure_modelines_allowed_items = [
                \ "textwidth",   "tw",
                \ "softtabstop", "sts",
                \ "tabstop",     "ts",
                \ "shiftwidth",  "sw",
                \ "expandtab",   "et",   "noexpandtab", "noet",
                \ "filetype",    "ft",
                \ "foldmethod",  "fdm",
                \ "readonly",    "ro",   "noreadonly", "noro",
                \ "rightleft",   "rl",   "norightleft", "norl",
                \ "colorcolumn"
                \ ]

" Lightline
let g:lightline = {
      \ 'colorscheme': 'catppuccin',
      \ 'enable': {
          \ 'tabline': 0,
      \ },
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'filename', 'modified' ] ],
      \   'right': [ [ 'lineinfo' ],
      \              [ 'percent' ],
      \              [ 'fileencoding', 'filetype' ] ],
      \ },
      \ 'component_function': {
      \   'filename': 'LightlineFilename'
      \ },
      \ }
function! LightlineFilename()
  return expand('%:t') !=# '' ? @% : '[No Name]'
endfunction

" from http://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
if executable('ag')
	set grepprg=ag\ --nogroup\ --nocolor
endif
if executable('rg')
	set grepprg=rg\ --no-heading\ --vimgrep
	set grepformat=%f:%l:%c:%m
endif

" Javascript
let javaScript_fold=0

" Java
let java_ignore_javadoc=1

" Latex
let g:latex_indent_enabled = 1
let g:latex_fold_envs = 0
let g:latex_fold_sections = []

" Open hotkeys
map <C-p> :Files<CR>

" Quick-save
nmap <leader>w :w<CR>

" Don't confirm .lvimrc
let g:localvimrc_ask = 0

" rust
let g:rustfmt_autosave = 1
let g:rustfmt_emit_files = 1
let g:rustfmt_fail_silently = 0
let g:rust_clip_command = 'xclip -selection clipboard'

" Completion
" Better completion
" menuone: popup even when there's only one match
" noinsert: Do not insert text until a selection is made
" noselect: Do not select, force user to select one from the menu
set completeopt=menuone,noinsert,noselect
" Better display for messages
set cmdheight=2
" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" Golang
let g:go_play_open_browser = 0
let g:go_fmt_fail_silently = 1
let g:go_fmt_command = "goimports"
let g:go_bin_path = expand("~/go/bin")

" =============================================================================
" # Editor settings
" =============================================================================
filetype plugin indent on
set autoindent
set timeoutlen=300 " http://stackoverflow.com/questions/2158516/delay-before-o-opens-a-new-line
set encoding=utf-8
set scrolloff=2
set noshowmode
set hidden
set nowrap
set nojoinspaces
let g:sneak#s_next = 1
let g:vim_markdown_new_list_item_indent = 0
let g:vim_markdown_auto_insert_bullets = 0
let g:vim_markdown_frontmatter = 1
"set printfont=:h10
"set printencoding=utf-8
"set printoptions=paper:letter
" Always draw sign column. Prevent buffer moving when adding/deleting sign.
set signcolumn=yes

" Settings needed for .lvimrc
set exrc
set secure

" Sane splits
set splitright
set splitbelow

" Permanent undo
set undodir=~/.vimdid
set undofile

" Decent wildmenu
set wildmenu
set wildmode=list:longest
set wildignore=.hg,.svn,*~,*.png,*.jpg,*.gif,*.settings,Thumbs.db,*.min.js,*.swp,publish/*,intermediate/*,*.o,*.hi,Zend,vendor

" Use wide tabs
set softtabstop=4
set tabstop=8     " tabs are at proper location
set expandtab     " don't use actual tab character (ctrl-v)
set shiftwidth=4  " indenting is 4 spaces
set autoindent    " turns it on
" set smartindent   " does the right thing (mostly) in programs
" set cindent       " stricter rules for C programs
"
autocmd Filetype javascript setlocal ts=2 sw=2 sts=0 expandtab
autocmd Filetype typescript setlocal ts=2 sw=2 sts=0 expandtab
autocmd Filetype vue setlocal ts=2 sw=2 sts=0 expandtab

" Wrapping options
set formatoptions=tc " wrap text and comments using textwidth
set formatoptions+=r " continue comments when pressing ENTER in I mode
set formatoptions+=q " enable formatting of comments with gq
set formatoptions+=n " detect lists for formatting
set formatoptions+=b " auto-wrap in insert mode, and do not wrap old long lines
set wrap
" Proper search
set incsearch
set ignorecase
set smartcase
set gdefault

" Search results centered please
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz

" Very magic by default
nnoremap ? ?\v
nnoremap / /\v
cnoremap %s/ %sm/

" =============================================================================
" # GUI settings
" =============================================================================
set guioptions-=T " Remove toolbar
set vb t_vb= " No more beeps
set backspace=2 " Backspace over newlines
set nofoldenable
set ttyfast
" https://github.com/vim/vim/issues/1735#issuecomment-383353563
set lazyredraw
set synmaxcol=500
set laststatus=2
set relativenumber " Relative line numbers
set number " Also show current absolute line
set diffopt+=iwhite " No whitespace in vimdiff
" Make diffing better: https://vimways.org/2018/the-power-of-diff/
set diffopt+=algorithm:patience
set diffopt+=indent-heuristic
set colorcolumn=120 " and give me a colored column
set showcmd " Show (partial) command in status line.
set mouse=a " Enable mouse usage (all modes) in terminals
set shortmess+=c " don't give |ins-completion-menu| messages.

" Show those damn hidden characters
" Verbose: set listchars=nbsp:¬,eol:¶,extends:»,precedes:«,trail:•
" set listchars=nbsp:¬,extends:»,precedes:«,trail:•

" =============================================================================
" # Keyboard shortcuts
" =============================================================================
" ; as :
" nnoremap ; :

" Ctrl+j and Ctrl+k as Esc
" Ctrl-j is a little awkward unfortunately:
" https://github.com/neovim/neovim/issues/5916
" So we also map Ctrl+k
" nnoremap <C-j> <Esc>
" inoremap <C-j> <Esc>
" vnoremap <C-j> <Esc>
" snoremap <C-j> <Esc>
" xnoremap <C-j> <Esc>
" cnoremap <C-j> <C-c>
" onoremap <C-j> <Esc>
" lnoremap <C-j> <Esc>
" tnoremap <C-j> <Esc>
" 
" nnoremap <C-k> <Esc>
" inoremap <C-k> <Esc>
" vnoremap <C-k> <Esc>
" snoremap <C-k> <Esc>
" xnoremap <C-k> <Esc>
" cnoremap <C-k> <C-c>
" onoremap <C-k> <Esc>
" lnoremap <C-k> <Esc>
" tnoremap <C-k> <Esc>

" Ctrl+h to stop searching
vnoremap <C-h> :nohlsearch<cr>
nnoremap <C-h> :nohlsearch<cr>

" Suspend with Super+f
"inoremap <S-f> :sus<cr>
"vnoremap <S-f> :sus<cr>
"nnoremap <S-f> :sus<cr>

" Jump to start and end of line using the home row keys
map H ^
map L $

" Neat X clipboard integration
map <Leader>y "*y
map <Leader>p "*p

" <leader>s for Rg search
noremap <leader>s :Rg
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } } 
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg -i --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

function! s:list_cmd()
  let base = fnamemodify(expand('%'), ':h:.:S')
  return base == '.' ? 'fd --type file --follow' : printf('fd --type file --follow | proximity-sort %s', shellescape(expand('%')))
endfunction

command! -bang -nargs=? -complete=dir GFiles
  \ call fzf#vim#files(<q-args>, {'source': s:list_cmd(),
  \                               'options': ['--tiebreak=index', '--info=inline', '--preview', 'cat {}']}, <bang>0)


" map dictionary
inoremap <expr> <c-x><c-k> fzf#vim#complete('cat /usr/share/dict/words')
" Open new file adjacent to current file
nnoremap <leader>o :e <C-R>=expand("%:p:h") . "/" <CR>

" List open buffers
nnoremap <leader>b :Buffers <CR>
" List history buffers
nnoremap <leader>h :History <CR>
" Close buffer to left
nnoremap <leader>ch :BufferLineCloseLeft <CR>
" Close buffer to right
nnoremap <leader>cl :BufferLineCloseRight <CR>
" No arrow keys --- force yourself to use the home row
nnoremap <up> <nop>
nnoremap <down> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

" Left and right can switch buffers
nnoremap <left> :bp<CR>
nnoremap <right> :bn<CR>
nnoremap <S-tab> :bp<CR>
nnoremap <tab> :bn<CR>

" Move by line
nnoremap j gj
nnoremap k gk

" <leader><leader> toggles between buffers
nnoremap <leader><leader> <c-^>

" <leader>, shows/hides hidden characters
nnoremap <leader>, :set invlist<cr>

" <leader>q shows stats
nnoremap <leader>q g<c-g>

" Keymap for replacing up to next _ or -
noremap <leader>m ct_

" I can type :help on my own, thanks.
map <F1> <Esc>
imap <F1> <Esc>

" nvim-tree shortcuts
nnoremap <leader>t :NvimTreeToggle <CR>

" visual
vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left>

" region expand
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)

" Use the "black hole register", "_ to really delete something: "_d.
" Use "_dP to paste something and keep it available for further pasting.
nnoremap <leader>d "_d
xnoremap <leader>d "_d
xnoremap <leader>p "_dP

" Context of the current line.
nnoremap <leader>cc :echo nvim_treesitter#statusline(#{seperator: '->', indicator_size: 90}) <CR>
" =============================================================================
" # Autocommands
" =============================================================================

" Prevent accidental writes to buffers that shouldn't be edited
autocmd BufRead *.orig set readonly
autocmd BufRead *.pacnew set readonly

" Leave paste mode when leaving insert mode
autocmd InsertLeave * set nopaste

" Jump to last edit position on opening file
if has("autocmd")
  " https://stackoverflow.com/questions/31449496/vim-ignore-specifc-file-in-autocommand
  au BufReadPost * if expand('%:p') !~# '\m/\.git/' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Follow Rust code style rules
au Filetype rust source ~/.config/nvim/scripts/spacetab.vim
au Filetype rust set colorcolumn=120

" C code style
au Filetype cpp setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab
au Filetype c setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab

" Help filetype detection
autocmd BufRead *.plot set filetype=gnuplot
autocmd BufRead *.md set filetype=markdown
autocmd BufRead *.lds set filetype=ld
autocmd BufRead *.tex set filetype=tex
autocmd BufRead *.trm set filetype=c
autocmd BufRead *.xlsx.axlsx set filetype=ruby

" Script plugins
autocmd Filetype html,xml,xsl,php source ~/.config/nvim/scripts/closetag.vim

" =============================================================================
" # Footer
" =============================================================================

" nvim
if has('nvim')
	runtime! plugin/python_setup.vim
endif
