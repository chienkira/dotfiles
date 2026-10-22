# Env
export LANG="${LANG:-en_US.UTF-8}"

# Alias
alias ll='ls -lh'
alias la='ls -lAh'

# ZSH plugins
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# My favorite shell prompt (starship style)
autoload -Uz add-zsh-hook  # register hooks without overwriting precmd()/preexec()
zmodload zsh/datetime      # provides $EPOCHREALTIME (current time, sub-second precision)
# ex: " ⑂ develop" (or short commit hash on detached HEAD). Empty outside a git repo.
function prompt-git-branch {
  local ref
  ref=$(git symbolic-ref --short HEAD 2>/dev/null) \
    || ref=$(git rev-parse --short HEAD 2>/dev/null) \
    || return
  ref=${ref//\%/%%}  # % is special in prompts; escape it so "fix-100%" displays correctly
  echo " %F{magenta}⑂ ${ref}%f"
}
# " ◷ 1m 5s" for the last command. Empty if it took < 1s or no command was run.
function format-duration {
  local total_seconds=$1
  local minutes=$(( total_seconds / 60 ))
  local seconds=$(( total_seconds % 60 ))
  if (( minutes > 0 )); then
    echo "${minutes}m ${seconds}s"
  else
    echo "${seconds}s"
  fi
}
function prompt-command-duration {
  [[ -z $PROMPT_COMMAND_START_TIME ]] && return
  local -i elapsed=$(( EPOCHREALTIME - PROMPT_COMMAND_START_TIME ))  # -i truncates to whole seconds
  (( elapsed < 1 )) && return
  echo " %F{yellow}◷ $(format-duration $elapsed)%f"
}
function build-prompt {
  local status_dot='%(?.%F{green}.%F{red})●%f'
  local user='%F{yellow}%n%f'
  local directory='%B%F{cyan}%~%f%b'  # %~ = current dir with $HOME shown as ~
  local prompt_char='%F{247}❯%f'

  local first_line="${status_dot} ${user} ${directory}$(prompt-git-branch)$(prompt-command-duration)"
  local second_line="${prompt_char} "
  echo "${first_line}\n${second_line}"
}
function on-command-start {
  PROMPT_COMMAND_START_TIME=$EPOCHREALTIME
}
add-zsh-hook preexec on-command-start
function on-prompt-display {
  PROMPT=$(build-prompt)
  unset PROMPT_COMMAND_START_TIME  # so an empty Enter doesn't show the previous duration again

  # Blank line between commands, but not above the very first prompt of the session
  if [[ -n $PROMPT_HAS_DISPLAYED_ONCE ]]; then
    echo
  fi
  PROMPT_HAS_DISPLAYED_ONCE=1
}
add-zsh-hook precmd on-prompt-display
