# diagnostics.zsh
#
# Diagnostic and debugging support for oh-my-zsh

# omz_diagnostic_dump()
#
# Author: Andrew Janke <andrew@apjanke.net>
#
# Usage:
#
# omz_diagnostic_dump [-v] [-V] [file]
#
# NOTE: This is a work in progress. Its interface and behavior are going to change,
# and probably in non-back-compatible ways.
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
# OPTIONS
#
# [file]   Specifies the output file. If not given, a file in the current directory
#        is selected automatically.
#
# -v    Increase the verbosity of the dump output. May be specified multiple times.
#       Verbosity levels:
#        0 - Basic info, shell state, omz configuration, git state
#        1 - (default) Adds key binding info and configuration file contents
#        2 - Adds zcompdump file contents
#
# -V    Reduce the verbosity of the dump output. May be specified multiple times.
#
# TODO:
# * Add automatic gist uploading
# * Consider whether to move default output file location to TMPDIR. More robust
#     but less user friendly.
#
function omz_diagnostic_dump () {
  emulate -L zsh

  local -A opts
  local opt_verbose opt_noverbose opt_outfile
  local timestamp=$(date +%Y%m%d-%H%M%S)
  local outfile=omz_diagdump_$timestamp.txt
  zparseopts -A opts -D -- "v+=opt_verbose" "V+=opt_noverbose"
  local verbose n_verbose=${#opt_verbose} n_noverbose=${#opt_noverbose}
  (( verbose = 1 + n_verbose - n_noverbose ))

  if [[ ${#*} > 0 ]]; then
    opt_outfile=$1
  fi
  if [[ -n "$opt_outfile" ]]; then
    outfile="$opt_outfile"
  fi

  # Always write directly to a file so terminal escape sequences are
  # captured cleanly
  _omz_diagnostic_dump_one_big_text > "$outfile"

  echo
  echo Diagnostic dump file created at: "$outfile"
  echo
  echo To share this with OMZ developers, post it as a Gist on GitHub and 
  echo share the link to the gist.
  echo
  echo WARNING: This dump file contains all your zsh and omz configuration files,
  echo "so don't share it publicly if there's sensitive information in them."
  echo
}

function _omz_diagnostic_dump_one_big_text {
  local program programs progfile md5

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
  programs=(sh zsh ksh bash sed cat grep find git posh)
  for program in $programs; do
    local md5_str="" md5="" link_str="" extra_str=""
    progfile=$(which $program)
    if [[ $? == 0 ]]; then
      if [[ -e $progfile ]]; then
        if whence md5 &>/dev/null; then
          extra_str+=" $(md5 -q $progfile)"
        fi
        if [[ -h "$progfile" ]]; then
          extra_str+=" ( -> ${file:A} )"
        fi
      fi
      printf '%-9s %-20s %s\n' "$program is" "$progfile" "$extra_str"
    else
      echo "$program: not found"
    fi
  done
  echo
  echo Versions:
  whence zsh >&/dev/null && echo "zsh: $(zsh --version)"
  whence bash &>/dev/null && echo "bash: $(bash --version | command grep bash)"
  echo "git: $(git --version)"
  echo "grep: $(grep --version)"
  echo

  # ZSH Process state
  echo Process state:
  echo pwd: $PWD
  if whence pstree &>/dev/null; then
    echo Process tree for this shell:
    pstree -p $$
  else
    ps -fT
  fi
  set | command grep -a '^\(ZSH\|plugins\|TERM\|LC_\|LANG\|precmd\|chpwd\|preexec\|FPATH\|TTY\|DISPLAY\|PATH\)\|OMZ'
  echo
  #TODO: Should this include `env` instead of or in addition to `export`?
  echo Exported:
  echo $(export | sed 's/=.*//')
  echo 
  echo Locale:
  command locale
  echo

  # Zsh configuration
  echo Zsh configuration:
  echo setopt: $(setopt)
  echo

  # Oh-my-zsh installation
  echo oh-my-zsh installation:
  command ls -ld ~/.z*
  command ls -ld ~/.oh*
  echo
  echo oh-my-zsh git state:
  (cd $ZSH && echo "HEAD: $(git rev-parse HEAD)" && git remote -v && git status | command grep "[^[:space:]]")
  if [[ $verbose -ge 1 ]]; then
    (cd $ZSH && git reflog --date=default | command grep pull)
  fi
  echo
  if [[ -e $ZSH_CUSTOM ]]; then
    local custom_dir=$ZSH_CUSTOM
    if [[ -h $custom_dir ]]; then
      custom_dir=$(cd $custom_dir && pwd -P)
    fi
    echo "oh-my-zsh custom dir:"
    echo "   $ZSH_CUSTOM ($custom_dir)"
    (cd ${custom_dir:h} && find ${custom_dir:t} -name .git -prune -o -print)
    echo
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

  # Configuration file info
  local zdotdir=${ZDOTDIR:-$HOME}
  echo "Zsh configuration files:"
  local cfgfile cfgfiles
  cfgfiles=( /etc/zshenv /etc/zprofile /etc/zshrc /etc/zlogin /etc/zlogout 
    $zdotdir/.zshenv $zdotdir/.zprofile $zdotdir/.zshrc $zdotdir/.zlogin $zdotdir/.zlogout )
  command ls -lad $cfgfiles 2>&1
  echo
  if [[ $verbose -ge 1 ]]; then
    for cfgfile in $cfgfiles; do
      _omz_diagnostic_dump_echo_file_w_header $cfgfile
    done
  fi
  echo "Zsh compdump files:"
  local dumpfile dumpfiles
  command ls -lad $zdotdir/.zcompdump*
  dumpfiles=( $zdotdir/.zcompdump*(N) )
  if [[ $verbose -ge 2 ]]; then
    for dumpfile in $dumpfiles; do
      _omz_diagnostic_dump_echo_file_w_header $dumpfile
    done
  fi

}

function _omz_diagnostic_dump_echo_file_w_header () {
  local file=$1
  if [[ ( -f $file || -h $file ) ]]; then
    echo "========== $file =========="
    if [[ -h $file ]]; then
      echo "==========    ( => ${file:A} )   =========="
    fi
    command cat $file
    echo "========== end $file =========="
    echo
  fi
}



