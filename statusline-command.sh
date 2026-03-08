#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract values
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
agent=$(echo "$input" | jq -r '.agent.name // empty')

# Extract token usage information
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# If used_percentage is not provided, compute it from raw token counts
if [ -z "$used_pct" ] && [ "$context_size" -gt 0 ] 2>/dev/null; then
  total_tokens_for_pct=$((total_input + total_output))
  used_pct=$(echo "scale=1; $total_tokens_for_pct * 100 / $context_size" | bc)
fi

# Extract model ID for pricing
model_id=$(echo "$input" | jq -r '.model.id')

# Calculate cost based on model pricing (prices per million tokens)
# Source: Anthropic pricing as of January 2025
case "$model_id" in
  *"claude-opus-4"*)
    input_price_per_mtok=15.00
    output_price_per_mtok=75.00
    cache_write_price_per_mtok=18.75
    cache_read_price_per_mtok=1.50
    ;;
  *"claude-sonnet-4"*)
    input_price_per_mtok=3.00
    output_price_per_mtok=15.00
    cache_write_price_per_mtok=3.75
    cache_read_price_per_mtok=0.30
    ;;
  *"claude-3-5-sonnet"*)
    input_price_per_mtok=3.00
    output_price_per_mtok=15.00
    cache_write_price_per_mtok=3.75
    cache_read_price_per_mtok=0.30
    ;;
  *"claude-3-5-haiku"*)
    input_price_per_mtok=0.80
    output_price_per_mtok=4.00
    cache_write_price_per_mtok=1.00
    cache_read_price_per_mtok=0.08
    ;;
  *"haiku"*)
    input_price_per_mtok=0.25
    output_price_per_mtok=1.25
    cache_write_price_per_mtok=0.30
    cache_read_price_per_mtok=0.03
    ;;
  *)
    # Default to Sonnet pricing if unknown
    input_price_per_mtok=3.00
    output_price_per_mtok=15.00
    cache_write_price_per_mtok=3.75
    cache_read_price_per_mtok=0.30
    ;;
esac

# Calculate total cost
input_cost=$(echo "scale=4; $total_input * $input_price_per_mtok / 1000000" | bc)
output_cost=$(echo "scale=4; $total_output * $output_price_per_mtok / 1000000" | bc)
total_cost=$(echo "scale=4; $input_cost + $output_cost" | bc)

# Format cost for display
if (( $(echo "$total_cost >= 1" | bc -l) )); then
  cost_display=$(printf "\$%.2f" "$total_cost")
elif (( $(echo "$total_cost >= 0.01" | bc -l) )); then
  cost_display=$(printf "\$%.3f" "$total_cost")
elif (( $(echo "$total_cost > 0" | bc -l) )); then
  cost_display=$(printf "\$%.4f" "$total_cost")
else
  cost_display="\$0.00"
fi

# Get just the directory name (like %c in zsh)
dir_name=$(basename "$cwd")

# Build status line inspired by robbyrussell theme
# Arrow in green, directory in cyan, git info if available
status=$(printf "\033[1;32m➜\033[0m  \033[36m%s\033[0m" "$dir_name")

# Add git branch if in a git repo (skip optional locks to avoid hanging)
if [ -d "$cwd/.git" ]; then
  branch=$(cd "$cwd" && git -c core.fileMode=false config --global --add safe.directory "$cwd" 2>/dev/null; git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    # Check if dirty (has uncommitted changes)
    if cd "$cwd" && ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
      status=$(printf "%s  \033[1;34mgit:(\033[31m%s\033[34m)\033[0m \033[33m✗\033[0m" "$status" "$branch")
    else
      status=$(printf "%s  \033[1;34mgit:(\033[31m%s\033[34m)\033[0m" "$status" "$branch")
    fi
  fi
fi

# Add token usage information
if [ -n "$used_pct" ]; then
  # Format total tokens with K suffix for readability
  total_tokens=$((total_input + total_output))
  if [ $total_tokens -ge 1000 ]; then
    token_display=$(printf "%.1fK" "$(echo "scale=1; $total_tokens / 1000" | bc)")
  else
    token_display="${total_tokens}"
  fi

  # Color code based on usage percentage
  if [ "${used_pct%.*}" -ge 80 ]; then
    # Red for high usage (80%+)
    status=$(printf "%s  \033[31m%s tokens (%s%% used)\033[0m" "$status" "$token_display" "${used_pct%.*}")
  elif [ "${used_pct%.*}" -ge 50 ]; then
    # Yellow for moderate usage (50-79%)
    status=$(printf "%s  \033[33m%s tokens (%s%% used)\033[0m" "$status" "$token_display" "${used_pct%.*}")
  else
    # Green for low usage (<50%)
    status=$(printf "%s  \033[32m%s tokens (%s%% used)\033[0m" "$status" "$token_display" "${used_pct%.*}")
  fi
fi

# Add cost info
status=$(printf "%s  \033[35m%s\033[0m" "$status" "$cost_display")

# Add model info
status=$(printf "%s  \033[2m[%s]\033[0m" "$status" "$model")

# Add agent name if present
if [ -n "$agent" ]; then
  status=$(printf "%s  \033[2m⚡%s\033[0m" "$status" "$agent")
fi

shortcuts=$(printf "\033[2m^R search · ^W del word · ^U del start · ^K del end · ^Y paste · ^L clear\033[0m")

printf "%s\n%s\n" "$status" "$shortcuts"
