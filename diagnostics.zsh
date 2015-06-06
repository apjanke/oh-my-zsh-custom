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
# This is written in a defensive style so it still works (and can detect) cases when
# basic functionality like echo and which have been redefined. In particular, almost
# everything is invoked with "builtin" or "command", to work in the face of user 
# redefinitions.
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
# * Multi-file capture
# * Add automatic gist uploading
# * Consider whether to move default output file location to TMPDIR. More robust
#     but less user friendly.
#
function omz_diagnostic_dump() {
  emulate -L zsh

  local thisfcn=omz_diagnostic_dump
  local -A opts
  local opt_verbose opt_noverbose opt_outfile
  local timestamp=$(date +%Y%m%d-%H%M%S)
  local outfile=omz_diagdump_$timestamp.txt
  builtin zparseopts -A opts -D -- "v+=opt_verbose" "V+=opt_noverbose"
  local verbose n_verbose=${#opt_verbose} n_noverbose=${#opt_noverbose}
  (( verbose = 1 + n_verbose - n_noverbose ))

  if [[ ${#*} > 0 ]]; then
    opt_outfile=$1
  fi
  if [[ ${#*} > 1 ]]; then
    builtin echo "$thisfcn: error: too many arguments" >&2
    return 1
  fi
  if [[ -n "$opt_outfile" ]]; then
    outfile="$opt_outfile"
  fi

  # Always write directly to a file so terminal escape sequences are
  # captured cleanly
  _omz_diag_dump_one_big_text &> "$outfile"
  if [[ $? != 0 ]]; then
    builtin echo "$thisfcn: error while creating diagnostic dump; see $outfile for details"
  fi

  builtin echo
  builtin echo Diagnostic dump file created at: "$outfile"
  builtin echo
  builtin echo To share this with OMZ developers, post it as a gist on GitHub 
  builtin echo at "https://gist.github.com" and share the link to the gist.
  builtin echo
  builtin echo "WARNING: This dump file contains all your zsh and omz configuration files,"
  builtin echo "so don't share it publicly if there's sensitive information in them."
  builtin echo

}

function _omz_diag_dump_one_big_text() {
  local program programs progfile md5

  builtin echo oh-my-zsh diagnostic dump
  builtin echo

  # Basic system and zsh information
  command date
  command uname -a
  builtin echo OSTYPE=$OSTYPE
  builtin echo ZSH_VERSION=$ZSH_VERSION
  builtin echo User: $USER
  builtin echo

  # Installed programs
  programs=(sh zsh ksh bash sed cat grep ls find git posh)
  for program in $programs; do
    local md5_str="" md5="" link_str="" extra_str=""
    progfile=$(builtin which $program)
    if [[ $? == 0 ]]; then
      if [[ -e $progfile ]]; then
        if builtin whence md5 &>/dev/null; then
          extra_str+=" $(md5 -q $progfile)"
        fi
        if [[ -h "$progfile" ]]; then
          extra_str+=" ( -> ${progfile:A} )"
        fi
      fi
      builtin printf '%-9s %-20s %s\n' "$program is" "$progfile" "$extra_str"
    else
      builtin echo "$program: not found"
    fi
  done
  builtin echo
  builtin echo Command Versions:
  builtin echo "zsh: $(zsh --version)"
  builtin echo "this zsh session: $ZSH_VERSION"
  builtin echo "bash: $(bash --version | command grep bash)"
  builtin echo "git: $(git --version)"
  builtin echo "grep: $(grep --version)"
  builtin echo

  # Core command definitions
  _omz_diag_dump_check_core_commands || return 1
  builtin echo  

  # ZSH Process state
  builtin echo Process state:
  builtin echo pwd: $PWD
  if builtin whence pstree &>/dev/null; then
    builtin echo Process tree for this shell:
    pstree -p $$
  else
    ps -fT
  fi
  builtin set | command grep -a '^\(ZSH\|plugins\|TERM\|LC_\|LANG\|precmd\|chpwd\|preexec\|FPATH\|TTY\|DISPLAY\|PATH\)\|OMZ'
  builtin echo
  #TODO: Should this include `env` instead of or in addition to `export`?
  builtin echo Exported:
  builtin echo $(builtin export | command sed 's/=.*//')
  builtin echo 
  builtin echo Locale:
  command locale
  builtin echo

  # Zsh configuration
  builtin echo Zsh configuration:
  builtin echo setopt: $(builtin setopt)
  builtin echo

  # Oh-my-zsh installation
  builtin echo oh-my-zsh installation:
  command ls -ld ~/.z*
  command ls -ld ~/.oh*
  builtin echo
  builtin echo oh-my-zsh git state:
  (cd $ZSH && builtin echo "HEAD: $(git rev-parse HEAD)" && git remote -v && git status | command grep "[^[:space:]]")
  if [[ $verbose -ge 1 ]]; then
    (cd $ZSH && git reflog --date=default | command grep pull)
  fi
  builtin echo
  if [[ -e $ZSH_CUSTOM ]]; then
    local custom_dir=$ZSH_CUSTOM
    if [[ -h $custom_dir ]]; then
      custom_dir=$(cd $custom_dir && pwd -P)
    fi
    builtin echo "oh-my-zsh custom dir:"
    builtin echo "   $ZSH_CUSTOM ($custom_dir)"
    (cd ${custom_dir:h} && command find ${custom_dir:t} -name .git -prune -o -print)
    builtin echo
  fi

  # Key binding and terminal info
  if [[ $verbose -ge 1 ]]; then
    builtin echo "bindkey:"
    builtin bindkey
    builtin echo
    builtin echo "infocmp:"
    command infocmp
    builtin echo
  fi

  # Configuration file info
  local zdotdir=${ZDOTDIR:-$HOME}
  builtin echo "Zsh configuration files:"
  local cfgfile cfgfiles
  # Some files for bash that zsh does not use are intentionally included
  # to help with diagnosing behavior differences between bash and zsh
  cfgfiles=( /etc/zshenv /etc/zprofile /etc/zshrc /etc/zlogin /etc/zlogout 
    $zdotdir/.zshenv $zdotdir/.zprofile $zdotdir/.zshrc $zdotdir/.zlogin $zdotdir/.zlogout
    ~/.zsh-pre-oh-my-zsh
    /etc/bashrc /etc/profile ~/.bashrc ~/.profile ~/.bash_profile ~/.bash_logout )
  command ls -lad $cfgfiles 2>&1
  builtin echo
  if [[ $verbose -ge 1 ]]; then
    for cfgfile in $cfgfiles; do
      _omz_diag_dump_echo_file_w_header $cfgfile
    done
  fi
  builtin echo
  builtin echo "Zsh compdump files:"
  local dumpfile dumpfiles
  command ls -lad $zdotdir/.zcompdump*
  dumpfiles=( $zdotdir/.zcompdump*(N) )
  if [[ $verbose -ge 2 ]]; then
    for dumpfile in $dumpfiles; do
      _omz_diag_dump_echo_file_w_header $dumpfile
    done
  fi

}

function _omz_diag_dump_check_core_commands() {
  builtin echo "Core command check:"
  local redefined name builtins externals
  redefined=()
  # All the zsh non-module builtin commands
  # These are taken from the zsh reference manual for 5.0.2
  # Commands from modules should not be included.
  # (For back-compatibility, if any of these are newish, they should be removed,
  # or at least made conditional on the version of the current running zsh.)
  # "history" is also excluded because OMZ is known to redefine that
  builtins=( alias autoload bg bindkey break builtin bye cd chdir command
    comparguments compcall compctl compdescribe compfiles compgroups compquote comptags
    comptry compvalues continue declare dirs disable disown echo echotc echoti emulate
    enable eval exec exit export false fc fg float functions getln getopts hash
    integer jobs kill let limit local log logout noglob popd print printf
    pushd pushln pwd r read readonly rehash return sched set setopt shift
    source suspend test times trap true ttyctl type typeset ulimit umask unalias
    unfunction unhash unlimit unset unsetopt vared wait whence where which zcompile
    zle zmodload zparseopts zregexparse zstyle )
  builtins_fatal=( builtin command local )
  externals=( zsh )
  for name in $builtins; do
    if [[ $(builtin whence -w $name) != "$name: builtin" ]]; then
      builtin echo "builtin '$name' has been redefined"
      builtin which $name
      redefined+=$name
    fi
  done
  for name in $externals; do
    if [[ $(builtin whence -w $name) != "$name: command" ]]; then
      builtin echo "command '$name' has been redefined"
      builtin which $name
      redefined+=$name
    fi
  done

  if [[ -n "$redefined" ]]; then
    builtin echo "SOME CORE COMMANDS HAVE BEEN REDEFINED: $redefined"
  else
    builtin echo "All core commands are defined normally"
  fi

}

function _omz_diag_dump_echo_file_w_header() {
  local file=$1
  if [[ ( -f $file || -h $file ) ]]; then
    builtin echo "========== $file =========="
    if [[ -h $file ]]; then
      builtin echo "==========    ( => ${file:A} )   =========="
    fi
    command cat $file
    builtin echo "========== end $file =========="
    builtin echo
  elif [[ -d $file ]]; then
    builtin echo "File '$file' is a directory"
  elif [[ ! -e $file ]]; then
    builtin echo "File '$file' does not exist"
  else
    command ls -lad "$file"
  fi
}


