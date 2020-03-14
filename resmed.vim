function! RunThisTest()
    let line = search('^class \w', 'bcnW')

    if line == 0
        echoerr "Not inside a test class!"
        return
    endif
    let [_, classname; _] = matchlist(getline(line), '^class \(\w\+\)')
    call term_start(['python', 'test_runner.py', 'classname'], {'cwd': 'test'})
    wincmd p
endfunction

nnoremap <leader>t :call RunThisTest()<CR>
