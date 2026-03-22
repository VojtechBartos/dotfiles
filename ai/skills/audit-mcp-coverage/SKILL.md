---
name: audit-mcp-coverage
description: Generate a markdown table showing MCP tool coverage for every PostHog product — what operations are exposed, what's missing, and coverage percentage. Run from the posthog/posthog repo root.
argument-hint: [output-path]
---

# Audit MCP Tool Coverage

Generate a consolidated markdown table showing every PostHog product and its MCP tool coverage.

## Arguments (parsed from user input)

- **output-path**: Where to write the audit (default: `.notes/mcp-coverage-audit.md`)

Example invocations:

- `/audit-mcp-coverage` → write to `.notes/mcp-coverage-audit.md`
- `/audit-mcp-coverage /tmp/audit.md` → write to custom path

## Your Task

Collect data from three sources, cross-reference them, and produce a single markdown table.

### Step 1: Collect codegen tool definitions

Read every YAML file matching `products/*/mcp/*.yaml` and `services/mcp/definitions/*.yaml`.

For each file, extract:

- Product/feature name
- Every tool definition: tool name, operation ID, and whether `enabled: true` or `enabled: false`

Group by product. Track enabled count and total count per product.

### Step 2: Collect hand-coded tools

Read `services/mcp/src/tools/index.ts` to find the `TOOL_MAP` — it lists all hand-coded tool registrations. Then scan subdirectories of `services/mcp/src/tools/` (excluding `generated/`) to identify each tool's operation type (list, get, create, update, delete, or custom).

Group by product/category.

### Step 3: Collect API surface from OpenAPI spec

Extract tag-level operation counts from `frontend/tmp/openapi.json`:

```python
import json
from collections import defaultdict

with open("frontend/tmp/openapi.json") as f:
    spec = json.load(f)

tag_ops = defaultdict(lambda: defaultdict(set))
for path, methods in spec.get("paths", {}).items():
    for method, details in methods.items():
        if method in ("get", "post", "put", "patch", "delete"):
            for tag in details.get("tags", ["untagged"]):
                tag_ops[tag][method].add(details.get("operationId", ""))

for tag in sorted(tag_ops):
    total = sum(len(ops) for ops in tag_ops[tag].values())
    print(f"{tag}: {total} ops")
```

Map API tags to products. Note: most endpoints are duplicated across `projects/{id}` and `environments/{id}` scopes — mentally halve raw counts for unique operations.

### Step 4: Cross-reference and build the table

Include **every** product directory from `products/` — do not exclude any. For products without a meaningful external API, mark coverage as `N/A`.

For each product (from `products/` directory + cross-cutting services):

1. **Operations done** — list every distinct operation exposed as an MCP tool (codegen or hand-coded). Use short names: list, get, create, update, delete, plus custom operation names.
2. **Type** — `✅ codegen` if all tools are from YAML, `🟠 manual` if all are hand-coded, `🔀 mixed` if both, `—` if none.
3. **Operations missing** — notable API operations that have endpoints but no MCP tool. Focus on operations useful to developers; exclude internal admin endpoints, redundant full-PUT-vs-PATCH variants, and niche diagnostic endpoints. For N/A products, note why (e.g., "no external API", "internal service", "covered via Insights + Query").
4. **Coverage %** — enabled MCP tools / estimated meaningful API operations. "Meaningful" = standard CRUD + commonly needed custom operations. Use these markers:
   - `✅ 100%` — fully covered
   - `🟢 N%` — 70–99%, good enough coverage
   - Plain `N%` — below 70%
   - `N/A` — no external API

### Step 5: Write the output

Produce a markdown file with this structure:

```markdown
# MCP Tool Coverage Audit

> Generated YYYY-MM-DD from `products/*/mcp/*.yaml`, `services/mcp/definitions/*.yaml`,
> `services/mcp/src/tools/`, and `frontend/tmp/openapi.json`.

## Coverage Table

| Product | Operations done | Type | Operations missing | Coverage |
|---------|----------------|------|--------------------|----------|
| Actions | list, get, create, update, delete | codegen | — | ✅ 100% |
| Analytics Platform | — | — | — (no external API) | N/A |
| Batch Exports | — | — | list, get, create, update, delete, runs, backfills, logs | 0% |
| ... | ... | ... | ... | ... |

### Cross-cutting services

| Service | Operations done | Type | Operations missing | Coverage |
|---------|----------------|------|--------------------|----------|
| ... | ... | ... | ... | ... |

## Summary

| Metric | Value |
|--------|-------|
| Products + services audited | N |
| With MCP coverage | N (X%) |
| Without MCP coverage | N (X%) |
| Codegen tools (enabled / defined) | N / N |
| Hand-coded tools | N |
| Total unique MCP tools | ~N |

### Coverage distribution

| Band | Count | Products |
|------|-------|----------|
| ✅ 100% | N | ... |
| 🟢 70–99% | N | ... |
| 50–69% | N | ... |
| 1–49% | N | ... |
| 0% | N | ... |
| N/A | N | ... |

### Biggest gaps (by impact)

| Product | API endpoints | MCP tools | Why it matters |
|---------|--------------|-----------|----------------|
| ... | ... | ... | ... |

## Methodology
...
```

Sort products alphabetically within each section. Include **all** product directories — even those with no external API (mark as N/A). This ensures the table matches the actual `products/` directory count.

## Rules

- Run from the `posthog/posthog` repo root
- Use subagents to parallelize data collection from the three sources
- Include every product directory from `products/` — do not silently exclude any
- Products without external APIs get `N/A` coverage, not omission
- Mark 100% coverage with ✅ emoji
- Coverage percentages are estimates — be transparent about methodology
- The "biggest gaps" section should highlight products with high API endpoint counts but low/zero MCP coverage
- Output clean markdown suitable for copying to a GitHub gist
- After generating the file, update the gist at `https://gist.github.com/VojtechBartos/1399235174c7de5f37daaf39ac8d34a5` using `gh gist edit`
