" Run python unittests from vim.
"
" You need to tell unittest.vim how to work with your project using the
" g:unittest_projects variable. See CUSTOMIZATION below.
"
" The current project is determined using vim's current working directory.
"
" COMMANDS:
"
" Unittest{Open,Split,VSplit}
"   With a project module open in the current window, open the corresponding
"   unittests. This also works the other way: if unittests are open in the
"   current buffer the source will be opened.
"
" Unittest
"   With either the the module to be tested or its unit tests open in the
"   current window, run that module's unittests and populate the quickfix list
"   (see :help quickfix) with the locations of errors and failures.
"
" UnittestAll
"   Run all the project's unittests.
"
" UnittestFailed{,All}
"   Run all the tests that failed during the last invocation of Unittest{,All}
"
"
" CUSTOMIZATION:
"
" g:unittest_projects (default: setup for Chimera and goat)
"   A list of dicts containing the following keys:
"     pattern: Used to determine which project is currently in use.
"         pattern must match the absolute path to the repository root.
"     unittests: repo-relative path to unittest directory
"     source2unit: List of substitute() [pat, sub] args to transform an
"         absolute source module filepath to the corresponding unittest
"         module.
"     unit2source: Same as source2unit, but in the other direction.
"     runner: Runner command.
"         Instances of '$REPOROOT' will be replaced with the absolute path to
"         the project's repository root.
"
" g:unittest_resultFilepath (default: '/tmp/runUnitTests')
"   File to store test runner output.
"
" g:unittest_openOutputOnOk (default: 0)
"   If 1, open the test runner output window even if all tests passed.
"
" g:unittest_openOutputOnFail (default: 1)
"   If 1, open the window containing test runner output when tests fail.
"
" g:unittest_openQuickFix (default: 0)
"   If 1, open the quickfix window when tests fail.
"
" g:unittest_focus (default: 'keep')
"   Set focus to the given window after running tests:
"       'keep': active window when Unittest* was called
"       'qf': quickfix window
"       'out': unittest output
"

command! UnittestOpen exe ":e " . <SID>OtherPath(expand('%:p'))
command! UnittestSplit exe ":sp " . <SID>OtherPath(expand('%:p'))
command! UnittestVSplit exe ":vsp " . <SID>OtherPath(expand('%:p'))
command! Unittest call <SID>Run(expand('%:p'), 1, 0)
command! UnittestAll call <SID>Run('', 1, 0)
command! UnittestFailed call <SID>Run(expand('%:p'), 1, 1)
command! UnittestFailedAll call <SID>Run('', 1, 1)
command! UnittestOpenResults exe ":e " . g:unittest_resultFilepath

nnoremap <leader>ur :Unittest<cr>
nnoremap <leader>ua :UnittestAll<cr>
nnoremap <leader>ufr :UnittestFailed<cr>
nnoremap <leader>ufa :UnittestFailedAll<cr>
nnoremap <leader>uo :UnittestOpen<cr>
nnoremap <leader>us :UnittestSplit<cr>
nnoremap <leader>uv :UnittestVSplit<cr>

hi UnittestPass term=reverse ctermfg=white ctermbg=darkgreen guifg=white guibg=green
hi UnittestFail   term=reverse ctermfg=white ctermbg=red guifg=white guibg=red

if !exists('g:unittest_resultFilepath')
    let g:unittest_resultFilepath = '/tmp/runUnitTests'
endif

if !exists('g:unittest_openOutputOnOk')
    let g:unittest_openOutputOnOk = 0
endif

if !exists('g:unittest_openOutputOnFail')
    let g:unittest_openOutputOnFail = 1
endif

if !exists('g:unittest_openQuickFix')
    let g:unittest_openQuickFix = 0
endif

if !exists('g:unittest_focus')
    let g:unittest_focus = 'keep'
endif

if !exists('g:unittest_projects')
    let g:unittest_projects = [
        \ {
            \ 'pattern': '\v/chimera[0-9]?(/|$)',
            \ 'unittests': 'yycli/testHarness/unitTests',
            \ 'source2unit': ['\v.*/yycli/(.*)/([^/]*)', 'yycli/testHarness/unitTests/\1/test_\2'],
            \ 'unit2source': ['\v.*/unitTests/(.*)/test_([^/]*)', 'yycli/\1/\2'],
            \ 'runner': '$REPOROOT/yycli/runUnitTests.py',
        \ },
        \ {
            \ 'pattern': '\v/(chimera_)?goat[0-9]?(/|$)',
            \ 'unittests': 'goat/tests/unit',
            \ 'source2unit': ['\v.*/goat/(.*)/([^/]*)', 'goat/tests/unit/\1/test_\2'],
            \ 'unit2source': ['\v.*/tests/unit/(.*)/test_([^/]*)', 'goat/\1/\2'],
            \ 'runner': 'nosetests -c $REPOROOT/setup.cfg',
        \ },
    \ ]
endif

" filepath and bufname for results
let g:unittest_resultFilepath = '/tmp/runUnitTests'
let s:lastpath = ''

" active buffer when Run was called.
let s:origBufnr = 0
let s:qfBufnr = 0


function! UnittestPrintConfig()
    let vars = [
        \ 'g:unittest_resultFilepath',
        \ 'g:unittest_openOutputOnOk',
        \ 'g:unittest_openOutputOnFail',
        \ 'g:unittest_openQuickFix',
        \ 'g:unittest_focus',
        \ 'g:unittest_projects',
    \ ]
    for var in vars
        exe printf('echo "%s=%s"', var, string(eval(var)))
    endfor
endfunction

function! <SID>Run(fullpath, saveIds, onlyFailedIds)
" fullpath
"     Absolute path to a file or directory containing unittests.
"     If the empty string ('') is given the runner is free to discover
"     whatever tests it wants, which is most likely all of them.
" saveIds
"     Bool. Use the testid nosetests plugin to keep track of which tests fail.
"     Requires using the nosetests runner. If a script is wrapping nosetest
"     it'll need to pass unused args to it.
" onlyFailedIds
"     Bool. Only run unittests that failed last time, according to testid.
"     Implies saveIds.
    let s:origBufnr = bufnr('%')
    let command = s:runnerCommand(a:fullpath, a:saveIds, a:onlyFailedIds)
    echom printf('Running "%s"...', command)
    let lines = split(system(command), '\n')
    cal writefile(lines, g:unittest_resultFilepath)

    redraw
    cal setqflist(s:unittestFailureLocations(lines))
    if lines[-1] =~ '^OK'
        if g:unittest_openOutputOnOk
            cal s:openWindow(lines)
        else
            cal s:refreshWindow()
        endif
    else
        if g:unittest_openOutputOnFail
            cal s:openWindow(lines)
        else
            cal s:refreshWindow()
        endif
        if g:unittest_openQuickFix
            copen
            let s:qfBufnr = bufnr('%')
        endif
    endif
    cal s:printSummary(lines)
    cal s:focus()
    let s:lastpath = a:fullpath
endfunction

function! s:runnerCommand(fullpath, saveIds, onlyFailedIds)
    let command = []
    let project = s:project()
    let path = s:pathToTest(a:fullpath)
    let repoRoot = s:repoRoot()
    let relativeRepoRoot = fnamemodify(repoRoot, ':~:.')
    let runAll = (path == '')
    let runner = project['runner']
    let runner = substitute(runner, '\$REPOROOT', relativeRepoRoot, '')
    cal add(command, runner)
    cal extend(command, s:saveIdArgs(runAll, a:saveIds, a:onlyFailedIds))
    if path != ''
        cal add(command, s:relpath(project['unittests'], path))
    endif
    return join(command)
endfunction

function! s:pathToTest(fullpath)
    if a:fullpath == ''
        return ''
    elseif bufname('%') ==# g:unittest_resultFilepath && s:lastpath != ''
        return s:lastpath
    elseif s:isUnittest(a:fullpath)
        return a:fullpath
    else
        return s:source2Unittest(a:fullpath)
    endif
endfunction

function! s:saveIdArgs(runAll, saveIds, onlyFailedIds)
    let args = []
    if a:saveIds || a:onlyFailedIds
        cal add(args, '--with-id')
        let dir = fnamemodify(s:repoRoot(), ':~:.')
        if a:runAll
            cal add(args, printf('--id-file=%s/.noseids_all', dir))
        else
            cal add(args, printf('--id-file=%s/.noseids_one', dir))
        endif
    endif
    if a:onlyFailedIds
        cal add(args, '--failed')
    endif
    return args
endfunction

function! <SID>OtherPath(fullpath)
    if s:isUnittest(a:fullpath)
        return s:unittest2Source(a:fullpath)
    else
        return s:source2Unittest(a:fullpath)
    endif
endfunction

function! s:isUnittest(fullpath)
    let project = s:project()
    if stridx(a:fullpath, project['unittests']) != -1
        return 1
    endif
    return 0
endfunction

function! s:source2Unittest(fullpath)
    let project = s:project()
    let [pat, sub] = project['source2unit']
    return substitute(a:fullpath, pat, sub, '')
endfunction

function! s:unittest2Source(fullpath)
    let project = s:project()
    let [pat, sub] = project['unit2source']
    return substitute(a:fullpath, pat, sub, '')
endfunction

" It might be easier to do this using 'errorformat'.
function! s:unittestFailureLocations(nosetest_output)
    let lines = a:nosetest_output
    let locList = []
    let i = 0
    while i < len(lines)
        let line = lines[i]
        let groups = matchlist(line, '\v^%(ERROR|FAIL): (\w+) \(([^)]+)\)$')
        if len(groups) > 0
            let funcName = groups[1]
            let class = groups[2]
            let relpath = join(split(class, '\.')[:-2], '/') . '.py'
            let filepath = join([s:repoRoot(), relpath], '/')
            let lnum = 0
            let exception = ''
            " Try to find a traceback entry from a test_* function and the
            " traceback's exception, but give up when the next header is
            " reached.
            let i += 1
            while 1
                if i >= len(lines)
                    break
                endif
                let line = lines[i]
                if line == '' || line =~ '^======='
                    break
                endif

                let groups = matchlist(line, '\vFile "([^"]*)", line (\d+), in test_')
                if len(groups) > 0
                    let filepath = groups[1]
                    let lnum = groups[2]
                endif

                if line =~ '\v^\w+: '
                    let exception = line
                endif

                let i += 1
            endwhile
            " If no test_* function traceback entry was found grep the file
            " for the test function.
            if lnum == 0
                let grepcmd = printf('grep -m 1 -n "def %s" %s', funcName, filepath)
                let lnum = str2nr(system(grepcmd))
            endif
            call add(locList, {'filename': filepath, 'lnum': lnum, 'text': exception})
        endif
        let i += 1
    endwhile
    return locList
endfunction

function! s:refreshWindow()
    let buffer_name = g:unittest_resultFilepath
    let window = bufwinnr(buffer_name)
    if window != -1
        exe printf('%dwincmd w', window)
        silent edit %
    endif
endfunction

function! s:openWindow(lines)
    let buffer_name = g:unittest_resultFilepath
    let window = bufwinnr(buffer_name)
    if window != -1
        exe printf('%dwincmd w', window)
        silent edit %
    else
        exe printf('silent! keepalt split %s', buffer_name)
        setlocal noswapfile
    endif
endfunction

function! s:printSummary(lines)
    let groups = matchlist(a:lines[-3], '\vRan (\d+) test')
    let run = str2nr(get(groups, 1, 0))
    let groups = matchlist(a:lines[-1], '\verrors\=(\d+)')
    let errors = str2nr(get(groups, 1, 0))
    let groups = matchlist(a:lines[-1], '\vfailures\=(\d+)')
    let failures = str2nr(get(groups, 1, 0))
    let notPassed = failures + errors
    if notPassed > 0
        echohl UnittestFail
        let msg = printf('%d of %d failed', notPassed, run)
    else
        echohl UnittestPass
        let msg = printf('All %d tests passed', run)
    endif
    echon msg repeat(' ', &columns - strlen(msg) - 1)
    echohl None
endfunction

function! s:focus()
    let buffer = -1
    if g:unittest_focus == 'keep'
        let buffer = s:origBufnr
    elseif g:unittest_focus == 'qf'
        let buffer = s:qfBufnr
    elseif g:unittest_focus == 'out'
        let buffer = bufnr(g:unittest_resultFilepath)
    else
        echom printf('Invalid g:unittest_focus: "%s"', g:unittest_focus)
    endif
    if buffer < 0 || bufwinnr(buffer) < 0
        let buffer = s:origBufnr
    endif
    exe printf('%dwincmd w', bufwinnr(str2nr(buffer)))
endfunction

function! s:project()
    let repoRoot = s:repoRoot()
    for project in g:unittest_projects
        if repoRoot =~ project['pattern']
            return project
        endif
    endfor
    throw 'No project found for ' . repoRoot
endfunction

function! s:repoRoot()
    return s:trim(system("git rev-parse --show-toplevel"))
endfunction

function! s:relpath(parent, child)
" parent and child must be absolute paths
" return a relative path from parent to child, or child.
    if stridx(a:child, a:parent) == 0
        return substitute(a:child[strlen(a:parent):], '^/', '', '')
    else
        return a:child
    endif
endfunction

function! s:trim(s)
    return substitute(a:s, '\v^(\s|\n)*|(\s|\n)*$', '', 'g')
endfunction
