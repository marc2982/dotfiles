if !has('python')
    echo "Error: Required vim compiled with +python"
    finish
endif

function! s:LoadUnitTest()
python << EOF

import vim
import os

fileName = vim.eval("@%").split("/")[-1]
utFileName = "test_" + fileName

fullPath = os.path.join(vim.eval("getcwd()"), vim.eval("expand('%')"))
splitPath = fullPath.split("/")
yycliIndex = splitPath.index("yycli")

chimeraPath = "/".join(splitPath[:6])

utPath = os.path.join(chimeraPath, "testHarness/unitTests", "/".join(splitPath[yycliIndex+1:-1]), utFileName)

vim.command(":vsp %s" % utPath)

EOF
endfunction

command LoadUnitTestFile :call <SID>LoadUnitTest()
