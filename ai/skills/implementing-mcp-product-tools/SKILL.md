---
name: implementing-mcp-product-tools
description: 'Step-by-step workflow for exposing a PostHog product as MCP tools. Covers serializer docs, HogQL system tables, YAML config, codegen, and integration tests. Prepend with the product name.'
---

# Implement MCP tools for <PRODUCT_NAME>

Read the `/implementing-mcp-tools` skill and the `/improving-drf-endpoints` skill before starting.

Reference implementation: the alerts MCP tools in `products/alerts/mcp/tools.yaml`, `posthog/api/alert.py`, and `services/mcp/tests/tools/alerts.integration.test.ts`.

## Workflow

Work through these steps in order. Each step should be a separate commit.

### Step 1: Extend OpenAPI schema docs on serializers

Find the serializer(s) for <PRODUCT_NAME> (search `class.*Serializer.*ModelSerializer` in `posthog/api/` and `products/*/backend/`).

For every field on the create/update serializer that an agent would interact with:

- Add `help_text` describing purpose, format, constraints, and valid values
- For `JSONField` subclasses, use `@extend_schema_field(PydanticModel)` for typed Zod output (see `posthog/api/alert.py` ThresholdConfigurationField for the pattern)
- For `ListField`, ensure `child=` is specified with a typed field
- Explicitly declare fields that Django infers implicitly if they need `help_text` (e.g., `name`, `enabled`)
- Add `help_text` to read-only fields too — agents need to understand responses

Do NOT change any business logic, validation, or behavior. Only add/modify field declarations and `help_text`.

Commit: `chore(<product>): extend openapi schema docs for MCP usage`

### Step 2: Add HogQL system table (conditional)

**Skip if** the product's Django model does NOT have a `team_id` field, or if a system table already exists in `posthog/hogql/database/schema/system.py`.

If the model has `team_id`:

1. Add a `PostgresTable` in `posthog/hogql/database/schema/system.py` with all queryable columns. Use the correct `postgres_table_name` (the actual DB table name) and set `access_scope` to match the viewset's `scope_object`. Insert alphabetically among existing tables.
2. Register in `SystemTables.children` dict (alphabetically).
3. Create a model reference at `products/posthog_ai/skills/query-examples/references/models-<product>.md` documenting columns, types, nullability, descriptions, key relationships, and important notes about enum values or JSON field structures. Follow the format in `models-alerts.md`.
4. Register the reference in `products/posthog_ai/skills/query-examples/SKILL.md` under **Data Schema** (alphabetically).
5. Run tests: `pytest posthog/hogql/database/schema/test/test_system_tables.py posthog/hogql/database/test/ -x` and update snapshots if needed.

Commit: `feat(hogql): add <product> system table`

### Step 3: Create MCP tools YAML

1. Scaffold: `pnpm --filter=@posthog/mcp run scaffold-yaml -- --product <product> --output ../../products/<product>/mcp/tools.yaml`
2. Configure the YAML:
   - Set `category` (human-readable), `feature` (snake_case, matches product folder), `url_prefix` (frontend route)
   - Enable standard CRUD tools: list, get, create, partial_update, delete. Disable full update if partial_update exists. Disable internal/admin endpoints.
   - Tool naming: `<domain>-list`, `<domain>-get`, `<domain>-create`, `<domain>-update`, `<domain>-delete` (kebab-case)
   - Scopes: `<scope_object>:read` for list/get, `<scope_object>:write` for mutations. The `scope_object` is on the viewset.
   - Annotations per operation type:
     - list/get: `{readOnly: true, destructive: false, idempotent: true}`
     - create: `{readOnly: false, destructive: false, idempotent: false}`
     - update (partial): `{readOnly: false, destructive: false, idempotent: true}`
     - delete: `{readOnly: false, destructive: true, idempotent: true}`
   - `mcp_version: 1` on list and get tools if a system table was added in step 2
   - `list: true` on the list tool
   - Write agent-friendly `description` for each enabled tool (1-3 sentences: what it does, what it returns, key constraints)
   - `exclude_params` on create/update: exclude server-managed fields (timestamps, computed state, internal IDs). Only expose fields the agent should set.
   - Only create tools that make sense for LLM/agent usage — skip niche admin endpoints

Commit: `feat(mcp): add <product> MCP tools`

### Step 4: Generate and verify

1. Run `hogli build:openapi` to regenerate everything
2. Verify generated files exist:
   - `services/mcp/src/tools/generated/<product>.ts`
   - `services/mcp/src/generated/<product>/api.ts`
   - Product appears in `services/mcp/src/tools/generated/index.ts`
3. Spot-check generated Zod schemas — confirm `help_text` flowed through as `.describe()` and JSONFields have typed schemas (not `z.unknown()`)

Commit: `chore: update OpenAPI generated types`

### Step 5: Write MCP integration tests

File: `services/mcp/tests/tools/<productName>.integration.test.ts` (camelCase filename).

Follow the pattern in `services/mcp/tests/tools/alerts.integration.test.ts`:

```typescript
import { GENERATED_TOOLS } from '@/tools/generated/<product>'
import {
    createTestClient, createTestContext, setActiveProjectAndOrg,
    parseToolResponse, generateUniqueKey, validateEnvironmentVariables,
    TEST_ORG_ID, TEST_PROJECT_ID,
} from '@/shared/test-utils'
import type { Context } from '@/tools/types'
```

Structure:
- `beforeAll`: validate env vars, create test client/context, set active project/org, set up prerequisites (if the product requires a parent entity, create it here)
- `afterEach`: cleanup created resources via the delete tool (best-effort, wrapped in try/catch)
- Helper `make<Entity>Params(overrides)` returning default valid create params
- Test suites:
  - **list**: paginated structure (`count`, `results` array, `_posthogUrl`), respects `limit`
  - **create**: basic creation, creation with various field combinations
  - **get**: retrieve by ID, throw for non-existent ID (`crypto.randomUUID()`)
  - **update**: update individual fields, update nested fields if applicable
  - **delete**: delete and verify get throws
  - **lifecycle**: full create -> get -> update -> delete workflow, verify entity appears in list after creation

Commit: `test(mcp): add <product> integration tests`

### Step 6: Update snapshots

If a system table was added in step 2:

```sh
pytest posthog/hogql/database/test/ -x --snapshot-update
pytest posthog/hogql/database/schema/test/test_system_tables.py -x --snapshot-update
```

Also update storybook snapshots if needed:

```sh
pnpm --filter=@posthog/frontend test -- --testPathPattern=Docs --update-snapshot
```

Commit: `test(backend): update query snapshots`

## Rules

- Do NOT change business logic — only extend OpenAPI docs on serializers
- Do NOT expose internal/admin-only endpoints as MCP tools
- Only expose fields that make sense for agent usage — hide server-managed state
- Only extend docs for fields that are useful to LLM/agents
- Use existing test utilities from `@/shared/test-utils`
- Follow conventional commits with appropriate scope
