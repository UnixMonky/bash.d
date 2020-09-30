# # # # # # # # # # # # # #
# .bash_profile for Matt  #
# # # # # # # # # # # # # #

# .bash_profile is used for non-interactive login shells
# v51 : 2017-03-13 : Added call to bashrc

if [ -f ~/.bashrc ]; then
   . ~/.bashrc
fi

if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
	exec startx
fi
