syntax on
set ic is nu rnu expandtab wildmode=longest,list,full splitbelow splitright autoindent shiftwidth=4 tabstop=4 encoding=utf8
autocmd BufWritePre * %s/\s\+$//e

noremap j n
noremap J N
noremap n j
noremap N J
noremap k t
noremap K T
noremap t k
noremap T K
noremap l s
noremap L S
noremap s l
noremap S L

inoremap <Tab> <Space><Space><Space><Space>
inoremap <S-Tab> <Tab>
