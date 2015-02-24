# diagnostics.zsh
#
# Diagnostic and debugging support for oh-my-zsh

# omz_diagnostic_dump()
#
# Outputs a bunch of information about the state and configuration of
# oh-my-zsh, zsh, and the user's system. This is intended to provide a
# bunch of context for diagnosing your own or a third party's problems, and to
# be suitable for posting to public bug reports.
#
# The output is human-readable and its format may change over time. It is not
# suitable for parsing. All the output is in one single file so it can be posted
# as a gist or bug comment on GitHub. GitHub doesn't support attaching tarballs
# or other files to bugs; otherwise, this would probably have an option to produce
# tarballs that contain copies of the config and customization files instead of
# catting them all in to one file.
#
# This is intended to be widely portable, and run anywhere that oh-my-zsh does.
# Feel free to report any portability issues as bugs.
#
# The verbosity level is controlled by the -v option, which increases verbosity
# by 1 each time it is specified. Verbosity levels:
#   0 (default) - basic info, shell state, omz configuration, git state
#   1 - Adds key binding info and configuration file contents
#
# TODO:
# * Add automatic gist uploading
# * Handle terminal control sequences in variables
function omz_diagnostic_dump () {
  emulate -L zsh
  local programs program 

  local opt_verbose opts
  zparseopts -A opts -D "v+=opt_verbose"
  local verbose=${#opt_verbose}

  echo oh-my-zsh diagnostic dump
  echo
  
  # Basic system and zsh information
  date
  uname -a
  echo OSTYPE=$OSTYPE
  zsh --version
  echo User: $USER
  echo

  # Installed programs
  programs=(zsh bash sed cat grep find git)
  for program in $programs; do
    echo "$program is $(which $program)"
  done
  echo Versions:
  echo "git: $(git --version)"
  whence bash &>/dev/null && echo "bash: $(bash --version | grep bash)"
  echo

  # Process state
  echo Process state:
  echo pwd: $PWD
  if whence pstree &>/dev/null; then
    echo Process tree for this shell:
    pstree -p $$
  fi
  #TODO: figure out how to exclude or translate terminal control characters
  set | command grep -a '^\(ZSH\|plugins\|TERM\|LC_\|LANG\|precmd\|chpwd\|preexec\|FPATH\|TTY\|DISPLAY\|PATH\)\|OMZ'
  echo -n $reset_color
  echo 

  # Zsh configuration
  echo Zsh configuration:
  echo setopt: $(setopt)
  echo

  # Oh-my-zsh installation
  echo oh-my-zsh installation:
  # Use cat to disable colorization
  command ls -ld ~/.z* | cat
  command ls -ld ~/.oh* | cat
  echo
  echo oh-my-zsh git state:
  (cd $ZSH && echo "HEAD: $(git rev-parse HEAD)" && git remote -v && git status | command grep "[^[:space:]]")
  echo
  if [[ -e $ZSH_CUSTOM ]]; then
    local custom_dir=$ZSH_CUSTOM
    if [[ -h $custom_dir ]]; then
      custom_dir=$(cd $custom_dir && pwd -P)
    fi
    echo "oh-my-zsh custom dir:"
    echo "   $ZSH_CUSTOM ($custom_dir)"
    (cd ${custom_dir:h} && find ${custom_dir:t} -name .git -prune -o -print)
  fi

  # Key binding and terminal info
  if [[ $verbose -ge 1 ]]; then
    echo "bindkey:"
    bindkey
    echo
    echo "infocmp:"
    infocmp
    echo
  fi

  # Full configuration file info
  if [[ $verbose -ge 1 ]]; then
    local cfgfile cfgfiles
    local zdotdir=${ZDOTDIR:-$HOME}
    echo "Zsh configuration files:"
    cfgfiles=( /etc/zshenv /etc/zprofile /etc/zshrc /etc/zlogin /etc/zlogout $zdotdir/.zshenv $zdotdir/.zprofile $zdotdir/.zshrc $zdotdir/.zlogin $zdotdir/.zlogout )
    for cfgfile in $cfgfiles; do
      if [[ ( -f $cfgfile || -h $cfgfile ) ]]; then
        echo $cfgfile
        if [[ -h $cfgfile ]]; then
          echo "    ( => ${cfgfile:A} )"
        fi
        echo "=================================================="
        cat $cfgfile
        echo
        echo
      fi
    done
  fi
}



