# Demonstration runs

The repository intentionally supports one clean path and one blocked path.
Both produce evidence; only the clean path can reach approval and publishing.

## Successful, non-publishing validation

In **Actions → Container security release → Run workflow**, select:

```text
dockerfile: Dockerfile
publish: false
approval_test: false
```

Expected behavior:

1. SonarCloud and pre-build Trivy configuration scans pass.
2. The candidate image is built locally on the runner.
3. Trivy scans the real image for vulnerabilities and embedded secrets.
4. Deterministic policy authorizes the candidate.
5. The ADK agent produces advisory triage when WIF is available.
6. The overall summary and all three deterministic reports are produced.
7. Approval and publishing are skipped because `publish` is false.

The checked-in [clean scan summary](../ADK/container-hardening/examples/agentic-devops-portfolio/reports/scan-summary.md)
is sanitized, point-in-time sample evidence. Always rerun current scanners.

## Intentionally blocked validation

Run the same workflow with:

```text
dockerfile: Dockerfile.vulnerable
publish: true
approval_test: false
```

Expected behavior:

1. The pre-build configuration gate detects intentional HIGH findings.
2. A pre-build HTML/PDF report is still uploaded.
3. The Docker build, image scan, approval, login, and push jobs are unreachable.
4. The workflow is red by design; this proves fail-closed behavior.

The checked-in [blocked release report](../ADK/container-hardening/examples/agentic-devops-portfolio/reports/vulnerable-release-gate-summary.md)
explains the sample findings and deterministic decision.

> Never weaken the policy merely to make the intentionally blocked run green.

## The three team-facing reports

| Artifact | Contents | Primary audience |
| --- | --- | --- |
| `pre-build-security-report-*` | Sonar code findings plus Trivy misconfigurations | Developers and platform engineers |
| `container-image-security-report-*` | Image CVEs, packages, secrets, and triage | Application and container owners |
| `consolidated-release-security-report-*` | Overall decision, all gate results, and ADK advisory status | Release approvers and security teams |

The separate `Claude container image advisory` workflow produces
`claude-container-image-report-*`. That artifact is a non-authoritative
interpretation of image evidence only; it is not one of the three required
release reports and cannot affect authorization.
