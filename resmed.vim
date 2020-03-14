" Default key mapping:
"
" <leader>rtt = Run current test in win32 (BDD and unit test)
" <leader>rtd = Run current test on device (BDD)
" <leader>rtf = Run current test file in win32 (BDD and unit test)
" <leader>rsc = Run style check
"
" <leader>rot = Open test file for the current file
"
" <leader>rcc = Create new class


let g:farm_config = "~/Hw.py"

function!  RunThisBddTest(platform)
    let line = search('^class \w', 'bcnW')
    let directory = 'Test/Scenarios'

    if line == 0
        echoerr "Not inside a test class!"
        return
    endif

    let [_, classname; _] = matchlist(getline(line), '^class \(\w\+\)')

    if platform == "target"
        call term_start(['python', 'fgtest.py', '-s -t', '-J' , 'g:farm_config', 'classname'], {'cwd': directory})
    elseif platform == "win32"
        call term_start(['python', 'fgtest.py', '-s', 'classname'], {'cwd': directory})
    endif

    wincmd p
endfunction


function! DetectTestType()
    " Initial classifiction is done based on filepath

    " Check where the file is located
    let this_dir = expand('%:p:h:t')

    if this_dir == "Srs"
        return "BDD"
    elseif this_dir == "Unittest"
        return call DetectUnitTestType()
    else
        return "Unknown"

    let line = search('^class \w', 'bcnW')
endfunction


function! RunThisGUnitTest()
    echoerr "Not implemented"
    return
endfunction


function! RunThisUnitTestPP()
    echoerr "Not implemented"
    return
endfunction


function! RunThisTest(platform)
    let test_type = call DetectTestType()

    if test_type == "BDD"
        call RunThisBddTest(platform)
    elseif test_type == "GUNIT"
        call RunThisGUnitTest()
    elseif test_type == "UNITTEST++"
        call RunThisUnitTestPP()
    else
        echoerr "Unrecognized test format"
    endif
endfunction


nnoremap <leader>rtt :call RunThisTest("win32")<CR>
nnoremap <leader>rtd :call RunThisTest("target")<CR>
