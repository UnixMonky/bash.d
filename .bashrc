# # # # # # # # # # # # # #
# .bashrc for Matt  #
# # # # # # # # # # # # # #

# .bashrc is used for interactive login shells
 
# v49 : 2016-10-18 : Copied from v48 and genericized
# v50 : 2016-12-30 : moved hardware determination from titlebar function to bashrc
# v51 : 2016-03-10 : reworked PS1 prompt to include status
# v52 : 2017-03-14 : Massive rewrite to use rc.d for granular control.

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

MY_VER=52
echo "[[ .bashrc v${MY_VER} ]]"

## Removed auto-updating code here, may replace later

# Source files from $home/rc.d in order
# this allows more granular customization of the environment

for RCFILE in $(ls ${HOME}/rc.d/rc[0-9][0-9]_*) ; do
  source ${RCFILE}
done

###
# Configure Shell Functions
###
for FUNC in $(ls ${HOME}/rc.d/f_*) ; do
  source ${FUNC}
done

export PROMPT_COMMAND=bash_prompt_command

# hash to insure any new scripts/binaries are found
hash > /dev/null

echo ''