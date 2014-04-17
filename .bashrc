#Style Guide for Python Codeprompt and colours
trap ". ~/.bashrc" USR1

# tab completion
[ -r /etc/bash_completion ] && . /etc/bash_completion
#source /spgear/zeph_auto/ctest_completion.bash

# Try to disable flow control
[ -t 0 ] && stty -ixon -ixoff

alias py27="/usr/bin/python2.7"
alias py26="/usr/bin/python2.6"

alias nose27='/usr/local/bin/nosetests'

alias hulk="ssh service@10.6.215.118"
alias biggie="ssh service@vmvisor-002"
alias shin="ssh service@vmvisor-009"
alias pewpew="ssh service@10.6.209.7"
alias griffin="ssh service@10.6.209.40"
alias hogwartsed="ssh hogwartsed"
alias hogwarts="ssh hogwarts"
alias hogwartsi="ssh hogwartsi"
alias asdf1="ssh service@10.6.209.63"
alias asdf2="ssh service@10.6.209.37"
alias gator1="ssh service@10.6.209.99"
alias gator2="ssh service@10.6.209.100"
alias gengar1="ssh service@10.6.209.203"
alias gengar2="ssh service@10.6.209.204"
alias heisenburg="ssh service@10.6.213.180"
alias corrado="ssh service@10.6.215.103"
alias ls="ls --color"
alias tree="tree -C"
alias runnervm="~runner/bin/ctest wildcat-nst-e vncviewer"
alias makeHulkVnc="vncserver :68 -name HULK -depth 24 -geometry 1200x900"
alias makeBiggieVnc="vncserver :72 -name BIGGIE -depth 24 -geometry 1200x900"
alias fixType="~/Desktop/test.sh; xmodmap -e \"keycode 108 = Alt_R\"; xmodmap ~/modmap/modmap"

alias chimera="cd ~/git/chimera/yycli; deactivate; source ~/virtual_envs/chimeraEnv/bin/activate"
alias goatdev="deactivate; cd ~/git/chimera_goat; source ~/virtual_envs/goat/bin/activate"
alias zephauto="cd /spgear/zeph_auto/"
alias ui="cd ~/git/ui/"
alias chimerareview="cd ~/git/chimeraReview/chimera/yycli; deactivate; source ~/virtual_envs/chimeraEnv/bin/activate"
alias chimeratestcases="cd ~/git/chimeraTestcases/chimera_api_tests"
alias chimera3="cd ~/git/chimera3/yycli; deactivate; source ~/virtual_envs/chimeraEnv/bin/activate"
alias metrics="cd ~/git/chimera_metrics; deactivate; source ~/virtual_envs/metricsEnv/bin/activate"
alias reviewboard="cd ~/git/reviewboard; deactivate; source ~/virtual_envs/reviewboard/bin/activate"

alias runnerpewpewve="cd ~/runner/testing/sms-pewpewve"
alias runnerwildcatnste="cd ~runner/testing/wildcat-nst-e/"
alias runnerkraken="cd ~campbr9/runner/testing/sms-kraken-1/"

alias vim='vim -w ~/.vimlog "$@"'

alias cqdl='access_cqattgw download --mail_when_done 1 --rid'

alias aoeu="setxkbmap us"
alias asdf="setxkbmap dvorak"

alias deleteClassFiles="find . -name '*py.class' | xargs rm"

#alias rdesktop='rdesktop -E -g 1024x768'

#alias windows='rdesktop bryanm3-zw.spgear.lab.emc.com -g 1225x975 -E'
alias windows='rdesktop bryanm3-w7 -g 1225x975 -E'

#alias apacherestart='sudo /etc/init.d/apache2 restart; sudo /etc/init.d/memcached restart'
alias apacherestart='sudo /etc/init.d/apache2 restart'

function mkcd() {
    mkdir -p "$@"
    cd "$@"
}

export PATH=/home/bryanm3/special_paths:/spgear/tools/bin:/bin:/usr/bin:/sbin:/usr/local/bin:/opt/rational/clearcase/bin:/usr/games:/home/runner/bin:/spgear/spgear/bin
export PYTHONSTARTUP=~/.pythonrc
export LUA_PATH="./?.lua;./lua/?.lua;;"

if [[ "$-" == *i* ]]; then # interactive
    bind C-p:history-search-backward
    bind C-n:history-search-forward
fi

alias br="git branch"
alias ch="git checkout"
alias co="git commit -v -a"
alias ca="git commit -v -a --amend"
alias st="git status"
alias log="git log"
alias pl="pylint --rcfile=/home/bryanm3/git/chimera/tools/pyLintRcFile.cfg -f colorized -r n --include-ids=y"
alias gitdiffmeld="git difftool -y -t meld"
alias gsmup="pushd /home/bryanm3/git/chimera; git submodule update; popd"

function getRevisionRange() {
    local num_commits_ahead="HEAD~"`git rev-list @{u}.. | wc -l`
    local rev_range=`git rev-parse $num_commits_ahead`":"`git rev-parse HEAD`
    echo $rev_range
}

function getReviewIdFromBranchName() {
    local current_branch_name=`git rev-parse --abbrev-ref HEAD`
    local reviewid=`expr "$current_branch_name" : '.\+__rb\([0-9]\+\)$'`
    echo $reviewid
}

function postDiff() {
    local reviewid=`getReviewIdFromBranchName`
    if [[ -z "$reviewid" ]] || [[ "$reviewid" == "" ]]; then
        echo "No review ID found; stopping."
    else
        echo "Review ID found: "$reviewid
        local rev_range=`getRevisionRange`
        local output="post-review --diff-only --guess-description -p -r $reviewid --revision-range=$rev_range $@"
        echo $output
        $output
    fi
}

function freeze() {
    local tracking_branch=`git tracking`
    local rev_range=`getRevisionRange`
    local output=`post-review --guess-summary --guess-description --branch $tracking_branch --revision-range=$rev_range -p $@`
    echo $output

    local reviewid=`expr "$output" : '.* \#\([0-9]\+\) .*'`
    if [[ -z "$reviewid" ]] || [[ "$reviewid" == "" ]]; then
        echo "Could not find a review ID; stopping."
    else
        local current_branch_name=`git rev-parse --abbrev-ref HEAD`
        if [[ -z "$current_branch_name" ]] || [[ "$current_branch_name" == "" ]]; then
            echo "Could not find a current branch name; stopping."
        else
            local new_branch_name=$current_branch_name"__rb"$reviewid
            echo "New branch name: "$new_branch_name
            `git branch -m $new_branch_name`
        fi
    fi
}

function newbr() {
    git checkout --track -b "master_$@" origin/master
}

function newdevbr() {
    git checkout --track -b "dev_$@" origin/dev
}

function newfreezebr() {
    git checkout --track -b "freeze_$@" origin/freeze
}

function newmetricsbr() {
    git checkout --track -b "$@" origin/b/master
}

function goatcov() {
    ~/bin/code_coverage/goat_coverage.sh $@
}

function cov() {
    local coverage="/usr/local/bin/coverage2"
    local covrc_ini="/home/bryanm3/code_coverage/covrc.ini"
    $coverage run --branch --rcfile $covrc_ini ./runUnitTests.py --with-coverage --no-parallel --cover-html --cover-html-dir=/home/bryanm3/public_html/html_cov $@
}

function send_key {
    ssh $1 "echo $(cat /home/torbij/.ssh/id_rsa.pub) >> ~/.ssh/authorized_keys "
}

function check_file() {
    echo 'PEP8:' && pep8 $@; echo 'PEP257:' && pep257 $@
}

function prompt1() {
    local black="\[\e[30m\]"
    local red="\[\e[31m\]"
    local green="\[\e[32m\]"
    local yellow="\[\e[33m\]"
    local blue="\[\e[34m\]"
    local purple="\[\e[35m\]"
    local cyan="\[\e[36m\]"
    local white="\[\e[37m\]"

    source ~/.git-completion.bash
    GIT_PS1_SHOWDIRTYSTATE=0
    PS1="$cyan\$(__git_ps1) $red\$(date +%H:%M) $purple\u$white@$green\h$white:$yellow\w$white\$ "
}
prompt1

export TERM=xterm-256color

function fuck() {
    if killall -9 "$2"; then
        echo ; echo " (╯°□°）╯︵$(echo "$2"|toilet -f term -F rotate)"; echo
    fi
}

#source ~/.bash_completion.d/python-argcomplete.sh
#eval "$(register-python-argcomplete goat)"
