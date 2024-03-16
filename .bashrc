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

# nix
alias nr='nix run'
alias nb='nix build'
function nbpf()
{
    echo "nix" "build" ".#workflows.x86_64-linux.$1.documents.provided_files"
    "nix" "build" ".#workflows.x86_64-linux.$1.documents.provided_files"
}
alias nrcs='nix run .#check-student'
alias nrcw='nix run .#check-workflow'
alias nrcwa='nix run .#check-workflow adapter address_book bimap builder cartesian_vector caste_or_cast chain_of_responsibility closer_to cmake color_manipulator compile_list const directories_infos do_not_loop doubly_linked_list exception exist_functor for_each forward_multiplication game_theory hello_world hot_potato implements int_container is_numerical is_prime lookup_table merge_sort my_nfts parse_csv path ref_swap replace safe_int singleton smtptr stdin_to_file unordered_multimap visitor war word_checker palindrome_vector constexpr_factorial equal_pairs make_cleanup rational template_method simple_display copy_constructor swap_template'
alias nbep='nix build .#exo-pdf'

# git
alias gita='git add -A && git status'
alias gitt='git tag -a -m msg'
alias gitpt='git push --tags'
alias gitpall='git push --follow-tags'
function gitc()
{
    msg=""
    for w in "$@"
    do
        msg="$msg $w"
    done
    git commit -m "$msg"
}
alias gitpom='git push origin main'
alias gitf='git add -A && git commit -m "used urgent push alias" && git push'
alias gits='git status'
alias ga='git add'
alias gr='git rm'
alias gitrom='git rebase origin/main'
alias gitromours='git rebase origin/main -X ours'
alias gitromtheirs='git rebase origin/main -X theirs'
alias gitrc='git rebase --continue; git status'
function gitrco()
{
    git checkout --ours $@
    git add $@
}
function gitrct()
{
    git checkout --theirs $@
    git add $@
}
# alias gitrco='git checkout --ours'
# alias gitrct='git checkout --theirs'

# epita
alias extar='mv ~/Downloads/*.tar . && ex *.tar && rm *.tar'
alias lgcc='gcc -o main -std=c99 -pedantic -Werror -Wall -Wextra -Wvla'
alias cfc='clang-format -i *.c *.h *.cxx **/*.c **/*.h **/*.cxx'
alias lcgpp='clang++ -o main -std=c++20 -pedantic -Werror -Wall -Wextra -Wvla -Wold-style-cast'
alias lgpp='g++ -o main -std=c++20 -pedantic -Werror -Wall -Wextra -Wvla -Wold-style-cast'
alias cfcpp='clang-format -i *.cc *.hh *.hxx **/*.cc **/*.hh **/*.hxx'

# general purpose
alias du='du -h'
alias please='sudo !!'
alias reboot='shutdown -r now'
alias shutdown='shutdown now'
alias mkdir='mkdir -pv'
function mkdircd()
{
    mkdir -pv $1 && cd $1
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
alias perg='grep -vi --color=always'
alias cp='cp -ri'
alias mv='mv -i'
alias df='df -h'
alias tree='tree -C'
alias treea='tree -AC'
alias clr='clear && uwufetch && ls -hN'
alias echo='echo -e'

# Pacman
alias spacman='sudo pacman'
alias spacmans='sudo pacman -S --noconfirm'
alias pacsyu='sudo pacman -Syy --noconfirm archlinux-keyring; paru -Syu --noconfirm'
alias spacmanr='sudo pacman -Rsn'
alias pacsearch='pacman -Ss'

function ex()
{
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2) tar xjf    $1 ;;
            *.tar.gz)  tar xzf    $1 ;;
            *.bz2)     bunzip2    $1 ;;
            *.rar)     unrar x    $1 ;;
            *.gz)      gunzip     $1 ;;
            *.tar)     tar xf     $1 ;;
            *.tbz2)    tar xjf    $1 ;;
            *.tgz)     tar xzf    $1 ;;
            *.zip)     unzip      $1 ;;
            *.Z)       uncompress $1 ;;
            *.7z)      7z x       $1 ;;
            *.deb)     ar x       $1 ;;
            *.tar.xz)  tar xf     $1 ;;
            *.tar.zst) unzstd     $1 ;;
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
cd hsh
uwufetch
# eval $(ssh-agent -s) > /dev/null && ssh-add ~/.ssh/fwaliarchlap

# Temporary function to change as needed
function tmp()
{
    for i in *
    do
        cp "$i/student.pdf" "$i.pdf"
        rm "$i"
    done
}



