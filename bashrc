# # # # # # # # # # # # # #
# .bashrc for Matt  #
# # # # # # # # # # # # # #

# .bashrc is used for interactive login shells
 
# v49 : 2016-10-18 : Copied from v48 and genericized
# v50 : 2016-12-30 : moved hardware determination from titlebar function to bashrc
# v51 : 2016-03-10 : reworked PS1 prompt to include status

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

MY_VER=51
echo "[[ profile/rc v${MY_VER} ]]"

## Removed auto-updating code here, may replace later

# Set Mail dir
MAIL=/usr/mail/${LOGNAME:?}

## Set erase ##
## /bin/stty erase ◘

# set-up environment varibles that make life good
export EXINIT='set ts=4'
export MANPATH=/usr/local/man:/usr/share/man:/usr/man:/usr/java/man
export ARCH=`/bin/uname -m`
export HOST=$(uname -n | cut -d. -f1)
export PAGER='less -s'

###
# Add man paths for optional software if they exist
###
OPT_MAN_PATHS="/opt/VRTS/man /opt/VRTSvlic/man /opt/SUNwconn/man \
  /opt/SUNconn/atm/man /opt/SUNWexplo/man \
  /opt/samba/man \
  /opt/csw/man \
  /usr/sfw/man \
  /opt/sfw/man \
  /opt/openwin/man /usr/cluster/man \
  /opt/SUNWSMS/man /opt/SUNWcstu/man \
  /opt/CollabNet_Subversion/share/man \
  /opt/SUNWscat/man \
  /opt/SUNWvxvm/man \
  /opt/VRTSllt/man \
  /opt/VRTSgab/man"

for OPT_MAN in $OPT_MAN_PATHS; do
  if [[ -d $OPT_MAN ]]; then
    export MANPATH=${MANPATH}:$OPT_MAN
  fi
done

### 
# build the PATH environment
###

## first set-up all the components

# OS Directories
OS_PATH=()
OS_PATH+=('/bin')
OS_PATH+=('/usr/bin')
OS_PATH+=('/usr/sbin')
OS_PATH+=('/sbin')
OS_PATH+=('/usr/ucb')
OS_PATH+=('/usr/ccs/bin')
# Local Directories
LOCAL_PATHS=()
LOCAL_PATHS+=('/lc/bin')              # old loudcloud servers
LOCAL_PATHs+=('/usr/local/bin')       # local binaries
LOCAL_PATHS+=('/usr/local/sbin')      # local system binaries
LOCAL_PATHS+=('/usr/local/sa/bin')    # some servers have this
# Solaris paths
LOCAL_PATHS+=('/usr/sfw/bin')         # sunfreeware.com
LOCAL_PATHS+=('/opt/sfw/bin')         # sunfreeware.com
LOCAL_PATHS+=('/opt/csw/bin')         # OpenCSW Solaris packages
LOCAL_PATHS+=('/opt/SUNWscat/bin')    # Solaris Crash Analysis Tool
LOCAL_PATHS+=('/usr/cluster/bin')     # Sun Cluster
LOCAL_PATHS+=('/opt/SUNWcluster/bin') # Sun Cluster
LOCAL_PATHS+=('/usr/platform/$ARCH/sbin') # Sun System Administration
LOCAL_PATHS+=('/opt/sun/bin')             # Sun System Administration
LOCAL_PATHS+=('/opt/sun/hbatools')        # Sun System Administration
LOCAL_PATHS+=('/opt/SUNWSMS/bin')         # Sun System Controller
LOCAL_PATHS+=('foo')
LOCAL_PATHS+=('foo')
# Utilities
LOCAL_PATHS+=('/opt/samba/bin')           # SAMBA
LOCAL_PATHS+=('/opt/samba/sbin')          # SAMBA
LOCAL_PATHS+=('/etc/emc/bin')             # EMC PowerPath
LOCAL_PATHS+=('/etc/vx/bin')              # Veritas Volume Manager
LOCAL_PATHS+=('/opt/vxva/bin')            # Veritas Volume Manager
LOCAL_PATHS+=('/opt/SUNWvxva/bin')        # Veritas Volume Manager
LOCAL_PATHS+=('/opt/VRTSvcs/bin')         # Veritas Volume Manager
LOCAL_PATHS+=("${HOME}/scripts")          # my scripts
LOCAL_PATHS+=("${HOME}/bin")              # my binaries
LOCAL_PATHS+=('/opt/mysql/bin')           # MySQL
LOCAL_PATHS+=('/cust/IBM/ITM/sol283/is/bin') # ISM6 commands
LOCAL_PATHS+=('/usr/local/scripts/arscli')   # Remedy command-line interface
LOCAL_PATHS+=($(echo -n $(echo $PATH | sed 's/:/\n/g' | grep cygdrive)))
LOCAL_PATHS+=('/opsw/bin')                   # OGFS
LOCAL_PATHS+=('/opt/opsware/vmm-ctl/bin')    # OGFS
LOCAL_PATHS+=('/opt/opsware/ogfsutils/bin')  # OGFS

for PATH_ELEMENT in $FULL_PATH; do
  if [ -d $PATH_ELEMENT ]; then PATH="$PATH:$PATH_ELEMENT"; fi
done
export PATH
hash > /dev/null

###
# Determine hardware info
###
if [[ -f ${HOME}/.hwinfo ]]; then
  . ${HOME}/.hwinfo
else
  # figure out the hardware info and write it to the file
  OS=$(uname)
  case $OS in

    SunOS)  HARDWARE="$(uname -i | cut -d, -f2)"
      RELEASE="$(head -1 /etc/release | awk '{print $3}')"
      [[ $RELEASE = "HW" ]] && RELEASE="$(head -1 /etc/release | awk '{print $4}')"
      OSNAME="$(uname -s -r) ${RELEASE}"
      CPU=$(/usr/sbin/psrinfo | wc -l | awk '{print $1}')
      RAM=$(/usr/sbin/prtconf | grep Mem | awk '{print $3/1024}')
      ;;

    Linux)  # get hardcoded values first if any
      if [[ -f ${HOME}/.hwinfo ]]; then
              . ${HOME}/.hwinfo
      fi
      # dynamically figure out what we have available
      if [[ -f /usr/bin/lshal ]]; then
              HARDWARE=$(/usr/bin/lshal | grep "system.hardware.product" | cut -d"'" -f2)
              CPU=$(grep -c processor /proc/cpuinfo)
              # for RAM, sum MemTotal plus Buffers, then divide out to give GB
              RAM=$(echo "($(grep ^MemTotal: /proc/meminfo|awk '{print $2}')+$(grep ^Buffers: /proc/meminfo|awk '{print $2}'))/1000/1000"| bc)
      elif [[ -f /usr/bin/lshw ]]; then
              HARDWARE=$(/usr/bin/lshw 2> /dev/null | grep "^    prod" | cut -d: -f2 | sed -e 's/^[[:space:]]*//')
              CPU=$(lshw -c cpu 2> /dev/null | fgrep -c '*-cpu:')
              RAM=$(lshw -c memory 2> /dev/null | grep size | cut -d: -f2 | sed -e 's/^[[:space:]]*//')
      fi
      if [[ -f /etc/os-release ]]; then
              OSNAME=$(grep PRETTY_NAME /etc/os-release | cut -d\" -f2)
      elif [[ -f /etc/redhat-release ]]; then
              OSNAME="RHEL $(cat /etc/redhat-release | cut -d\  -f7-)"
      else
              OSNAME="Linux (Unknown)"
      fi
      ;;
    
  esac
  cat <<-EOF >${HOME}/.hwinfo
    HARDWARE="${HARDWARE}"
    CPU="${CPU}"
    RAM="${RAM}"
    OSNAME="${OSNAME}"
EOF
fi  

HOSTNAME="$(uname -n | cut -d. -f1)"

export HARDWARE
export CPU
export RAM
export OSNAME
export HOSTNAME

###
# Configure Shell Functions
###
case $SHELL in
  */ksh)  export FPATH=${FPATH:+"$FPATH:"}$HOME/rc/sh_functions ;;
  */bash) for FUNC in $HOME/rc/sh_functions/*; do
    [[ -f $FUNC ]] && . $FUNC
    done ;;
esac

###
# emulate ksh functions in bash
###
[[ $SHELL == "/bin/bash" ]] && . $HOME/rc/kshenv

###
# find vim, if it's there, let's use it
###
HAVE_VIM=`whence vim`
if [[ -n $HAVE_VIM ]]; then
  alias vi=$HAVE_VIM 
fi

###
# Always use vi as our editor
###
set -o vi
export VISUAL=vi

###
# Set unique history files
###
if [[ ! -d ${HOME}/.history ]]; then
  mkdir ${HOME}/.history
fi
export HISTFILE=${HOME}/.history/hist_$$
export HISTSIZE=512

###
# some evironment variables that I like
###
set ignoreeof      # prevent ^D from logging out
set noclobber      # prevent overwrite of files
set markdirs       # adds "/" to dirs in ls (ksh only?)
set bell-style visible  # Flash instead of beep
unset TMOUT        # prevent autologout
  
###
# colored terminal
###
TERM=xterm-color

###
# Define the shell prompt
###
case $SHELL in
    */bash)
      export PROMPT_COMMAND=bash_prompt_command

      bash_prompt_command () {
        # exit must be first
        local EXIT=$?

        # define colors
        local BLACK="\[\033[0;30m\]"
        local RED="\[\033[0;31m\]"
        local GREEN="\[\033[0;32m\]"
        local YELLOW="\[\033[0;33m\]"
        local BLUE="\[\033[0;34m\]"
        local MAGENTA="\[\033[0;35m\]"
        local CYAN="\[\033[0;36m\]"
        local LIGHTGRAY="\[\033[0;37m\]"
        local DARKGRAY="\[\033[0;90m\]"
        local LIGHTRED="\[\033[0;91m\]"
        local LIGHTGREEN="\[\033[0;92m\]"
        local LIGHTYELLOW="\[\033[0;93m\]"
        local LIGHTBLUE="\[\033[0;94m\]"
        local LIGHTMAGENTA="\[\033[0;95m\]"
        local LIGHTCYAN="\[\033[0;96m\]"
        local WHITE="\[\033[0;97m\]"

        # return color to Terminal setting for text color
        local DEFAULT="\[\033[0;39m\]"

        # set various promt variables
        local TIME="${WHITE}[\t $(date +%Z)]"
        local TITLEBAR='`titlebar`'
        if [[ ${EXIT} -ne 0 ]]; then
          STATUS="${RED}✘"
        else
          STATUS="${GREEN}✔"
        fi
        if [ "`whoami`" = "root" ]; then
          USERCOLOR=${RED}
        else
          USERCOLOR=${BLUE}
        fi
        local USER="${USERCOLOR}\u"
        local HOST="${GREEN}\h$"
        local MYPWD='$(echo -n "${PWD/#$HOME/~}" | awk -F "/" '"'"'{
          if (length($0) > 20) { if (NF>4) print $1 "/" $2 "/.../" $(NF-1) "/" $NF;
          else if (NF>3) print $1 "/" $2 "/.../" $NF;
          else print $1 "/.../" $NF; }
          else print $0;}'"'"')'

        # put it all together
        PS1="${TITLEBAR}"
        PS1+=" ${STATUS}"
        PS1+=" ${TIME}"
        PS1+=" ${DEFAULT}(${USERCOLOR}${USER}${DEFAULT}@${GREEN}${HOST}${DEFAULT})"
        PS1+=":${MYPWD} > "
        export PS1
      }

  esac

###
# set some aliases
###
if [[ -f $HOME/rc/sh_functions/cd2 ]]; then
  [[ $SHELL == "/bin/ksh" ]] && alias cd=cd2
fi

if [[ -f $CSW_PATH/python ]]; then
  alias py=$CSW_PATH/python
fi

if [[ -f /usr/local/bin/vim ]]; then
  alias vi=/usr/local/bin/vim
fi

# ls with filetype marks, and color if available
if [[ -f $HOME/lbin/$ARCH/gls ]]; then
  alias ls="$HOME/lbin/$ARCH/gls -F --color=auto"
else
  alias ls="ls -F"
fi

# less is better than more
if [[ -f /usr/bin/less ]]; then
  alias more=/usr/bin/less
fi

# the "wide" ps
alias wps="/usr/ucb/ps -awwx"

# alais the remedy command line
[[ -f /usr/local/scripts/arscli/emscli ]] && alias remedy=/usr/local/scripts/arscli/emscli

# get rid of any of the local.* that might have been copied during
# account creation
rm -f local.* .kshrc 2> /dev/null

# insure that the .ssh directory is protected
chmod 700 .ssh 2> /dev/null

# hash again to insure any new scripts/binaries are found
hash > /dev/null

echo ''

