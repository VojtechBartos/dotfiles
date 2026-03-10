---
name: get-recent-ph-mcp-prs
description: List recent PRs touching services/mcp in PostHog/posthog where VojtechBartos is NOT involved
argument-hint: [days]
---

# PostHog MCP PRs

List recent PRs in PostHog/posthog that touch `services/mcp` where @VojtechBartos is **NOT** involved (not author, reviewer, or commenter). This surfaces MCP changes by other team members that you may want to review.

## Arguments (parsed from user input)

- **days**: How many days back to search (default: 7)

Example invocations:

- `/get-recent-ph-mcp-prs` → last 7 days
- `/get-recent-ph-mcp-prs 14` → last 14 days

## Your Task

### Step 1: Parse Arguments

Extract `days` from the user's input (default: 7).

### Step 2: Fetch All MCP PRs

Search for all PRs (not filtered by user) that mention `services/mcp`, extract just the PR numbers, deduplicate, and pipe into the filter script:

```bash
# Collect PR numbers from both queries
open_prs=$(gh search prs --repo PostHog/posthog --state open --json number --jq '.[].number' -- "services/mcp")
merged_prs=$(gh search prs --repo PostHog/posthog --merged ">=$(date -v-{days}d +%Y-%m-%d)" --json number --jq '.[].number' -- "services/mcp")

# Deduplicate and pipe into filter script
all_prs=$(echo "$open_prs $merged_prs" | tr ' \n' ' ' | tr -s ' ')
echo "$all_prs" | /Users/vojta/.claude/skills/get-recent-ph-mcp-prs/filter-mcp-prs.sh
```

The filter script checks each PR, keeps only those that touch `services/mcp` files and where VojtechBartos is not involved (author, reviewer, or commenter). It outputs tab-separated lines sorted newest-first:

```
createdAt\tnumber\ttitle\tauthor\tstate\tmergedAt
```

### Step 4: Present Results

Group results by state (OPEN then MERGED) and display a table sorted newest-first within each group:

- PR number (linked to GitHub)
- Title
- Author
- Opened date (formatted as `YYYY-MM-DD`)
- Merged date (for merged PRs, formatted as `YYYY-MM-DD`)

If no PRs are found, say so.
