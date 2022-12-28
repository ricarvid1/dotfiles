" Linters to be used
let b:ale_linters = {'python': ['flake8']}
" Fix files with prettier, and then ESLint.
let b:ale_fixers = {'python': ['autoflake', 'black', 'isort']}
