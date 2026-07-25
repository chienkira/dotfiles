# Env
export LANG="${LANG:-en_US.UTF-8}"

# Alias
alias ll='ls -lh'
alias la='ls -lAh'

# ZSH plugins
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Direnv
eval "$(direnv hook zsh)"

# My pretty prompt 
# Git ブランチ用のセグメント（powerline スタイル）を返す
function git-prompt {
  local text_color='%{\e[38;5;'    # 文字色
  local back_color='%{\e[30;48;5;' # 背景色
  local reset='%{\e[0m%}'          # リセット
  local sharp=''             # 三角形
  local branch=''            # ブランチ記号
  local path_b='031m%}'            # 直前（パス）の背景色
  local git_b='064m%}'             # git セグメントの背景色
  local git_t='000m%}'             # git セグメントの文字色

  # 現在のブランチ名（detached の場合は短縮ハッシュ）を取得
  local ref
  ref=$(git symbolic-ref --short HEAD 2>/dev/null) \
    || ref=$(git rev-parse --short HEAD 2>/dev/null) \
    || {
      # git 管理下でなければ通常の閉じ三角形のみ
      echo "${reset}${text_color}${path_b}${sharp}${reset}"
      return
    }
  # パス背景 → git 背景への遷移三角形 + ブランチ名 + 閉じ三角形
  echo "${back_color}${git_b}${text_color}${path_b}${sharp}${back_color}${git_b}${text_color}${git_t} ${branch} ${ref} ${reset}${text_color}${git_b}${sharp}${reset}"
}
function left-prompt {
  name_t='179m%}'    # user name text color
  name_b='000m%}'    # user name background color
  path_t='255m%}'    # path text color
  path_b='031m%}'    # path background color
  arrow='087m%}'     # arrow color
  text_color='%{\e[38;5;'    # set text color
  back_color='%{\e[30;48;5;' # set background color
  reset='%{\e[0m%}'  # reset
  sharp='\uE0B0'     # triangle

  user="${back_color}${name_b}${text_color}${name_t}"
  dir="${back_color}${path_b}${text_color}${path_t}"
  echo "${dir}%~$(git-prompt)\n${text_color}${arrow}→ ${reset}"
}
function precmd() {
  # 毎回プロンプトを再構築し、カレントディレクトリの git ブランチを反映する
  PROMPT=$(left-prompt)
  # Print a newline before the prompt, unless it's the
  # first prompt in the process.
  if [ -z "$NEW_LINE_BEFORE_PROMPT" ]; then
    NEW_LINE_BEFORE_PROMPT=1
  elif [ "$NEW_LINE_BEFORE_PROMPT" -eq 1 ]; then
    echo ""
  fi
}
