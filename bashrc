# # # # # # # # # # # # # #
# .bashrc for Matt  #
# # # # # # # # # # # # # #

# .bashrc is used for interactive login shells
 
# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

# Source files from $home/rc.d in order
# this allows more granular customization of the environment

for RCFILE in $(ls ${HOME}/bash.d/rc[0-9][0-9]_*) ; do
  source ${RCFILE}
done

###
# Configure Shell Functions
###
for FUNC in $(ls ${HOME}/bash.d/f_*) ; do
  source ${FUNC}
done

## use liquidprompt if installed
if [[ -d ${HOME}/git/liquidprompt ]]; then
  source ${HOME}/git/liquidprompt/liquidprompt
else
  export PROMPT_COMMAND=bash_prompt_command
fi

# hash to insure any new scripts/binaries are found
hash > /dev/null

echo ''