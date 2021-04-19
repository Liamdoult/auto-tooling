call plug#begin('~/AppData/Local/nvim/plugged')
Plug 'joshdick/onedark.vim'
Plug 'iCyMind/NeoSolarized'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'preservim/nerdtree'
Plug 'https://github.com/ctrlpvim/ctrlp.vim'
Plug 'https://github.com/mileszs/ack.vim'

Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }

Plug 'neovim/nvim-lsp'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/completion-nvim'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'omnisharp/omnisharp-vim'
call plug#end()

syntax on
colorscheme onedark

let g:airline_solarized_bg='dark'

let mapleader = " "

" Movement
nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>

" Nerd Tree Configuration
nnoremap <C-n> :NERDTreeToggle<CR>

" Ctrl + p Configuration
let g:ctrlp_map = '<leader>p'

" RipGrep search Configuration
nnoremap <leader>rg :Ack 
" if executable('rg')
"   let g:ackprg = 'rg --vimgrep'
" endif
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

" Other
set ts=2 sw=2

set number
" highlight ColorColumn ctermbg=red
" set cc=80
nnoremap <Leader><CR> :so C:\Users\Liamd\AppData\Local\nvim\init.vim<CR>
nnoremap <Leader>ec :edit C:\Users\Liamd\AppData\Local\nvim\init.vim<CR>

let g:OmniSharp_server_use_mono = 1
let g:OmniSharp_server_stdio = 1

set completeopt=menuone,noinsert,noselect
let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']
lua require'lspconfig'.pyls.setup{ on_attach=require'completion'.on_attach }
lua require'lspconfig'.tsserver.setup{ on_attach=require'completion'.on_attach }
lua require'lspconfig'.gopls.setup{ on_attach=require'completion'.on_attach }
lua require'lspconfig'.omnisharp.setup{ on_attach=require'completion'.on_attach }
