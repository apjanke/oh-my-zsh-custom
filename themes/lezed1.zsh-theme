# Theme lezed1
#
# From http://paste.ubuntu.com/10347952/
#
# This is a test case for this bug: https://github.com/robbyrussell/oh-my-zsh/issues/3396

grey='\e[0;90m'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$grey%}("
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$grey%}) %{$fg[yellow]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$grey%})"

function lezed1_prompt {
  (( spare_width = ${COLUMNS} ))
  prompt=" "

  branch=$(current_branch)
  ruby_version=$(rvm_prompt_info || rbenv_prompt_info)
  path_size=${#PWD}
  branch_size=${#branch}
  ruby_size=${#ruby_version}
  user_machine_size=${#${(%):-%n@%m:-}}
  
  if [[ ${#branch} -eq 0 ]]
    then (( ruby_size = ruby_size + 1 ))
  else
    (( branch_size = branch_size + 4 ))
    if [[ -n $(git status -s 2> /dev/null) ]]; then
      (( branch_size = branch_size + 2 ))
    fi
  fi
  
  (( spare_width = ${spare_width} - (${user_machine_size} + ${path_size} + ${branch_size} + ${ruby_size}) ))

  while [ ${#prompt} -lt $spare_width ]; do
    prompt=" $prompt"
  done
  
  prompt="%{%F{green}%}$PWD$prompt%{%F{red}%}$ruby_version %{$reset_color%}$(current_branch)"
  
  echo $prompt
}

setopt prompt_subst

PROMPT='%K{magenta}$fg_bold[yellow]%n@%m%{$reset_color%}: $(lezed1_prompt)
%(?,%{%F{green}%},%{%F{red}%})█▌%{$reset_color%}'