#prompt and colours
BLACK='\[\e[0;30m\]'
RED='\[\e[0;31m\]'
GREEN='\[\e[0;32m\]'
YELLOW='\[\e[0;33m\]'
BLUE='\[\e[0;34m\]'
PURPLE='\[\e[0;35m\]'
CYAN='\[\e[0;36m\]'
WHITE='\[\e[0;37m\]'
BLACKBG='\[\e[40m\]'

BACKGROUNDISWHITE=false

alias omg="ls -l"

if [ "$BACKGROUNDISWHITE" = "false" ]; then
    DIVIDER=$WHITE
    USER=$PURPLE
    HOST=$GREEN
    DIR=$YELLOW
else
    DIVIDER=$BLACK
    USER=$BLUE
    HOST=$RED
    DIR=$PURPLE
fi

trap ". ~/.bashrc" USR1

# tab completion
[ -r /etc/bash_completion ] && . /etc/bash_completion
#source /spgear/zeph_auto/ctest_completion.bash

alias py27="/usr/bin/python2.7"
alias py26="/usr/bin/python2.6"

alias hulk="ssh service@10.6.215.118"
alias biggie="ssh service@vmvisor-002"
alias shin="ssh service@vmvisor-009"
alias pewpew="ssh service@10.6.209.55"
alias griffin="ssh service@10.6.209.40"
alias hogwartsed="ssh hogwartsed"
alias hogwarts="ssh hogwarts"
alias hogwartsi="ssh hogwartsi"
alias asdf1="ssh service@10.6.209.63"
alias asdf2="ssh service@10.6.209.37"
alias gator1="ssh service@10.6.209.99"
alias gator2="ssh service@10.6.209.100"
alias corrado="ssh service@10.6.215.103"
alias ls="ls --color"
alias cov="~/bin/quickCoverage.sh"
alias runnervm="~runner/bin/ctest wildcat-nst-e vncviewer"
alias makeHulkVnc="vncserver :68 -name HULK -depth 24 -geometry 1200x900"
alias makeBiggieVnc="vncserver :72 -name BIGGIE -depth 24 -geometry 1200x900"
alias fixType="~/Desktop/test.sh; xmodmap -e \"keycode 108 = Alt_R\"; xmodmap ~/modmap/modmap"

alias chimera="cd ~/git/chimera/yycli"
alias zephauto="cd /spgear/zeph_auto/"
alias ui="cd ~/git/ui/com-yottayotta-smsv2/src/java/com/yottayotta/smsv2"
alias chimerareview="cd ~/git/chimeraReview/chimera/yycli"
alias chimeratestcases="cd ~/git/chimeraTestcases/chimera_api_tests"
alias chimera3="cd ~/git/chimera3/yycli"

alias runnerpewpewve="cd ~/runner/testing/sms-pewpewve"
alias runnerwildcatnste="cd ~runner/testing/wildcat-nst-e/"
alias runnerkraken="cd ~campbr9/runner/testing/sms-kraken-1/"

alias cqdl='access_cqattgw download --mail_when_done 1 --rid'

alias aoeu="setxkbmap us"
alias asdf="setxkbmap dvorak"

alias deleteClassFiles="find . -name '*py.class' | xargs rm"

#alias rdesktop='rdesktop -E -g 1024x768'

alias windows='rdesktop bryanm3-zw.spgear.lab.emc.com -g 1225x975 -E'

function mkcd() {
    mkdir -p "$@"
    cd "$@"
}

export PS1="$USER\u$DIVIDER@$HOST\h$DIVIDER:$DIR\w$DIVIDER> "

export PATH=/spgear/tools/bin:/bin:/usr/bin:/sbin:/usr/local/bin:/opt/rational/clearcase/bin:/usr/games:/home/runner/bin
export PYTHONPATH=:~/git/chimera/yycli/:~/git/chimera/yycli/commonPythonLibrary/
export PYTHONSTARTUP=~/.pythonrc

bind C-p:history-search-backward
bind C-n:history-search-forward

# GIT STUFF
# ===============================================================================
## Context sensitive aliases
# make all function variables local
# undo aliases of previous context
# set up new context sensitive aliases
# try not to run any non-native bash cmds... this has to execute a lot
__git_undo() {
    unalias br ch co ca st log masterfreeze devfreeze freezefreeze pl gitdiffmeld gsmup
}
__git_do() {
    local git_br
    read git_br < $1/.git/HEAD
    __working_branch=${git_br##*refs/heads/}
    [ "$git_br" == "$__working_branch" ] && __working_branch="(no branch)"
    __working_in="${1##*/}"
    __working_branch="[$__working_branch]"
    __working_dir="${PWD##$1}"
    __undo_context=__git_undo
    alias br="git branch"
    alias ch="git checkout"
    alias co="git commit -v -a"
    alias ca="git commit -v -a --amend"
    alias st="git status"
    alias log="git log"
    alias masterfreeze="post-review --guess-summary --guess-description -p --branch origin/master"
    alias devfreeze="post-review --guess-summary --guess-description -p --branch origin/dev"
    alias freezefreeze="post-review --guess-summary --guess-description -p --branch origin/freeze"
    alias postDiff="post-review --diff-only -p -r"
    alias pl="pylint --rcfile=/home/bryanm3/git/chimera/tools/pyLintRcFile.cfg -f colorized -r n --include-ids=y"
    alias gitdiffmeld="git difftool -y -t meld"
    alias gsmup="pushd /home/bryanm3/git/chimera; git submodule update; popd"
}

function newbr() {
    git checkout -b "master_$@" origin/master
}

function newdevbr() {
    git checkout -b "dev_$@" origin/dev
}

function newfreezebr() {
    git checkout -b "freeze_$@" origin/freeze
}

function updateFixdTickets() {
    echo "Gathering tickets in FIXD/BUILDTBD or FIXD/VERIFY......"
    LIST=`csetool zeph_auto query --expr "tickets:state:FIXD/BUILDTBD|tickets:state:FIXD/VERIFY" --form id | xargs`
    echo "Updating to 'fixed in $@'"
    for rid in $LIST; do \
        echo $rid;
        csetool zeph_auto ticket:update --rid $rid --state CLSD/NOTEST --buildFixed $@ --description "Fixed in $@. We are marking it CLSD/NOTEST. The submitter can leave it in that state, change it to CLSD/VERIFIED, or re-open if the problem is not fixed.";
    done;
}

__git_dir() {
    local tmppath
    tmppath=$PWD
    while [ "$tmppath" != "" ]; do
        [ -d "$tmppath"/.git ] && __git_do "$tmppath" && return 0
        [ ${tmppath##*/} == .git ] && return 1
        tmppath=${tmppath%/*}
    done
    return 1
}
__other_dir() {
    __working_in=
    __working_branch=
    __working_dir=
    __undo_context=true
}
__prompt_command() {
    $__undo_context
    __git_dir || __other_dir  # add more as needed
    echo -ne "\033]0;$__working_in$__working_branch$__working_dir\007"
    if __git_dir eq 1
    then
        #export PS1='\[\e[31m\]`r=$?; test $r -ne 0 && echo "[ERR-$r] "`\[\e[0m\]$__working_in\[\e[33m\]$__working_branch\[\e[0m\]$__working_dir$'
        export PS1="$CYAN$__working_branch$USER\u$DIVIDER@$HOST\h$DIVIDER:$DIR\w$DIVIDER\$ "
    else
        export PS1="$USER\u$DIVIDER@$HOST\h$DIVIDER:$DIR\w$DIVIDER\$ "
    fi
}
PROMPT_COMMAND=__prompt_command
