#trap ". ~/.bashrc" USR1

# Try to disable flow control
# (-t FD => if file descriptor is open and refers to a terminal)
[ -t 0 ] && stty -ixon -ixoff

export GOPATH=$HOME/go
export XDG_CONFIG_HOME=$HOME/.config

export PATH=$HOME/special_paths:/bin:/usr/local/bin:/sbin:/usr/bin:/usr/games:$HOME/.local/bin:/usr/local/go/bin:$GOPATH/bin/:/home/runner/bin

export HISTFILESIZE=10000
export HISTSIZE=10000
export LUA_PATH="./?.lua;./lua/?.lua;;"
export PYTHONSTARTUP=$HOME/.pythonrc
export TERM=xterm-256color

alias freecell='sol -v freecell'

alias apacherestart='sudo /etc/init.d/apache2 restart'
alias deleteClassFiles="find . -name '*py.class' | xargs rm"
alias fixType="$HOME/Desktop/test.sh; xmodmap -e \"keycode 108 = Alt_R\"; xmodmap $HOME/modmap/modmap"
alias ls="ls --color"
alias less="less -R"
alias nose27='/usr/local/bin/nosetests'
alias tree="tree -C"

alias vim='vim -w $HOME/.vimlog "$@"'

alias py26="/usr/bin/python2.6"
alias py27="/usr/bin/python2.7"
alias py34="/usr/bin/python3.4"

alias ccat='pygmentize -g'

alias aoeu="setxkbmap us"
alias asdf="setxkbmap dvorak"

function mkcd() {
    mkdir -p "$@"
    cd "$@"
}

if [[ "$-" == *i* ]]; then # interactive
    bind C-p:history-search-backward
    bind C-n:history-search-forward
fi

# git stuff
alias br="git branch"
alias ch="git checkout"
alias co="git commit -v -a"
alias ca="git commit -v -a --amend"
alias st="git status"
alias log="git log"
alias gitdiffmeld="git difftool -y -t meld"

function send_key() {
    ssh $1 "echo $(cat $HOME/.ssh/id_rsa.pub) >> $HOME/.ssh/authorized_keys "
}

function send_key_and_login() {
    # usage: send_key_and_login service@sms-glados-1
    ssh-copy-id -i $HOME/.ssh/id_rsa.pub "$@"
    ssh "$@"
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

    source $HOME/.git-completion.bash
    GIT_PS1_SHOWDIRTYSTATE=0
    PS1="$cyan\$(__git_ps1) $red\$(date +%H:%M) $purple\u$white@$green\h$white:$yellow\w$white\$ "
}
prompt1

function prompt_reversed() {
    local black="\[\e[30m\]"
    local red="\[\e[31m\]"
    local green="\[\e[32m\]"
    local yellow="\[\e[33m\]"
    local blue="\[\e[34m\]"
    local purple="\[\e[35m\]"
    local cyan="\[\e[36m\]"
    local white="\[\e[37m\]"

    source $HOME/.git-completion.bash
    GIT_PS1_SHOWDIRTYSTATE=0
    PS1="$black\$(__git_ps1) \$(date +%H:%M) \u@\h:\w\$ "
}

function fuck() {
    if killall -9 "$2"; then
        echo ; echo " (╯°□°）╯︵$(echo "$2"|toilet -f term -F rotate)"; echo
    fi
}

function battery_life() {
    upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage
}

function top_disk_users() {
    local cmd="du -hs $1/* 2> /dev/null | sort -hr | head -n 10"
    echo "Running: $cmd"
    eval $cmd
}

# (-e = if file exists, -r = -e && is readable)
[ -r /etc/bash_completion ] && . /etc/bash_completion
[ -r $HOME/.bashrc.local ] && . $HOME/.bashrc.local

# virtualenv / virtualenvwrapper
export WORKON_HOME=$HOME/virtual_envs
[ -r /usr/local/bin/virtualenvwrapper.sh ] && source /usr/local/bin/virtualenvwrapper.sh


PERL_MB_OPT="--install_base \"/$HOME/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/$HOME/perl5"; export PERL_MM_OPT;
