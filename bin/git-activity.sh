#!/bin/bash

# --- Configuration ---
# Set the number of days to look back (e.g., 30 for the last month)
DAYS_BACK=30
# --- End Configuration ---

# Get the author's email from the local or global git config
AUTHOR_EMAIL=$(git config user.email)

# Check if email is set
if [ -z "$AUTHOR_EMAIL" ]; then
  echo "Error: Git user.email is not set."
  echo "Please set it for this repo (or globally) before running this script:"
  echo "  git config user.email 'your.email@example.com'"
  exit 1
fi

echo "📊 Gathering stats for author: $AUTHOR_EMAIL"
echo "================================================================="
printf "%-12s | %-9s | %-11s | %-12s\n" "Date" "Commits" "Added (+)" "Removed (-)"
echo "-----------------------------------------------------------------"

# Loop from $DAYS_BACK days ago up to today
for i in $(seq $DAYS_BACK -1 0); do
  # Get the specific day in YYYY-MM-DD format
  DAY=$(date -d "$i days ago" +%Y-%m-%d)
  
  # Define the time range for that specific day
  SINCE="${DAY} 00:00:00"
  UNTIL="${DAY} 23:59:59"
  
  # 1. Get the commit count for that day
  # We use --no-merges to only count original work, not merge commits
  COMMIT_COUNT=$(git log --author="$AUTHOR_EMAIL" --since="$SINCE" --until="$UNTIL" --oneline --no-merges | wc -l | tr -d ' ')
  
  # 2. Get stats only if there were commits
  if [ "$COMMIT_COUNT" -gt 0 ]; then
    # Use git log --numstat to get machine-readable line changes
    #
    # *** THIS IS THE CORRECTED PART ***
    # This awk command is now much safer:
    # 1. BEGIN { added=0; removed=0 } - Explicitly initializes totals to zero.
    # 2. if ($1 ~ /^[0-9]+$/) ... - Only adds $1 if it is a valid number.
    # 3. if ($2 ~ /^[0-9]+$/) ... - Only adds $2 if it is a valid number.
    # This safely skips binary files (which show up as '-\t-') and any other
    # unexpected non-numeric output.
    #
    STATS=$(git log --author="$AUTHOR_EMAIL" --since="$SINCE" --until="$UNTIL" --numstat --no-merges | \
            awk 'BEGIN { added=0; removed=0 } { if ($1 ~ /^[0-9]+$/) added += $1; if ($2 ~ /^[0-9]+$/) removed += $2 } END { print added, removed }')
    
    # Read the two numbers from the STATS output
    read ADDED REMOVED <<< "$STATS"
    
  else
    # No commits, so no lines changed
    ADDED=0
    REMOVED=0
  fi
  
  # 3. Print the formatted output for the day
  printf "%-12s | %-9s | %-11s | %-12s\n" "$DAY" "$COMMIT_COUNT" "$ADDED" "$REMOVED"
  
done

echo "================================================================="
