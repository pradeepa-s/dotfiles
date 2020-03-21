" Default key mapping:
"
" <leader>rtt = Run current test in win32 (BDD and unit test)
" <leader>rtl = Run last test (This runs the test you executed last)
" <leader>rtp = Run current parameterised test on win32 (parameter will be requested from the user)
" <leader>rdp = Run current parameterised test on target
" <leader>rtd = Run current test on device (BDD)
" <leader>rtf = Run current test file in win32 (BDD and unit test)
" <leader>rbw = Build Win32
" <leader>rbt = Build Target
" <leader>rsc = Run style check
" <leader>rk  = Keep this terminal open(Plugin will not close this terminal)
" <leader>rc  = Close all open terminals
"

" Please point to the farm config file
let g:farm_config = "/home/pradeepas/Hw.py"

" Repetitive tasks
" ================
"
"      1. It's annoying that I have to copy the test name, paste it in a shell, run, check results, if
"      it fails go back edit the file do the same thing over and over again.
"      2. It's annoying that I have to leave the editor and go to the shell to build the project and
"      if there are errors come back fix them, repeat.
"      3. It's annoying that when running unit tests I need to copy the name, REMEMBER to go to unit
"      test folder, type in the unit test filter, run the test and if it fails come back, fix the
"      issue, repeat.
"
" What this script does?
" ======================
"
"     1. Runs BDD test (win32, target and parameterized)
"     2. Runs unit tests (google test and unittest++)
"     3. Builds project (win32 and target)
"     4. Runs style check
"
" How to use it?
" ==============
"
"     Following are the default key mappings: (Modify as it pleases you)
"
"         <leader>rtt = Run current test in win32 (BDD and unit test)
"         <leader>rtl = Run last test (This runs the test you executed last)
"         <leader>rtp = Run current parameterised test on win32 (parameter will be requested from the user)
"         <leader>rdp = Run current parameterised test on target
"         <leader>rtd = Run current test on device (BDD)
"         <leader>rtf = Run current test file in win32 (BDD and unit test)
"         <leader>rbw = Build Win32
"         <leader>rbt = Build Target
"         <leader>rsc = Run style check
"         <leader>rk  = Keep this terminal open(Plugin will not close this terminal)
"     <leader>rc  = Close all open terminals
"
" How to set it up?
" =================
"
"     Add the following line to your vim config.
"         source <the script path>
"     Modify the g:farm_config to point to the full path of your FarmConfig.py
"
" Limitations
" ===========
"
"     Assumes that vim working directory is fgapplication
"
" Use cases currently handled:
" ============================
"
" Use case 1:
"     You are developing a BDD test and you want to run it in Win32
"
"     You can type <leader>rtt to run that test (RTT = Resmed This Test).
"     This basically runs the test which is at or above your cursor line.
"     Script automatically identifies the test type and runs that particular test in a separate terminal (as a horizontal split).
"     At the moment, it can identify BDD, GoogleTest, UnitTest++.
"     Cursor position will not change so you can simply continue your work while test runs parallaly.
"     If you run this multiple times, it will clean up the stale windows for you.
"
" Use case 2:
"     You are developing a unit test using GTest or UnitTest++.
"
"     You can type <leader>rtt, same as BDD test.
"     Script will determine which type of test you are writing based on header files and run that
"     fixture (GTEST) or suite (UNITTEST++) which is at or above your cursor.
"     It builds the project before running the test, so you don't have to do that.
"     If you run this multiple times, it will clean up the stale windows for you.
"
" Use case 3:
"     You only need to run the 0th parameterised BDD test.
"
"     Keep the cursor in the test and type <leader>rtp to run a specific parameter (RTP = Resmed Test Parameterized)
"     Once you execute this, it will ask from the user to enter the parameter (Ex: 0, 1, ...)
"     It simply runs that same as other cases.
"
" Use case 4:
"     You found an error in one of the tests.
"     Now you are no longer editing the test steps, but you are changing some other function. A python
"     infrastructure function or some cpp file.
"
"     You can type <leader>rtl to run the last test (RTL = Resmed Test Last).
"     This runs the last executed test in a new terminal (horizontal split).
"     This will close last terminal so you wouldn't end up having stale jobs in your workspace.
"
" Use case 5:
"     You are developing a BDD test and you want to run it on target.
"
"     You can type <leader>rtd to run the the test on device (RTD = Resmed Test Device)
"
"     *** This assumes that you've built the project and runs that BDD test on target
"
" Use case 6:
"     You need to run a parameterized BDD test on target
"
"     You can type <leader>rdp to run the the test on device (RDP = Resmed Device Paramterized)
"
"     *** This assumes that you've built the project and runs that BDD test on target
"
" Use case 7:
"     You don't want to keep the last finished terminal when running the next job
"
"     Go to the terminal you want to keep and type <leader>rk (RK = Resmed Keep)
"     Next time you run a test it wouldn't kill the terminal you marked
"
" Use case 8:
"     You want to close the opened terminals (except the ones you wanted to keep)
"
"     Type <leader>rc (RC = Resmed Clear)
"     This closes the terminals the script opened for you
"
" Use case 9:
"     I want to build for win32
"
"     Type <leader>rbw (RBW = Resmed Build Win32)
"
" Use case 10:
"     I want to build for target
"
"     Type <leader>rbt (RBT = Resmed Build Targe)
"
" Future
" ======
"
" <leader>rcc = Create CPP class and test files
" <leader>rot = Open unit test file for current class




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
        let term_no = term_start(['python', 'fgtest.py', '-t', '-J' , g:farm_config, '-s', s:last_test], {'cwd': bdd_directory})
        call add(s:terminals, term_no)
    elseif s:last_test_type == "GUNIT_FIXTURE"
        let term_no = term_start(['scons', '-uj8'], {'cwd': unit_directory, 'exit_cb': function("s:RunThisGUnitTest", [unit_directory, s:last_test])})
        call add(s:terminals, term_no)
    elseif s:last_test_type == "UNITPP_SUITE"
        let term_no = term_start(['scons', '-uj8'], {'cwd': unit_directory, 'exit_cb': function("s:RunThisUnitTestPPTest", [unit_directory, s:last_test])})
        call add(s:terminals, term_no)
    elseif s:last_test_type == "BDD_WIN32_TEST_FILE"
        let term_no = term_start(['python', 'fgtest.py', s:last_test], {'cwd': bdd_directory})
        call add(s:terminals, term_no)
    else
        echoerr "Previous test not detected"
    endif

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


function! Build(platform)
    call CloseOpenedTerminals()
    if a:platform == "win32"
        let directory = 'Test/Scenarios/Win32'
    elseif a:platform == "target"
        let directory = 'Test/Scenarios/Target'
    else
        echoerr "Invalid platform"
    endif

    let term_no = term_start(['scons', '-uj8'], {'cwd': directory})
    call add(s:terminals, term_no)
    wincmd p
endfunction


nnoremap <leader>rtt :call RunThisTest("win32", 0)<CR>
nnoremap <leader>rtd :call RunThisTest("target", 0)<CR>
nnoremap <leader>rtp :call RunThisTest("win32", 1)<CR>
nnoremap <leader>rdp :call RunThisTest("target", 1)<CR>
nnoremap <leader>rtf :call RunThisTestFile()<CR>
nnoremap <leader>rtl :call RunTest()<CR>
nnoremap <leader>rsc :call RunStyleCheck()<CR>
nnoremap <leader>rbw :call Build("win32")<CR>
nnoremap <leader>rbt :call Build("target")<CR>
nnoremap <leader>rk :call KeepThisTerminal()<CR>
nnoremap <leader>rc :call CloseOpenedTerminals()<CR>
