#!/usr/bin/env bash
# Filters a list of PR numbers, keeping only those that touch services/mcp
# and where VojtechBartos is NOT a participant (author, reviewer, or commenter).
#
# Usage: echo "12345 12346 12347" | ./filter-mcp-prs.sh
# Output: tab-separated lines sorted newest-first by createdAt:
#         createdAt  number  title  author  state  mergedAt

set -euo pipefail

REPO="PostHog/posthog"
EXCLUDE_USER="VojtechBartos"
results=()

read -r -a prs <<< "$(cat)"

for pr in "${prs[@]}"; do
  data=$(gh pr view "$pr" --repo "$REPO" \
    --json files,author,reviews,comments,title,state,createdAt,mergedAt 2>/dev/null) || continue

  [ -n "$data" ] || continue

  touches_mcp=$(echo "$data" | jq -r '.files[].path' | grep -c '^services/mcp' || true)
  [ "$touches_mcp" -gt 0 ] || continue

  # Check author, reviewers, and commenters for the excluded user.
  author_login=$(echo "$data" | jq -r '.author.login')
  [ "$author_login" != "$EXCLUDE_USER" ] || continue

  reviewer_match=$(echo "$data" | jq -r '.reviews[]?.author.login // empty' | grep -c "$EXCLUDE_USER" || true)
  [ "$reviewer_match" -eq 0 ] || continue

  commenter_match=$(echo "$data" | jq -r '.comments[]?.author.login // empty' | grep -c "$EXCLUDE_USER" || true)
  [ "$commenter_match" -eq 0 ] || continue

  title=$(echo "$data" | jq -r '.title')
  state=$(echo "$data" | jq -r '.state')
  created=$(echo "$data" | jq -r '.createdAt')
  merged=$(echo "$data" | jq -r '.mergedAt // empty')

  results+=("${created}	${pr}	${title}	${author_login}	${state}	${merged}")
done

if [ ${#results[@]} -eq 0 ]; then
  exit 0
fi

printf '%s\n' "${results[@]}" | sort -t$'\t' -k1,1r
