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
# suitable for parsing.
#
# TODO:
# * Add option parsing
# * Add optional key binding dump
# * Add automatic gist creation
function _omz_diagnostic_dump () {
  emulate -L zsh
  local programs program 
  echo oh-my-zsh diagnostic dump

  # Basic system and zsh information
  date
  uname -a
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
  whence bash &>/dev/null && echo "bash: $(bash --version | grep -v Copyright)"
  echo

  # Process state
  echo Process state:
  echo pwd: $PWD
  if whence pstree &>/dev/null; then
    echo Process tree for this shell:
    pstree -p $$
  fi
  #TODO: figure out how to exclude control characters
  set | command grep -a '^\(ZSH\|plugins\|TERM\|LC_\|LANG\|precmd\|chpwd\|preexec\|FPATH\)\|OMZ'
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
}



