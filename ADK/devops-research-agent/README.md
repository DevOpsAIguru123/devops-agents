# DevOps Deep Research Agent

> **Portfolio prototype:** the generated HTTP service has no application-level
> authentication in this repository. Keep it local unless you add identity,
> authorization, rate limiting, and deployment controls. See
> [production readiness](../../docs/PRODUCTION-READINESS.md).

Google ADK agent for DevOps, SRE, platform engineering, cloud infrastructure,
CI/CD, observability, security, FinOps, and internal developer platform research.

The agent uses ADK's built-in `google_search` tool directly. Its behavior is
adapted from the ADK `deep-search` sample: broad research requests are planned
first, substantial work is split into search and synthesis phases, thin coverage
triggers follow-up search, and final answers should cite or name sources when
grounding metadata is available.

## Agent

Internal ADK name:

```text
devops_deep_research_agent
```

App package:

```text
my_agent
```

## Local Run

```bash
cd ADK/devops-research-agent
uv sync

GOOGLE_CLOUD_PROJECT="YOUR_PROJECT_ID" \
GOOGLE_CLOUD_LOCATION="us-central1" \
GOOGLE_GENAI_USE_VERTEXAI=TRUE \
DEMO_AGENT_MODEL="gemini-2.5-flash" \
adk web --port 8000
```

Open:

```text
http://127.0.0.1:8000
```

## CLI Smoke Test

```bash
GOOGLE_CLOUD_PROJECT="YOUR_PROJECT_ID" \
GOOGLE_CLOUD_LOCATION="us-central1" \
GOOGLE_GENAI_USE_VERTEXAI=TRUE \
DEMO_AGENT_MODEL="gemini-2.5-flash" \
agents-cli run "Research current platform engineering trends. Keep it concise and cite sources when available."
```

## Tests

```bash
uv run python -m pytest tests -q
```
