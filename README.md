# Agentic DevSecOps Reference Pipeline

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Google ADK](https://img.shields.io/badge/Agent-Google_ADK-4285F4)](ADK/container-hardening)
[![Claude Agent SDK](https://img.shields.io/badge/Agent-Claude_Sonnet_5-D97757)](Claude/container-hardening)
[![Security: Trivy](https://img.shields.io/badge/Security-Trivy-1904DA)](https://trivy.dev/)

This repository demonstrates a policy-driven container release workflow that
combines deterministic security controls with a choice of advisory agent:
Google ADK with Vertex AI or the Claude Agent SDK with Sonnet 5. Both complete
pipelines scan code and release configuration before a Docker build, scan the
exact built image, produce three audience-friendly reports, and keep publishing
behind machine-enforced policy and protected human approval.

> **Portfolio/reference implementation:** this is useful as a working starting
> point, but it is not a drop-in production security platform. Review
> [Production readiness](docs/PRODUCTION-READINESS.md) before adapting it to a
> real organization.

## What it demonstrates

- SonarCloud source-code analysis and quality-gate evidence
- Trivy pre-build Dockerfile and deployment misconfiguration scanning
- Trivy post-build container vulnerability and secret scanning
- Fail-closed deterministic release authorization
- Advisory CVE triage with Google ADK and Vertex AI
- Advisory CVE triage with the tool-disabled Claude Agent SDK and Sonnet 5
- Prompt-injection-resistant, bounded, allowlisted agent context
- A protected GitHub Environment approval before registry publication
- HTML/PDF reports for pre-build, image, and consolidated release results
- Immutable commit pinning for every third-party GitHub Action

## Choose an agent implementation

| Pipeline | Advisory runtime | Authentication | Deterministic controls | Workflow |
| --- | --- | --- | --- | --- |
| Google ADK release | Google ADK + Vertex AI | GitHub OIDC/WIF | SonarCloud, Trivy, policy, approval | `Container security release` |
| Claude release | Claude Agent SDK + Sonnet 5 | `ANTHROPIC_API_KEY` secret | Same SonarCloud, Trivy, policy, approval | `Claude comprehensive container release` |

The provider changes only the advisory stage. Scanner evidence, policy
authorization, protected approval, reporting, and publishing remain identical.

## Architecture

```mermaid
flowchart LR
    source["1. Pull request or manual release"]
    sonar["2. SonarCloud code scan"]
    config["3. Trivy pre-build config scan"]
    pre["4. Report 1: code + configuration"]
    build["5. Build local candidate"]
    image["6. Trivy vulnerability + secret scan"]
    policy["7. Deterministic release policy"]
    agent["8. Advisory agent: ADK or Claude"]
    imageReport["9. Report 2: container security"]
    overall["10. Report 3: consolidated release"]
    approval["11. Protected human approval"]
    publish["12. Docker Hub publish"]

    source --> sonar
    source --> config
    sonar --> pre
    config --> pre
    config -->|approved| build
    build --> image
    image --> policy
    image --> agent
    image --> imageReport
    pre --> overall
    policy --> overall
    agent -. "advisory only" .-> overall
    overall --> approval
    policy -->|publish_allowed=true| approval
    approval --> publish
```

The components are numbered `1`–`12`; arrows show their connections.

The model is deliberately outside the authorization path:

```text
Agent proposes → scanners and policy decide → protected gate approves → tool publishes
```

An AI result cannot approve, reject, waive, downgrade, or override a release.
`policy_decision: not_evaluated` is not approval.

## The three reports

| Report | Evidence | Audience |
| --- | --- | --- |
| 1. Pre-build code and configuration | SonarCloud findings and Trivy Dockerfile/deployment misconfigurations | Developers and platform engineers |
| 2. Container image security | Image CVEs, installed/fixed versions, secrets, and deterministic triage | Application and container owners |
| 3. Consolidated release security | Overall decision, every gate, and the non-authoritative agent review | Security teams and release approvers |

Each report is uploaded in HTML and PDF form. Machine-readable JSON, Markdown,
and SARIF evidence is retained separately for automation and audit use.

## Start in five minutes

Follow [the five-minute setup guide](docs/QUICKSTART.md). Google Cloud users
should configure [keyless WIF authentication](docs/AUTHENTICATION.md); Claude
users should add a dedicated Anthropic API key as a GitHub Actions secret.

## See both outcomes

- [Successful hardened-image example](ADK/container-hardening/examples/agentic-devops-portfolio/reports/scan-summary.md)
- [Intentionally blocked vulnerable-image example](ADK/container-hardening/examples/agentic-devops-portfolio/reports/vulnerable-release-gate-summary.md)
- [Commands and expected CI behavior](docs/DEMO-RUNS.md)

The vulnerable Dockerfile and Kubernetes manifest are training fixtures. Never
publish or deploy them.

## CI/CD behavior

- Pull requests run analysis, deterministic gates, the chosen advisory, and all
  three reports. Production approval and publishing are intentionally skipped.
- A manual run on `main` with `approval_test: true` exercises the protected
  `container-production` approval without publishing.
- A manual run on `main` with `publish: true` can publish only after every
  deterministic gate and protected approval succeeds.
- A blocked pre-build configuration decision stops the image build but still
  uploads the pre-build HTML/PDF report.
- Agent failure is visible in reports but cannot turn a blocked or unevaluated
  deterministic decision into approval.

## Security boundaries

- Scanner fields are allowlisted, bounded, and labeled as untrusted data before
  entering model context.
- Claude runs for one turn with tools, MCP servers, workspace settings, and file
  access disabled. Its requested and provider-reported models are recorded.
- Google ADK uses short-lived Vertex AI credentials through WIF on trusted
  branches; long-lived service-account JSON is not required.
- Docker Hub authentication occurs only after policy authorization and protected
  approval. The exact scanned image archive is the image that gets published.
- Third-party GitHub Actions and scanner versions are pinned.

See [SECURITY.md](SECURITY.md), [authentication](docs/AUTHENTICATION.md), and
[production readiness](docs/PRODUCTION-READINESS.md) for the full threat model
and organization-specific work.

## Repository map

| Path | Maturity | Purpose |
| --- | --- | --- |
| `ADK/container-hardening` | Flagship reference | Policy-driven Trivy and ADK container-security pipeline |
| `Claude/container-hardening` | Full comparison | Tool-disabled Claude Agent SDK advisory over sanitized Trivy evidence |
| `.github/workflows/claude-container-image-advisory.yml` | Comprehensive pipeline | SonarCloud, Trivy, Sonnet 5, three reports, approval, and publishing |
| `ADK/container-hardening/examples/agentic-devops-portfolio` | Runnable demo | Hardened and intentionally vulnerable release candidates |
| `ADK/terraform-plan-reviewer` | Portfolio prototype | Read-only Terraform plan review agent |
| `ADK/terraform-drift-detector` | Portfolio prototype | Read-only Terraform drift classifier |
| `ADK/devops-research-agent` | Scaffold/experiment | ADK research-agent example |

## Security and licensing

Read [SECURITY.md](SECURITY.md) before reporting a vulnerability or using the
pipeline for a real release. Original project code is available under the
[MIT License](LICENSE). Google ADK and scaffold-derived files retain their
upstream terms as described in [third-party notices](THIRD_PARTY_NOTICES.md).

## Share the project

The [LinkedIn showcase guide](docs/LINKEDIN-SHOWCASE.md) contains a five-minute
demo sequence, recommended screenshots, an architecture explanation, and a
ready-to-edit post template. It also lists claims to avoid so a portfolio post
does not imply that AI replaces deterministic security policy or human review.
