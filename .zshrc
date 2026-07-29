# Env
export LANG="${LANG:-en_US.UTF-8}"

# Alias
alias ll='ls -lh'
alias la='ls -lAh'

# ZSH plugins
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# My pretty prompt (Starship style)
function git-prompt {
  local ref
  ref=$(git symbolic-ref --short HEAD 2>/dev/null) \
    || ref=$(git rev-parse --short HEAD 2>/dev/null) \
    || return
  echo " %F{247}on %F{magenta}⑂ ${ref}%f"
}
function left-prompt {
  local prompt_char='%(?.%F{green}.%F{red})❯%f'
  echo "%B%F{cyan}%~%f%b$(git-prompt)
${prompt_char} "
}
function precmd() {
  PROMPT=$(left-prompt)
  if [ -z "$NEW_LINE_BEFORE_PROMPT" ]; then
    NEW_LINE_BEFORE_PROMPT=1
  elif [ "$NEW_LINE_BEFORE_PROMPT" -eq 1 ]; then
    echo ""
  fi
}
