#prompt and colours
BLACK='\[\e[0;30m\]'
RED='\[\e[0;31m\]'
GREEN='\[\e[0;32m\]'
YELLOW='\[\e[0;33m\]'
BLUE='\[\e[0;34m\]'
#BLUE='\[\033[32m\]'
PURPLE='\[\e[0;35m\]'
#PURPLE='\[\033[35m\]'
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

alias nose27='/usr/local/bin/nosetests'

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
alias tree="tree -C"
alias runnervm="~runner/bin/ctest wildcat-nst-e vncviewer"
alias makeHulkVnc="vncserver :68 -name HULK -depth 24 -geometry 1200x900"
alias makeBiggieVnc="vncserver :72 -name BIGGIE -depth 24 -geometry 1200x900"
alias fixType="~/Desktop/test.sh; xmodmap -e \"keycode 108 = Alt_R\"; xmodmap ~/modmap/modmap"

alias chimera="cd ~/git/chimera/yycli; deactivate; source ~/virtual_envs/chimeraEnv/bin/activate"
alias zephauto="cd /spgear/zeph_auto/"
alias ui="cd ~/git/ui/com-yottayotta-smsv2/src/java/com/yottayotta/smsv2"
alias chimerareview="cd ~/git/chimeraReview/chimera/yycli; deactivate; source ~/virtual_envs/chimeraEnv/bin/activate"
alias chimeratestcases="cd ~/git/chimeraTestcases/chimera_api_tests"
alias chimera3="cd ~/git/chimera3/yycli; deactivate; source ~/virtual_envs/chimeraEnv/bin/activate"
alias metrics="cd ~/git/chimera_metrics; deactivate; source ~/virtual_envs/metricsEnv/bin/activate"

alias runnerpewpewve="cd ~/runner/testing/sms-pewpewve"
alias runnerwildcatnste="cd ~runner/testing/wildcat-nst-e/"
alias runnerkraken="cd ~campbr9/runner/testing/sms-kraken-1/"

alias cqdl='access_cqattgw download --mail_when_done 1 --rid'

alias aoeu="setxkbmap us"
alias asdf="setxkbmap dvorak"

alias deleteClassFiles="find . -name '*py.class' | xargs rm"

#alias rdesktop='rdesktop -E -g 1024x768'

alias windows='rdesktop bryanm3-zw.spgear.lab.emc.com -g 1225x975 -E'

#alias apacherestart='sudo /etc/init.d/apache2 restart; sudo /etc/init.d/memcached restart'
alias apacherestart='sudo /etc/init.d/apache2 restart'

function mkcd() {
    mkdir -p "$@"
    cd "$@"
}

export PATH=/spgear/tools/bin:/bin:/usr/bin:/sbin:/usr/local/bin:/opt/rational/clearcase/bin:/usr/games:/home/runner/bin:/spgear/spgear/bin
export PYTHONPATH=:~/git/chimera/yycli/:~/git/chimera/yycli/commonPythonLibrary/
export PYTHONSTARTUP=~/.pythonrc

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
alias masterfreeze="post-review --guess-summary --guess-description -p --branch origin/master"
alias devfreeze="post-review --guess-summary --guess-description -p --branch origin/dev"
alias freezefreeze="post-review --guess-summary --guess-description -p --branch origin/freeze"
alias metricsfreeze="post-review --guess-summary --guess-description -p --branch origin/b/master --target-people steffk,line6,campbr9"
alias postDiff="post-review --diff-only -p -r"
alias pl="pylint --rcfile=/home/bryanm3/git/chimera/tools/pyLintRcFile.cfg -f colorized -r n --include-ids=y"
alias gitdiffmeld="git difftool -y -t meld"
alias gsmup="pushd /home/bryanm3/git/chimera; git submodule update; popd"

function newbr() {
    git checkout -b "master_$@" origin/master
}

function newdevbr() {
    git checkout -b "dev_$@" origin/dev
}

function newfreezebr() {
    git checkout -b "freeze_$@" origin/freeze
}

function newmetricsbr() {
    git checkout -b "$@" origin/b/master
}

function cov() {
    ~/bin/quickCoverage.sh $@
}

source ~/.git-completion.bash
export GIT_PS1_SHOWDIRTYSTATE=1
export PS1='\[\e[0;36m\]$(__git_ps1)\[\e[0;35m\]\u\[\e[0;37m\]@\[\e[0;32m\]\h\[\e[0;37m\]:\[\e[0;33m\]\w\[\e[0;37m\]\$ '
