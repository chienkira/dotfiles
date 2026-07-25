#!/usr/bin/env bash
# Claude Code Status line

input=$(cat)

# ── Colors ──
GREEN="\033[38;2;151;201;195m"
YELLOW="\033[38;2;229;192;123m"
RED="\033[38;2;224;108;117m"
GRAY="\033[38;2;74;88;92m"
CYAN="\033[36m"
RESET="\033[0m"

color_for_pct() {
  local pct=$1
  if (( pct >= 80 )); then
    printf '%s' "$RED"
  elif (( pct >= 50 )); then
    printf '%s' "$YELLOW"
  else
    printf '%s' "$GREEN"
  fi
}

# Session info
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
dir=$(echo "$input" | jq -r '.workspace.current_dir')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // "0"')
output_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // "0"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // ""')

# Context percentage (integer)
ctx_pct=0
if [ -n "$used_pct" ]; then
  printf -v ctx_pct "%.0f" "$used_pct" 2>/dev/null || ctx_pct="${used_pct%%.*}"
fi
ctx_color=$(color_for_pct "$ctx_pct")

# Cost in USD
cost=$(printf '$%.1f' "$cost_usd")

# Git branch
git_branch=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# Output
sep="${GRAY} │ ${RESET}"

output="${CYAN}${dir##*/}"
if [ -n "$git_branch" ]; then
  output+="${sep}🌿 ${git_branch}"
fi
output+="${sep}🧠 ${model} ${ctx_color}${ctx_pct}% used"
output+="${sep}💰 ${cost} ${input_tokens}/${output_tokens} tokens"
printf '%b' "$output"
