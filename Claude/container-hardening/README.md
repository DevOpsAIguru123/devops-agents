# Claude Agent SDK Container Security Advisor

This standalone implementation uses the Claude Agent SDK (formerly the Claude
Code SDK) to explain bounded, sanitized Trivy findings. It does not import or
require the Google ADK project.

The trust boundary is deliberate:

```text
Claude proposes -> Trivy and deterministic policy decide -> Human approves
```

Claude has no tools, MCP servers, repository settings, or permission to read or
modify the workspace. It receives an allowlisted evidence envelope, runs for a
single turn, and returns a locally validated advisory. It cannot approve,
reject, waive, publish, or change a release decision. In particular,
`policy_decision: not_evaluated` is not approval.

## Five-minute test

Requirements: Python 3.11+, `uv`, and either an existing Claude Code login or
an `ANTHROPIC_API_KEY`. Never commit credentials.

The SDK uses its bundled Claude Code CLI by default. To test a newer installed
CLI, set `CLAUDE_CODE_CLI_PATH` to that executable's absolute path.

```bash
uv sync
uv run pytest
uv run claude-container-review \
  --triage-report examples/triage.json \
  --json-output reports/claude-review.json \
  --markdown-output reports/claude-review.md
```

Expected terminal output:

```text
Claude agent status: completed
Deterministic policy unchanged: True
```

If Claude authentication or the model is unavailable, the command still writes
an advisory artifact with `agent_status: unavailable`. That failure never
changes the input policy decision.

## Input contract

The input must be a JSON object containing `summary`, `findings`, and
`policy_decision`. Only these finding fields enter model context:

- `triage_item_id`, `id`, `kind`, `severity`, and `component`
- `installed_version`, `fixed_version`, and `scanner_status`
- `policy_blocking`
- `location.path` and `location.start_line`

Unknown fields—including possible secret values—are dropped. At most 50
findings are supplied by default, and every model-cited finding ID is checked
against that bounded input.

## CI/CD use

Run this after deterministic Trivy processing and before the human-facing
consolidated report. Treat its output as optional advisory evidence. Never add
the Claude job to a policy authorization expression, and never allow model
failure or model text to convert a blocked or unevaluated decision into an
approval.

The repository's `Container security release` workflow includes an optional
`Claude image advisory triage` job. It runs after the deterministic image scan
for trusted manual dispatches and `main` pushes, consumes the uploaded
`ci-triage.json`, and publishes `claude-image-advisory-<run-id>`. Configure the
GitHub Actions repository secret `ANTHROPIC_API_KEY` before running it. The job
uses `continue-on-error` and is deliberately absent from the release gate.
