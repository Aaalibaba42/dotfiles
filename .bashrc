#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='$? <$(pwd)>\n42sh$ '

export PATH="$PATH:~/hsh/scripts/bin"

export HISTFILESIZE=
export HISTSIZE=

# ls
alias ls='ls -hN --color=always'
alias la='ls -A --color=always'
alias l.='ls -A --color=always | grep --color=always "^\."'
alias ll='ls -oh --color=always'
alias lla='ls -oAh --color=always'

# builds
alias extar='mv ~/Downloads/*.tar . && ex *.tar && rm *.tar'
alias lgcc='gcc -o main -std=c23 -pedantic -Werror -Wall -Wextra -Wvla'
alias lcgpp='clang++ -o main -std=c++23 -pedantic -Werror -Wall -Wextra -Wvla -Wold-style-cast'
alias lgpp='g++ -o main -std=c++23 -pedantic -Werror -Wall -Wextra -Wvla -Wold-style-cast'
alias cfc='find . \( -name "*.c" -o -name "*.h" -o -name "*.cxx" \) -exec clang-format -i {} +'
# naming conventions are manyfold in C++
alias cfcpp='find . \( -name "*.cc"  \
                    -o -name "*.cpp" \
                    -o -name "*.cxx" \
                    -o -name "*.inl" \
                    -o -name "*.inc" \
                    -o -name "*.hh"  \
                    -o -name "*.h"   \
                    -o -name "*.cxx" \
                \) -exec clang-format -i {} +'
alias cm='cmake -S . -B build && cmake --build build --parallel'

# LadyBird fixme roulette
alias lbr="grep -rin --include='*.c' --include='*.h' --include='*.cpp' --exclude-dir='Build' --include='*.hpp' -e 'FIXME' -e 'TODO' \$(g root) 2>/dev/null | shuf -n 5"

# general purpose
alias sudo='doas'
alias g='git'
alias du='du -h'
alias reboot='shutdown -r now'
alias shutdown='shutdown now'
alias mkdir='mkdir -pv'
function mkdircd()
{
    mkdir -pv "$1" && cd "$1"
}
alias ..='cd ..'
alias ...='cd ../..'
alias 3.='cd ../../..'
alias 4.='cd ../../../..'
alias 5.='cd ../../../../..'
alias 6.='cd ../../../../../..'
alias 7.='cd ../../../../../../..'
alias 8.='cd ../../../../../../../..'
alias 9.='cd ../../../../../../../../..'
alias groot='cd $(g root)'
alias perg='grep --color=always -vi'
alias cp='cp -ri'
alias mv='mv -i'
alias df='df -ha'
alias tree='tree -C'
alias treea='tree -aC'
alias clr='clear && uwufetch && ls -hN'
alias echo='echo -e'
alias hx='helix'
alias tmpws='cd $(mktemp -d)'
alias grep='grep --color=always -n'

# Pacman
alias spacman='doas pacman'
alias spacmans='doas pacman -S --noconfirm'
alias pacsyu='doas pacman -Syy --noconfirm archlinux-keyring chaotic-keyring; paru -Syu --noconfirm; cargo install-update -a'
alias spacmanr='doas pacman -Rsn'
alias pacsearch='pacman -Ss'
alias parsearch='paru -Ss'

function ex()
{
    if [ -f "$1" ] ; then
        case "$1" in
            *.tar.bz2) tar xjf    "$1" ;;
            *.tar.gz)  tar xzf    "$1" ;;
            *.bz2)     bunzip2    "$1" ;;
            *.rar)     unrar x    "$1" ;;
            *.gz)      gunzip     "$1" ;;
            *.tar)     tar xf     "$1" ;;
            *.tbz2)    tar xjf    "$1" ;;
            *.tgz)     tar xzf    "$1" ;;
            *.zip)     unzip      "$1" ;;
            *.Z)       uncompress "$1" ;;
            *.7z)      7z x       "$1" ;;
            *.deb)     ar x       "$1" ;;
            *.tar.xz)  tar xf     "$1" ;;
            *.tar.zst) unzstd     "$1" ;;
        *) echo "'$1' cannot be extracted :^<" && return 1;
        esac
    else
        echo "'$1' is not a valid file :^<" && return 1;
    fi
}

# SQL
export PGDATA="$HOME/postgres_data"
export PGHOST="/tmp"

# Shell startup
[ -d hsh ] && cd hsh
uwufetch

# Temporary function to change as needed
function tmp()
{
    cpp main.cc -Itxx -o preprocessed_main.cc -D_TXX_MAIN -D_TXX_INPUT="bu120"
    sed -i '/^#/d' preprocessed_main.cc
    clang-format -i preprocessed_main.cc

}
. "$HOME/.cargo/env"
