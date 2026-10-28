#!/bin/bash
# Status line converted from ~/.bashrc PS1 (~/.zshrc has no PS1, uses powerlevel10k instead).
# Original: PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# Hostname dropped from the prompt at Julien's request 2026-09-24.
# Username dropped from the prompt at Julien's request 2026-09-24.
input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir')
dir="${cwd/#$HOME/\~}"

chroot=""
if [ -r /etc/debian_chroot ]; then
	chroot="($(cat /etc/debian_chroot))"
fi

printf '%s\033[01;34m%s\033[00m' "$chroot" "$dir"

# Git branch and number of changed files (staged, unstaged and untracked), requested 2026-10-16.
# --no-optional-locks avoids taking index.lock and racing with git commands run elsewhere.
branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short -q HEAD 2>/dev/null \
	|| git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
if [ -n "$branch" ]; then
	changed=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null | wc -l)
	printf ' \033[02m|\033[00m \033[01;32mgit: %s\033[00m' "$branch"
	if [ "$changed" -gt 0 ]; then
		printf ' \033[31m(%d changed)\033[00m' "$changed"
	else
		printf ' \033[02m(clean)\033[00m'
	fi
fi

# Model, context usage and rate limits (statusline-setup, requested by Julien 2026-09-23).
# Label:value colon separators added for readability at Julien's request 2026-09-25.
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
session_id=$(echo "$input" | jq -r '.session_id // empty')
# total_input_tokens reflects the full current context, unlike current_usage.input_tokens
# which is only the fresh (non-cached) tokens of the last API call and made "in" look
# tiny/wrong next to "cached" (fixed 2026-09-25).
ctx_in=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
# total_output_tokens is only the most recent API response, not a running total, so "out"
# reset every turn instead of growing like "in"/"cached". Accumulate it ourselves in a
# per-session state file: add the previous response's tokens once a new (smaller) response
# starts (2026-09-27).
ctx_out_last=$(echo "$input" | jq -r '.context_window.total_output_tokens // empty')
ctx_out=""
if [ -n "$session_id" ] && [ -n "$ctx_out_last" ]; then
	state_dir="$HOME/.claude/statusline-state"
	mkdir -p "$state_dir"
	state_file="$state_dir/$session_id.out"
	prev_last=0
	prev_total=0
	if [ -f "$state_file" ]; then
		read -r prev_last prev_total < "$state_file"
	fi
	if [ "${ctx_out_last%.*}" -lt "${prev_last%.*}" ] 2>/dev/null; then
		prev_total=$(( prev_total + prev_last ))
	fi
	prev_last="$ctx_out_last"
	echo "$prev_last $prev_total" > "$state_file"
	ctx_out=$(( prev_total + prev_last ))
fi
ctx_cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // empty')
ctx_cache_write=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // empty')
five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
five_hour_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_day_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')

# Format a unix timestamp; GNU date uses -d @ts, BSD/macOS date uses -r ts.
fmt_epoch() {
	date -d "@$1" "$2" 2>/dev/null || date -r "$1" "$2"
}

# Insert thousand separators into an integer, e.g. 12345 -> 12,345.
fmt_num() {
	printf '%d' "${1:-0}" | rev | sed 's/\([0-9]\{3\}\)/\1,/g;s/,$//' | rev
}

[ -n "$model" ] && printf ' \033[02m|\033[00m \033[36mmodel: %s\033[00m' "$model"

[ -n "$used_pct" ] && printf ' \033[02m|\033[00m \033[33mctx: %.0f%%\033[00m' "$used_pct"

if [ -n "$ctx_in" ] || [ -n "$ctx_out" ] || [ -n "$ctx_cache_read" ] || [ -n "$ctx_cache_write" ]; then
	cached=$(( ${ctx_cache_read:-0} + ${ctx_cache_write:-0} ))
	printf ' \033[02m(in: %s out: %s cached: %s)\033[00m' "$(fmt_num "$ctx_in")" "$(fmt_num "$ctx_out")" "$(fmt_num "$cached")"
fi

if [ -n "$five_hour" ] || [ -n "$seven_day" ]; then
	limits=""
	# Reset time for 5h (HH:MM), reset date for 7d (Mon DD), requested 2026-10-11.
	if [ -n "$five_hour" ]; then
		limits="5h: $(printf '%.0f' "$five_hour")%"
		[ -n "$five_hour_reset" ] && limits="$limits ($(fmt_epoch "$five_hour_reset" +%H:%M))"
	fi
	if [ -n "$seven_day" ]; then
		limits="${limits:+$limits }7d: $(printf '%.0f' "$seven_day")%"
		[ -n "$seven_day_reset" ] && limits="$limits ($(fmt_epoch "$seven_day_reset" '+%a %b %d'))"
	fi
	printf ' \033[02m|\033[00m \033[35m%s\033[00m' "$limits"
fi

[ -n "$cost" ] && printf ' \033[02m|\033[00m \033[32mcost: $%.2f\033[00m' "$cost"
