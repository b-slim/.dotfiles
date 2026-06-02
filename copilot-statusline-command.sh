#!/bin/bash

# Copilot CLI status line, inspired by ~/.dotfiles/statusline-command.sh (Claude).
#
# Copilot CLI sends a JSON object on stdin with (subset of) fields:
#   .cwd, .workspace.current_dir, .session_id, .session_name, .username, .version
#   .model.{id,display_name}
#   .context_window.{total_input_tokens,total_output_tokens,context_window_size,
#                    used_percentage,remaining_tokens,current_context_tokens,
#                    displayed_context_limit,current_context_used_percentage,...}
#   .cost.{total_lines_added,total_lines_removed,total_duration_ms,
#          total_api_duration_ms,total_premium_requests}
#   .ai_used.{total_nano_aiu,formatted}
#   .remote.{connected,indicator,task_name,...}
#
# Unlike Claude (which bills per-token), Copilot bills via "premium requests"
# and AIU, so we display those instead of a dollar-cost estimate.

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
model_id=$(echo "$input" | jq -r '.model.id // ""')
session_name=$(echo "$input" | jq -r '.session_name // empty')
remote_connected=$(echo "$input" | jq -r '.remote.connected // false')
remote_indicator=$(echo "$input" | jq -r '.remote.indicator // empty')
remote_task=$(echo "$input" | jq -r '.remote.task_name // empty')

# Context-window usage. Prefer the "current" (post-compaction) numbers when
# present, since they are what the user actually sees in /context.
current_ctx_tokens=$(echo "$input" | jq -r '.context_window.current_context_tokens // empty')
displayed_ctx_limit=$(echo "$input" | jq -r '.context_window.displayed_context_limit // empty')
current_ctx_pct=$(echo "$input" | jq -r '.context_window.current_context_used_percentage // empty')

total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

if [ -n "$current_ctx_tokens" ] && [ -n "$current_ctx_pct" ]; then
  token_total="$current_ctx_tokens"
  pct_value="$current_ctx_pct"
elif [ -n "$used_pct" ]; then
  token_total=$((total_input + total_output))
  pct_value="$used_pct"
elif [ "$context_size" -gt 0 ] 2>/dev/null; then
  token_total=$((total_input + total_output))
  pct_value=$(echo "scale=1; $token_total * 100 / $context_size" | bc)
else
  token_total=$((total_input + total_output))
  pct_value=""
fi

# Cost / usage metrics from Copilot.
premium_requests=$(echo "$input" | jq -r '.cost.total_premium_requests // 0')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
aiu_formatted=$(echo "$input" | jq -r '.ai_used.formatted // empty')

# Directory name (like %c in zsh).
dir_name=$(basename "$cwd")

# Robbyrussell-inspired prompt: green arrow + cyan dir.
status=$(printf "\033[1;32m➜\033[0m  \033[36m%s\033[0m" "$dir_name")

# Git branch + dirty marker.
if [ -d "$cwd/.git" ]; then
  branch=$(cd "$cwd" && git symbolic-ref --short HEAD 2>/dev/null \
                       || git rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    if cd "$cwd" && ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
      status=$(printf "%s  \033[1;34mgit:(\033[31m%s\033[34m)\033[0m \033[33m✗\033[0m" "$status" "$branch")
    else
      status=$(printf "%s  \033[1;34mgit:(\033[31m%s\033[34m)\033[0m" "$status" "$branch")
    fi
  fi
fi

# Context window usage.
if [ -n "$pct_value" ]; then
  if [ "$token_total" -ge 1000 ] 2>/dev/null; then
    token_display=$(printf "%.1fK" "$(echo "scale=1; $token_total / 1000" | bc)")
  else
    token_display="${token_total}"
  fi

  pct_int=${pct_value%.*}
  [ -z "$pct_int" ] && pct_int=0

  if [ "$pct_int" -ge 80 ] 2>/dev/null; then
    color="\033[31m"   # red
  elif [ "$pct_int" -ge 50 ] 2>/dev/null; then
    color="\033[33m"   # yellow
  else
    color="\033[32m"   # green
  fi
  status=$(printf "%s  ${color}%s tokens (%s%% used)\033[0m" "$status" "$token_display" "$pct_int")
fi

# Code changes this session.
if [ "$lines_added" -gt 0 ] 2>/dev/null || [ "$lines_removed" -gt 0 ] 2>/dev/null; then
  status=$(printf "%s  \033[32m+%s\033[0m/\033[31m-%s\033[0m" "$status" "$lines_added" "$lines_removed")
fi

# Premium request count + AIU (Copilot's billing units).
if [ -n "$aiu_formatted" ] && [ "$aiu_formatted" != "null" ]; then
  status=$(printf "%s  \033[35m%s AIU\033[0m" "$status" "$aiu_formatted")
fi
if [ "$(echo "$premium_requests > 0" | bc -l 2>/dev/null)" = "1" ]; then
  pr_display=$(printf "%.2f" "$premium_requests")
  status=$(printf "%s  \033[35m%s req\033[0m" "$status" "$pr_display")
fi

# Model.
if [ -n "$model" ]; then
  status=$(printf "%s  \033[2m[%s]\033[0m" "$status" "$model")
fi

# Remote / session indicators.
if [ "$remote_connected" = "true" ]; then
  label="${remote_task:-remote}"
  status=$(printf "%s  \033[36m%s %s\033[0m" "$status" "${remote_indicator:-☁}" "$label")
fi
if [ -n "$session_name" ]; then
  status=$(printf "%s  \033[2m⚡%s\033[0m" "$status" "$session_name")
fi

shortcuts=$(printf "\033[2m^R search · ^W del word · ^U del start · ^K del end · ^G \$EDITOR · ^L clear · shift+tab modes\033[0m")

printf "%s\n%s\n" "$status" "$shortcuts"
