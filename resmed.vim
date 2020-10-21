"
" version: 1.1.0
" Release date: <TBD>
"
" Default key mapping:
"
" Build Related
" =============
"
" <leader>rb1 = Build win32
" <leader>rb2 = Build target
"
" Test Related
" ============
"
" <leader>rt0 = Run last test (This runs the test you executed last)
" <leader>rt1 = Run current test in win32 (BDD and unit test)
" <leader>rt2 = Run current test on device (BDD)
" <leader>rt3 = Run current test on win32 in debug mode (BDD)
" <leader>rt4 = Run current test on device in debug mode (BDD)
" <leader>rt5 = Run current test file in win32 (BDD and unit test)
" <leader>rt7 = Ask params from user befor running current test on win32(parameter will be requested from the user)
" <leader>rt8 = Ask params from user befor running current test on target(parameter will be requested from the user)
" <leader>rt9 = Run current parameterised test (parameter will be requested from the user)
" <leader>rt? = Displays available options - prompts for an input
"
" Specs
" =====
"
" <leader>rf1 = Search for the jama spec under cursor
" <leader>rf2 = Open jira ticket under cursor
"
" Flashing Related
" ================
"
" <leader>rp0 = Program the default firmware
" <leader>rp1 = Program the firmware (ask for path)
"
" Misc
" ====
"
" <leader>rsc = Run style check
" <leader>rk  = Keep this terminal open(Plugin will not close this terminal)
" <leader>rc  = Close all open terminals
"
" Wish list:
"   -
"

" Please point to the farm config file
let g:farm_config = "/home/pradeepas/Hw.py"

" Please point to the default web browser
let s:browser_path='/cygdrive/c/Program\ Files\ \(x86\)/Google/Chrome/Application/chrome.exe'

" jama specific
let s:search_url='https://jama.corp.resmed.org/perspective.req\#/search?term='
let s:project_link="&projectId=45&scope=GLOBAL"

let s:terminals = []

" Local functions
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
    let line = search('^TEST', 'bcnw')
    let directory = 'Test/Unit/SuperUnit/Win32'

    let [_, fixture_name; _] = matchlist(getline(line), '^TEST_F(\(\w\+\)')

    let s:last_test = fixture_name
    let s:last_test_type = "GUNIT_FIXTURE"
    call RunTest()
endfunction

function! s:RunThisGUnitTest(dir, test_name, job, status)
    let term_no = term_start(['./Unit_NoRegion_SupersetAlert.exe', '--gtest_filter='.a:test_name.".*"], {'cwd': a:dir})
    call add(s:terminals, term_no)
    wincmd p
endfunction

function! s:RunThisUnitTestPPTest(dir, test_name, job, status)
    let term_no = term_start(['./Unit_NoRegion_SupersetAlert.exe', a:test_name], {'cwd': a:dir})
    call add(s:terminals, term_no)
    wincmd p
endfunction

function! s:RunThisUnitTestPP()
    let line = search('^SUITE', 'bcnW')
    let directory = 'Test/Unit/SuperUnit/Win32'

    let [_, suite_name; _] = matchlist(getline(line), '^SUITE(\(\w\+\)')

    let s:last_test = suite_name
    let s:last_test_type = "UNITPP_SUITE"
    call RunTest()
endfunction

function! s:RunThisBddTest(platform, param)
    let line = search('^class \w', 'bcnW')

    if line == 0
        echoerr "Not inside a test class!"
        return
    endif

    let [_, classname; _] = matchlist(getline(line), '^class \(\w\+\)')

    if a:platform == "target"
        let s:last_test = classname."$"
        let s:last_test_type = "BDD_TARGET_TEST"
    elseif a:platform == "win32"
        let s:last_test = classname."$"
        let s:last_test_type = "BDD_WIN32_TEST"
    else
        echoerr "Invalid platform"
    endif

    if a:param == 1
        let user_param = input('Enter parameter: ')
        let s:last_test = s:last_test.":".user_param
    elseif a:param == 2
        let test_type = s:last_test_type."_DEBUG"
        let s:last_test_type = test_type
    elseif a:param == 3
        let user_param = input('Enter fgtest params: ')
        let s:last_test = s:last_test." ".user_param
    endif

    call RunTest()
endfunction


" Global functions
function! CloseOpenedTerminals()
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
    call CloseOpenedTerminals()
    let bdd_directory = 'Test/Scenarios'
    let unit_directory = 'Test/Unit/SuperUnit/Win32'

    if s:last_test_type == "BDD_WIN32_TEST"
        let term_no = term_start(['python', 'fgtest.py', '-s', s:last_test], {'cwd': bdd_directory})
        call add(s:terminals, term_no)
    elseif s:last_test_type == "BDD_TARGET_TEST"
        let term_no = term_start(['python', 'fgtest.py', '-t', '-s', s:last_test], {'cwd': bdd_directory})
        call add(s:terminals, term_no)
    elseif s:last_test_type == "BDD_WIN32_TEST_DEBUG"
        let term_no = term_start(['python', 'fgtest.py', '-d', '-s', s:last_test], {'cwd': bdd_directory})
        call add(s:terminals, term_no)
    elseif s:last_test_type == "BDD_TARGET_TEST_DEBUG"
        let term_no = term_start(['python', 'fgtest.py', '-K',  '-t', '-s', s:last_test], {'cwd': bdd_directory})
        call add(s:terminals, term_no)
    elseif s:last_test_type == "GUNIT_FIXTURE"
        let term_no = term_start(['wscons', '-uj8'], {'cwd': unit_directory, 'exit_cb': function("s:RunThisGUnitTest", [unit_directory, s:last_test])})
        call add(s:terminals, term_no)
    elseif s:last_test_type == "UNITPP_SUITE"
        let term_no = term_start(['wscons', '-uj8'], {'cwd': unit_directory, 'exit_cb': function("s:RunThisUnitTestPPTest", [unit_directory, s:last_test])})
        call add(s:terminals, term_no)
    elseif s:last_test_type == "BDD_WIN32_TEST_FILE"
        let term_no = term_start(['python', 'fgtest.py', s:last_test], {'cwd': bdd_directory})
        call add(s:terminals, term_no)
    else
        echoerr "Previous test not detected"
    endif

    echo "Running: ".s:last_test
    wincmd p
endfunction


function! RunThisTest(platform, param)
    let test_type = s:DetectTestType()
    call CloseOpenedTerminals()

    if test_type == "BDD"
        call s:RunThisBddTest(a:platform, a:param)
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
    call CloseOpenedTerminals()
    let s:last_test_type = "GUNIT_FIXTURE"
    let directory = 'Test/Scripts'
    let term_no = term_start(['python', 'runStyleCheck.py'], {'cwd': directory})
    call add(s:terminals, term_no)
    wincmd p
endfunction


function! RunThisTestFile()
    call CloseOpenedTerminals()
    let directory = 'Test/Scenarios'
    let testfile_name = expand('%:t')
    let testdir = expand('%:h:t')
    let s:last_test_type = "BDD_WIN32_TEST_FILE"
    let s:last_test = testdir."/".testfile_name
    call RunTest()
endfunction

function! FlashFirmware(config)
    call CloseOpenedTerminals()
    if a:config == "default"
        let directory = 'Test/Scenarios/Target'
    endif

    let term_no = term_start(['/cygdrive/c/Program Files (x86)/STMicroelectronics/STM32 ST-LINK Utility/ST-LINK Utility/ST-LINK_CLI.exe', '-ME', '-p', 'NoRegion_SupersetAlert_CombinedWithBootloader.srec', '-Rst'], {'cwd': directory})
    call add(s:terminals, term_no)
    wincmd p
endfunction


function! Build(platform)
    call CloseOpenedTerminals()
    if a:platform == "win32"
        let directory = 'Test/Scenarios/Win32'
    elseif a:platform == "target"
        let directory = 'Test/Scenarios/Target'
    else
        echoerr "Invalid platform"
    endif

    let term_no = term_start(['wscons', '-uj8'], {'cwd': directory})
    call add(s:terminals, term_no)
    wincmd p
endfunction


function! OpenRequirements()
    let cur_pos = getpos(".")

    " Find the start of the test
    let test_start_line = search('class', 'bcW')

    " Find the line with requirements and copy the requirements
    let line = search('REQUIREMENT', 'W')
    execute 'normal! f["ayi['
    call setpos(".", cur_pos)
    let requirements = @a
    let requirements = substitute(requirements, "\n", "", "g")
    let requirements = substitute(requirements, "'*", "", "g")
    let requirements = substitute(requirements, '"*', "", "g")
    let requirements = substitute(requirements, '\s*', "", "g")
    let req_list = split(requirements, ",")
    for req in req_list
        if req !=? 'Internal'
            " Append requirement in the URL
            execute "silent !" . s:browser_path . " " . s:search_url . req . s:project_link
        endif
    endfor
    redraw!

    echo "Opening requirements:"
    for req in req_list
        if req !=? 'Internal'
            echo req
        else
            echoerr 'Test is for internal requirement'
        endif
    endfor
endfunction

function! ResmedHelp(type)
    if a:type == "plugin"
        echo "<leader>rb? = Build"
        echo "<leader>rt? = Test"
        echo "<leader>rf? = Find"
        echo "<leader>rsc = Style check"
        echo "<leader>rk = Keep this terminal open"
        echo "<leader>rp0 = Program using st-link"
        echo "<leader>rc = Close all open terminals"
    elseif a:type == "test"
        echo "<leader>rt0 = Run last test (This runs the test you executed last)"
        echo "<leader>rt1 = Run current test in win32 (BDD and unit test)"
        echo "<leader>rt2 = Run current test on device (BDD)"
        echo "<leader>rt3 = Run current test on win32 in debug mode (BDD)"
        echo "<leader>rt4 = Run current test on device in debug mode (BDD)"
        echo "<leader>rt5 = Run current test file in win32 (BDD and unit test)"
        echo "<leader>rt7 = Ask params from user befor running current test on win32(parameter will be requested from the user)"
        echo "<leader>rt8 = Ask params from user befor running current test on target(parameter will be requested from the user)"
        echo "<leader>rt9 = Run current parameterised test (parameter will be requested from the user)"
    endif
endfunction

nnoremap <unique> <leader>r? :call ResmedHelp("plugin")<CR>
nnoremap <unique> <leader>rt? :call ResmedHelp("test")<CR>

nnoremap <unique> <leader>rb1 :call Build("win32")<CR>
nnoremap <unique> <leader>rb2 :call Build("target")<CR>

nnoremap <unique> <leader>rt0 :call RunTest()<CR>
nnoremap <unique> <leader>rt1 :call RunThisTest("win32", 0)<CR>
nnoremap <unique> <leader>rt2 :call RunThisTest("target", 0)<CR>
nnoremap <unique> <leader>rt3 :call RunThisTest("win32", 2)<CR>
nnoremap <unique> <leader>rt4 :call RunThisTest("target", 2)<CR>
nnoremap <unique> <leader>rt5 :call RunThisTestFile()<CR>
nnoremap <unique> <leader>rt7 :call RunThisTest("win32", 1)<CR>
nnoremap <unique> <leader>rt8 :call RunThisTest("target", 3)<CR>

nnoremap <unique> <leader>rf1 :call OpenRequirements()<CR>

nnoremap <unique> <leader>rsc :call RunStyleCheck()<CR>
nnoremap <unique> <leader>rk :call KeepThisTerminal()<CR>
nnoremap <unique> <leader>rp0 :call FlashFirmware("default")<CR>
nunmap <leader>rc
nnoremap <unique> <leader>rc :call CloseOpenedTerminals()<CR>
