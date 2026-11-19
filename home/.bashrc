#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# fastfetch with rotating logo (makima / tomoko / ushanka / zerotwo)
if [ -x "$HOME/.config/fastfetch/rotate.sh" ]; then
    fastfetch() { "$HOME/.config/fastfetch/rotate.sh" "$@"; }
    fastfetch
fi

# Rust/cargo (optional)
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
export PATH="$HOME/.local/bin:$PATH"
