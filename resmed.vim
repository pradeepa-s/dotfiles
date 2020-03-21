" Default key mapping:
"
" <leader>rtt = Run current test in win32 (BDD and unit test)
" <leader>rtl = Run last test (This runs the test you executed last)
" <leader>rtd = Run current test on device (BDD)
" <leader>rtf = Run current test file in win32 (BDD and unit test)
" <leader>rsc = Run style check
" <leader>rk  = Keep this terminal open(Plugin will not close this terminal)
"
" <leader>rot = Open test file for the current file
"
" <leader>rcc = Create new class


let g:farm_config = "/home/pradeepas/Hw.py"
let s:terminals = []

" Local functions
function! s:CloseOpenedTerminals()
    let buf_remove = []
    for term_no in s:terminals
        if bufexists(term_no) && term_getstatus(term_no) == "finished"
            call add(buf_remove, term_no)
        endif
    endfor

    for term_no in buf_remove
        execute "bdelete".term_no
        let ind = index(s:terminals, term_no)
        call remove(s:terminals, ind)
    endfor
endfunction

function! s:DetectTestType()
    " Initial classifiction is done based on filepath

    " Check where the file is located
    let this_dir = expand('%:p:h:t')

    if this_dir == "Srs"
        return "BDD"
    elseif this_dir == "SuperUnit"
        return s:DetectUnitTestType()
    else
        return "Unknown"
endfunction

function! s:DetectUnitTestType()
    let line_gt = search('SuperUnitGtest.hpp', 'bcnw')

    if line_gt != 0
        return "GUNIT"
    endif

    let line_upp = search('UnitTest++.h', 'bcnw')
    if line_upp != 0
        return "UNITTEST++"
    endif

    echoerr "Cannot determine the unit test type"
endfunction

function! s:BuildAndRunThisGUnitTestFixture()
    let line = search('^TEST', 'bcnW')
    let directory = 'Test/Unit/SuperUnit/Win32'

    let [_, fixture_name; _] = matchlist(getline(line), '^TEST_F(\(\w\+\)')

    let s:last_test = fixture_name
    let s:last_test_type = "GUNIT_FIXTURE"
    call RunTest()
endfunction

function! s:RunThisGUnitTest(dir, test_name, job, status)
    let term_no = term_start(['./Unit_NoRegion_SupersetAlert.exe', '--gtest_filter='.a:test_name.".*"], {'cwd': a:dir})
    call add(s:terminals, term_no)
endfunction

function! s:RunThisUnitTestPP()
    echoerr "Not implemented"
    return
endfunction

function! s:RunThisBddTest(platform)
    let line = search('^class \w', 'bcnW')

    if line == 0
        echoerr "Not inside a test class!"
        return
    endif

    let [_, classname; _] = matchlist(getline(line), '^class \(\w\+\)')

    if a:platform == "target"
        let s:last_test = classname
        let s:last_test_type = "BDD_TARGET_TEST"
    elseif a:platform == "win32"
        let s:last_test = classname
        let s:last_test_type = "BDD_WIN32_TEST"
    else
        echoerr "Invalid platform"
    endif

    call RunTest()
endfunction


" Global functions
function! KeepThisTerminal()
    let cur_buf = bufnr("%")
    for term_no in s:terminals
        if cur_buf == term_no
            let ind = index(s:terminals, cur_buf)
            call remove(s:terminals, ind)
        endif
    endfor
endfunction

function! RunTest()
    call s:CloseOpenedTerminals()
    let bdd_directory = 'Test/Scenarios'
    let unit_directory = 'Test/Unit/SuperUnit/Win32'

    if s:last_test_type == "BDD_WIN32_TEST"
        let term_no = term_start(['python', 'fgtest.py', '-s', s:last_test], {'cwd': bdd_directory})
        call add(s:terminals, term_no)
    elseif s:last_test_type == "BDD_TARGET_TEST"
        let term_no = term_start(['python', 'fgtest.py', '-t', '-J' , g:farm_config, '-s', s:last_test], {'cwd': bdd_directory})
        call add(s:terminals, term_no)
    elseif s:last_test_type == "GUNIT_FIXTURE"
        let term_no = term_start(['scons', '-uj8'], {'cwd': unit_directory, 'exit_cb': function("s:RunThisGUnitTest", [unit_directory, s:last_test])})
        call add(s:terminals, term_no)
    elseif s:last_test_type == "BDD_WIN32_TEST_FILE"
        let term_no = term_start(['python', 'fgtest.py', s:last_test], {'cwd': bdd_directory})
        call add(s:terminals, term_no)
    else
        echoerr "Previous test not detected"
    endif

    wincmd p
endfunction


function! RunThisTest(platform)
    let test_type = s:DetectTestType()
    call s:CloseOpenedTerminals()

    if test_type == "BDD"
        call s:RunThisBddTest(a:platform)
    elseif test_type == "GUNIT"
        call s:BuildAndRunThisGUnitTestFixture()
    elseif test_type == "UNITTEST++"
        call s:RunThisUnitTestPP()
    else
        echoerr "Unrecognized test format"
        wincmd p
    endif
endfunction


function! RunStyleCheck()
    call s:CloseOpenedTerminals()
    let s:last_test_type = "GUNIT_FIXTURE"
    let directory = 'Test/Scripts'
    let term_no = term_start(['python', 'runStyleCheck.py'], {'cwd': directory})
    call add(s:terminals, term_no)
    wincmd p
endfunction


function! RunThisTestFile()
    call s:CloseOpenedTerminals()
    let directory = 'Test/Scenarios'
    let testfile_name = expand('%:t')
    let testdir = expand('%:h:t')
    let s:last_test_type = "BDD_WIN32_TEST_FILE"
    let s:last_test = testdir."/".testfile_name
    call RunTest()
endfunction


nnoremap <leader>rtt :call RunThisTest("win32")<CR>
nnoremap <leader>rtf :call RunThisTestFile()<CR>
nnoremap <leader>rtl :call RunTest()<CR>
nnoremap <leader>rtd :call RunThisTest("target")<CR>
nnoremap <leader>rsc :call RunStyleCheck()<CR>
nnoremap <leader>rk :call KeepThisTerminal()<CR>
