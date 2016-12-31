# # # # # # # # # # # # # #
# .bashrc for Matt  #
# # # # # # # # # # # # # #

# .bashrc is used for interactive login shells
 
# v49 : 2016-10-18 : Copied from v48 and genericized
# v50 : 2016-12-30 : moved hardware determination from titlebar function to bashrc

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

MY_VER=50
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
      TITLEBAR="\`titlebar\`" ## this runs the function but doesn't change the prompt
      SMILEY="\`if [ \$? = 0 ]; then echo \[\e[33m\]^_^\[\e[0m\]; else echo \[\e[31m\]O_O\[\e[0m\]; fi\`"
      TIME="\[\e[1;37m\][\t $(date +%Z)]"
      USER="\[\e[0;35m\]\u\[\e[0m\]@\[\e[0;32m\]\h\[\e[0m\]"
      MYPWD="\W"
#       PROMPT_COMMAND='MYPWD=$(echo -n "${PWD/#$HOME/~}" | awk -F "/" '"'"'{
# if (length($0) > 14) { if (NF>4) print $1 "/" $2 "/.../" $(NF-1) "/" $NF;
# else if (NF>3) print $1 "/" $2 "/.../" $NF;
# else print $1 "/.../" $NF; }
# else print $0;}'"'"')'
      PS1="${TITLEBAR}${SMILEY}${TIME}${USER}:${MYPWD} > "
      #PS1="$(color bold,gray,black)[\t $(date +%Z)]$(color normal,purple,black)\u$(color)@$(color normal,green,black)\h$(color):${CURDIR} > "
      ;;
    */ksh)
      . $HOME/rc/sh_functions/cd2 # this will define CURDIR
      CURDIR=$PWD
      typeset -RZ2 _x1 _x2 _x3
      let SECONDS=$(date '+3600*%H+60*%M+%S')
      _s='(_x1=(SECONDS/3600)%24)==(_x2=(SECONDS/60)%60)==(_x3=SECONDS%60)'
      TIME='"${_d[_s]}$_x1:$_x2:$_x3"'
      #PS1="[$TIME]$(logname)@${HOST}:\${CURDIR} > "
      PS1="$(color bold,gray,black)[$TIME]$(color normal,purple,black)$(logname)$(color)@$(color normal,green,black)${HOST}$(color):\${CURDIR} > "
      #PS1="$(color bold,gray,black)[$TIME]$(color normal,purple,black)$(logname)$(color)@$(color normal,green,black)${HOST}$(color):\${PWD} > "
      ;;
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

