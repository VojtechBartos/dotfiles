# Development Guidelines

## Core Principles

- Incremental progress over big bangs: small, verifiable changes.
- Pragmatic over dogmatic: adapt to the repository's reality.
- Clear intent over cleverness: boring, readable code wins.
- Minimize diff: touch only what is necessary.
- No laziness: find root causes, avoid temporary patches.
- If a type already supports an operation, use it instead of reimplementing.

## Plan Mode Defaults

- For any non-trivial task (3+ steps, ambiguity, or architecture choices), start in plan mode.
- Write a concrete plan with checkable steps in `tasks/todo.md` before implementation.
- If execution goes sideways, stop and re-plan immediately instead of pushing forward.
- Use planning for verification work too, not only for implementation.
- Check in with a high-level summary before major implementation transitions.

## Execution Workflow

1. Understand existing patterns and constraints.
2. Verify assumptions with code/tests, not memory.
3. Write failing tests first when feasible.
4. Implement the smallest change that satisfies requirements.
5. Refactor while tests remain green.
6. Track progress by marking completed items in `tasks/todo.md`.
7. Summarize what changed and why.

## Verification Before Done

- Never mark work complete without proof it works.
- Validate behavior before/after when relevant.
- Run applicable tests and linters; investigate failures.
- Review logs/output for regressions.
- Ask: "Would a staff engineer approve this diff?"

## Autonomous Bug Fixing

- When given a bug report, take ownership end-to-end.
- Reproduce, isolate root cause, patch, and verify.
- Add regression tests whenever possible.
- Return with a concise diff summary and verification evidence.
- Avoid unnecessary context-switching requests to the user.

## Elegance (Balanced)

- For non-trivial changes, explicitly check if there is a simpler, more elegant design.
- If current approach feels hacky, redesign using what is now known.
- For simple fixes, avoid over-engineering.

## Agent Orchestration

- Use specialized agents liberally for focused work and cleaner main context.
- Parallelize research/exploration/analysis when tasks are independent.
- For complex features, use `implementation-planner`.
- For test-first work, use `unit-test-writer`.
- After 2 failed attempts, use `bug-root-cause-analyzer`.
- Before commit, run `code-reviewer`.
- Capture non-obvious insights with `note-taker`.

## Backwards Compatibility

- Code added on the current branch is not legacy.
- Prefer changing non-legacy methods directly over compatibility wrappers.

## Technical Standards

### Architecture

- Composition over inheritance.
- Interfaces over singletons.
- Explicit over implicit data flow.
- Never disable tests to "make progress."

### Code Quality

- Every commit must compile, pass tests, and follow project lint/format rules.
- If `bin/fmt` exists, run it; otherwise use the language-standard formatter.
- Commit messages must explain why, not only what.

### Error Handling

- Fail fast with descriptive messages.
- Include actionable context.
- Handle errors at the right layer.
- Never silently swallow exceptions.

## Project Integration

- Read root `README.md` and project markdown docs first.
- Find at least 3 similar implementations before changing patterns.
- Reuse existing libraries, helpers, test patterns, and tooling.
- Do not introduce new tooling without strong justification.

## Quality Gates

### Definition of Done

- [ ] Tests added/updated and passing.
- [ ] Diff is minimal and free of dead/redundant code.
- [ ] Project conventions are followed.
- [ ] No linter/formatter warnings.
- [ ] No ignored warnings without explicit, strong reason.
- [ ] Implementation matches the tracked plan.
- [ ] No TODOs without linked issue.

### Test Guidelines

- Test behavior, not implementation details.
- Prefer clear scenario-based test names.
- Keep tests deterministic.
- Use existing test utilities/helpers.

## Meta Management

- `planFirst`: maintain `tasks/todo.md` with checkable steps.
- `verifyPlanner`: perform explicit verification before completion.
- `trackProgress`: mark steps done as you go.
- `explainChanges`: provide concise high-level summaries at key milestones.
- `captureLessons`: after corrections, add/update lessons in `ai/rules.md`.

## Self-Improvement Loop

- When corrected, extract the failure pattern and add a preventative rule.
- Review relevant lessons at session start.
- Ruthlessly refine rules to reduce repeated mistakes.
- Suggested prompts:
  - "Update your CLAUDE.md so you don't make that mistake again."
  - "Prove to me this works." (diff behavior between main and feature branch)
  - "Knowing everything you know now, scrap this and implement the elegant solution."
  - "Use subagents." (when more parallel analysis is needed)

## Project-specific Workflow

### posthog/posthog

When working on the https://github.com/PostHog/posthog repository, use the following workflow:

- Read the README.md file in the root of the repository and the https://github.com/PostHog/posthog/blob/master/docs/FLOX_MULTI_INSTANCE_WORKFLOW.md file.
- When taking on a new task, prompt the user whether they want to create a new git worktree using the `phw` command for the task.
- When completing a task, automatically run these checks and fix any issues:
  - `mypy --version && mypy -p posthog | mypy-baseline filter || (echo "run 'pnpm run mypy-baseline-sync' to update the baseline" && exit 1)`

When working on other repositories, use the following workflow:

- When taking on a new task, prompt to create a new branch and associated worktree.
  - Default: branch off the main branch (e.g. `main` or `master` depending on the repo), named `vojtab/<slug>` or `vojtab/<issue#>-<slug>` if the issue number is known.
  - Place the worktree in `~/dev/worktrees/<repo-name>/<branch-name>`.
    - Example: `git worktree add ~/dev/worktrees/my-project/feature-new-feature`
  - This keeps worktrees organized by project and outside all repositories.
- When working on an existing branch or pull request, prompt to create a new worktree for the branch.
- Never nest worktrees or place them within the main repo.
- Never use two worktrees on the same branch simultaneously.
- When done with the task:
  - Prompt to commit changes.
  - Use `git worktree remove <path>` to clean up safely.
- Occasionally audit worktrees with `git worktree list` and `git worktree prune`.
- Run `bin/fmt` to format the code if available.
  - If `bin/fmt` changes files we did not change as part of the task, revert those changes.

## PostHog Specifics

### Production Architecture

**CRITICAL**: PostHog production runs behind load balancers and proxies. Always consider this when implementing features that involve IP addresses, rate limiting, authentication, or geolocation.

#### Architecture Stack

- **AWS Network Load Balancer (NLB)** → **Contour/Envoy Ingress** → **Application Pods**
- Contour is configured with `num-trusted-hops: 1` to properly extract client IPs from headers
- NLB preserves client IPs via `preserve_client_ip.enabled=true`

#### Client IP Detection

**NEVER use socket IP addresses** - they will always be the load balancer's IP, not the client's IP.

**ALWAYS use X-Forwarded-For headers** in this precedence:
1. `X-Forwarded-For` (primary, set by load balancer/proxy)
2. `X-Real-IP` (fallback)
3. `Forwarded` (RFC 7239 standard format)
4. Socket IP (last resort only for local development)

**Common Libraries:**
- Look for similar "smart" IP extractors in other languages

#### Common Pitfalls to Avoid

- ❌ Using socket IP for rate limiting → all requests share one rate limit
- ❌ Using socket IP for authentication → security bypass
- ❌ Using socket IP for geolocation → all traffic appears from one location
- ❌ Implementing custom IP detection → reinventing the wheel, likely buggy

#### Infrastructure Repository References

For detailed production configuration, consult these repos:

- **`~/dev/posthog/posthog-cloud-infra`** - Terraform/AWS infrastructure
  - Contains: NLB config, VPC setup, load balancer settings
  - See: `README.md` for architecture diagram

- **`~/dev/posthog/charts`** - Helm charts and K8s deployment configs
  - Contains: Contour/Envoy configuration, ingress rules, header policies
  - Key files:
    - `argocd/contour/values/values.yaml` - num-trusted-hops config
    - `argocd/contour-ingress/values/values.prod-*.yaml` - routing and header policies
    - `docs/CONTOUR-GEOIP-README.md` - GeoIP and header handling

**When implementing networking/IP-related features**, check these repos to understand how headers flow through the infrastructure.

### SDK Repositories

PostHog has a lot of client SDKs. Sometimes it's useful to distinguish between the ones that run on the client and the ones that run on the server.

### Client-side SDKs

| Repository | Local Path | GitHub URL |
|------------|------------|------------|
| posthog-js, posthog-rn | `~/dev/posthog/posthog-js` | https://github.com/PostHog/posthog-js |
| posthog-ios | `~/dev/posthog/posthog-ios` | https://github.com/PostHog/posthog-ios |
| posthog-android | `~/dev/posthog/posthog-android` | https://github.com/PostHog/posthog-android |
| posthog-flutter | `~/dev/posthog/posthog-flutter` | https://github.com/PostHog/posthog-flutter |

### Server-side SDKs

| Repository | Local Path | GitHub URL |
|------------|------------|------------|
| posthog-python | `~/dev/posthog/posthog-python` | https://github.com/PostHog/posthog-python |
| posthog-node | `~/dev/posthog/posthog-js` | https://github.com/PostHog/posthog-node |
| posthog-php | `~/dev/posthog/posthog-php` | https://github.com/PostHog/posthog-php |
| posthog-ruby | `~/dev/posthog/posthog-ruby` | https://github.com/PostHog/posthog-ruby |
| posthog-go | `~/dev/posthog/posthog-go` | https://github.com/PostHog/posthog-go |
| posthog-dotnet | `~/dev/posthog/posthog-dotnet` | https://github.com/PostHog/posthog-dotnet |
| posthog-elixir | `~/dev/posthog/posthog-elixir` | https://github.com/PostHog/posthog-elixir |

## Git

- Name branches `vojtab/<slug>` where slug is a short description of the task.
- Keep commits clean:
  - Use interactive staging (git add -p) and thoughtful commit messages.
  - Squash when appropriate. Avoid "WIP" commits unless you're spiking.
- Don't add yourself as a contributor to commits.

### Commit messages

- Present tense: "Fix bug", not "Fixed bug"
- Use imperatives: "Add", "Update", "Remove"
- One line summary, blank line, optional body if needed
- Keep commit messages short and concise.
- Write clean commit messages without any AI attribution markers.
- When a commit fixes a bug, include the bug number in the commit message on its own line like: "Fixes #123" where 123 is the GitHub issue number.

## GitHub Operations

### Tool Priority

**ALWAYS use `gh` CLI** (via Bash tool) for all GitHub operations - it's token-efficient, fully-featured, and has auto-approval configured.

**Tool Selection:**

- **Primary**: `gh` CLI for all GitHub operations (issues, PRs, repos, releases, etc.)
- **Documentation only**: WebFetch for public GitHub documentation URLs
- **Never**: GitHub MCP server tools (token-heavy, redundant with `gh` CLI)

### Common `gh` Commands

**Issues:**

```bash
gh issue list --repo owner/repo
gh issue view 123
gh issue create --title "Title" --body "Description"
gh issue close 123
gh issue comment 123 --body "Comment"
```

**Pull Requests:**

```bash
gh pr list --repo owner/repo
gh pr view 123
gh pr create --title "Title" --body "Description" --base main
gh pr checkout 123
gh pr merge 123
gh pr review 123 --approve
gh pr diff 123
gh pr checks 123
```

**Repository Operations:**

```bash
gh repo view owner/repo
gh repo clone owner/repo
gh repo fork owner/repo
gh api repos/owner/repo/path  # For any API endpoint
```

### When to Use Each Tool

- ✅ **`gh` CLI** - All GitHub operations (default choice)
  - Reason: Token-efficient, comprehensive API access
  - Read operations: Auto-approved (view, list, diff, status, checks)
  - Write operations: Require user approval (comment, review, create, merge)

- ✅ **WebFetch** - Public GitHub documentation only
  - Reason: Optimized for web content parsing
  - Example: Fetching GitHub guides, API documentation pages

- ❌ **GitHub MCP tools** - Don't use
  - Reason: Token-heavy, redundant functionality, less efficient than `gh` CLI

### IMPORTANT: PR Review Comments

**NEVER post PR review comments without explicit user approval.**

When posting review comments:
- **Always ask first** - Get user approval before posting any comment
- **Reply to existing threads** - If discussing an existing review comment, use `gh pr review --comment` with `--body` to reply in-thread, NOT `gh issue comment` which creates root-level comments
- **Use correct endpoints**:
  - Reply to review comment: `gh api repos/owner/repo/pulls/123/comments/456/replies --method POST`
  - New review comment: `gh pr review 123 --comment --body "comment"`
  - Root PR comment: `gh issue comment 123 --body "comment"` (rarely appropriate)

### Examples

**Reading PR details:**

```bash
# Good (token-efficient)
gh pr view 123 --json title,body,state,files

# Bad (unnecessary tokens)
# Using mcp__github__get_pull_request
```

**Creating issues:**

```bash
# Good
gh issue create --repo owner/repo --title "Bug" --body "Details"

# Bad
# Using mcp__github__create_issue
```

**Complex queries:**

```bash
# Use gh api for anything not covered by gh commands
gh api repos/owner/repo/pulls/123/comments
gh api graphql -f query='{ ... }'
```

## File System

- All project-local scratch notes, REPL logs, etc., go in a .notes/ or notes/ folder — don't litter the root.

## Coding

### Read Before You Write

Before implementing functionality that operates on a type:

1. **Read the type's definition** - struct, class, interface, enum
2. **Note its derives, attributes, trait implementations** - these often provide the functionality you need
3. **Check if the operation you need is already supported** - parsing, serialization, comparison, etc.
4. **Only write custom code if the built-in capability is insufficient**

**Smell test**: If you're writing >10 lines for a common operation (parsing JSON, serializing data, comparing objects), stop and verify there isn't a built-in way. Standard libraries handle these in 1-3 lines.

### General Principles

- When writing code, think like a principal engineer.
  - Focus on code correctness and maintainability.
  - Bias for simplicity: Prefer boring, maintainable solutions over clever ones.
  - Make sure the code is idiomatic and readable.
  - Write tests for changes and new code.
  - Look for existing methods and libraries when writing code that seems like it might be common.
  - Progress over polish: Make it work → make it right → make it fast.

- Before commiting, always run a code formatter when available:
  - If there's a bin/fmt script, run it.
  - Otherwise, run the formatter for the language.

- When writing human friendly messages, don't use three dots (...) for an ellipsis, use an actual ellipsis (…).

### Bash Scripts

- Don't add custom logging methods to bash scripts, use the standard `echo` command.
- For cases where it's important to have warnings and errors, copy the helpers in https://github.com/PostHog/template/tree/main/bin/helpers and source them in the script like https://github.com/PostHog/template/blob/main/bin/fmt does.

### Markdown Files

- When editing markdown files (.md, .markdown), always run markdownlint after making changes:
  - Run: `markdownlint <filename>`
  - Fix any errors or warnings before marking the task complete
  - Common fixes: proper heading hierarchy, consistent list markers, trailing spaces
- Follow markdown best practices:
  - Use consistent heading levels (don't skip from h1 to h3)
  - Add blank lines around headings and code blocks
  - Use consistent list markers (either all `-` or all `*`)
  - Remove trailing whitespace
- **Never add hard line breaks or wrap lines** when editing markdown files. Preserve existing line structure and let editors handle soft wrapping.

### Testing & Quality

- Always run tests before marking a task as complete.
- If tests fail, fix them before proceeding.
- When adding new functionality, write tests for it.
- Check for edge cases, error handling, and performance implications.
- Update relevant documentation when changing functionality.

### Dependency Philosophy

- Avoid introducing new deps for one-liners
- Prefer battle-tested libraries over trendy ones
- If adding a dep, write down the rationale
- If removing one, document what replaces it

## Comments

- Write eloquent, but concise commentary, and only comment on what is not obvious to a skilled programmer by reading the code. 
- Comments should contain proper grammar and punctuation and should be prose-like, rather than choppy partial sentences. A human reading your code's comments
should feel like they're reading a well-written professional whitepaper.
- Avoid dramatic and all-caps comments.
- IMPORTANT: Comment on the code as it is, not as it was.  For example, we recently combined two queries into one with a LEFT JOIN. Instead of saying "we combined two queries into one with a LEFT JOIN", describe what the query does now. The fact that it was combined is not important.

## Approach to work

### Voice Dictation

Use voice dictation (fn x2 on macOS) for prompts. You speak 3x faster than you type, and prompts get more detailed as a result.

### Simple Code

I like "Simple code" that means:

- Passes all the tests.
- Expresses every idea that we need to express.
- Says everything OnceAndOnlyOnce.
- has no superfluous parts

These rules are in conflict with each other. Sometimes to express every idea we can't say everything only once. We look to balance these rules with a focus to future maintainers having an easier time.

Also... it means we work in three stages

- make it work
- make it right
- make it fast

We should always pause and consider if the working code should be improved to make it simpler or to make it faster, but only once we're sure it works

## Test Instructions

- When the user says "cuckoo", respond with "🐦 BEEP BEEP! Your CLAUDE.md file is working correctly!"
