# Agentic DevOps Portfolio

A static, responsive sample portfolio served by an unprivileged NGINX process.

## Build and run

```bash
docker build -t agentic-devops-portfolio:local .
docker run --rm -p 8080:8080 agentic-devops-portfolio:local
curl --fail http://127.0.0.1:8080/healthz
```

## Scan

```bash
mkdir -p reports
trivy image --format json --output reports/trivy-image.json agentic-devops-portfolio:local
trivy config --format json --output reports/trivy-config.json .
```

The image runs as the `nginx` user, listens on port 8080, writes temporary files
under `/tmp`, and sends logs to stdout/stderr.

## Intentionally vulnerable release-gate demonstration

`Dockerfile.vulnerable` and `deployment.vulnerable.yaml` are isolated training
fixtures. They must never be published or deployed. Build and scan them locally:

```bash
docker build --platform linux/amd64 \
  --file Dockerfile.vulnerable \
  --tag agentic-devops-portfolio:vulnerable-demo .

trivy image --format json \
  --output reports/vulnerable-image-trivy.json \
  agentic-devops-portfolio:vulnerable-demo

trivy config --format json \
  --output reports/vulnerable-config-trivy.json \
  .

python3 scripts/evaluate_release.py \
  --image-report reports/vulnerable-image-trivy.json \
  --config-report reports/vulnerable-config-trivy.json \
  --output reports/vulnerable-policy-decision.json
```

The final command exits nonzero when policy blocks the candidate. A CI pipeline
must place `docker push` after this gate using conditional execution, so a
blocked result makes the push step unreachable.

## GitHub Actions release pipeline

The repository workflow `.github/workflows/container-security-release.yml`
uses four isolated jobs:

1. SonarQube source analysis and Quality Gate enforcement.
2. Local image build, separate Trivy image/configuration scans, and the
   deterministic release-policy gate. Every Trivy occurrence is also ranked
   into an advisory triage queue, rendered in the Actions job summary, retained
   as Markdown/JSON/SARIF evidence, and uploaded to GitHub Code Scanning when
   that repository feature is available.
3. A separate Gemini/ADK advisory stage that consumes the bounded,
   secret-safe deterministic triage data and proposes prioritized remediation,
   compatibility checks, attack-path hypotheses, and verification steps.
4. Docker Hub authentication and push, which can run only after the Sonar and
   deterministic container-security jobs succeed and the machine-readable
   decision says `publish_allowed: true`.

The generated `ci-triage.md` is the team-facing report; reviewers can read it
without downloading an artifact. `ci-triage.json` is the complete
machine-readable queue, and `ci-trivy.sarif` supplies repository Security-tab
alerts and pull-request annotations. The triage verdict is deliberately
advisory: scanner output alone cannot prove runtime exploitability, and
`policy_decision: not_evaluated` is never approval. Only
`ci-policy-decision.json` can authorize the publishing job.

If a release is blocked, reporting and evidence upload still run before the job
fails. This gives developers and security reviewers the explanation needed to
remediate the candidate without weakening the fail-closed release gate.

The ADK job is deliberately non-authoritative. A model outage or malformed
model response is recorded as `agent_status: unavailable` and cannot approve,
block, or change a release decision. Pull-request code receives no Gemini API
key; it produces the deterministic report plus an explicit unavailable agent
report. Trusted `main` runs use the `GOOGLE_API_KEY` repository secret to run
the real model-backed stage through the Gemini Developer API.

Configure these GitHub repository settings before running it:

| Type | Name | Value |
| --- | --- | --- |
| Secret | `SONAR_TOKEN` | SonarQube project analysis token |
| Secret | `SONAR_HOST_URL` | SonarQube URL, such as `https://sonar.example.com` |
| Secret | `SONAR_ORGANIZATION` | SonarQube Cloud organization key |
| Secret | `DOCKERHUB_TOKEN` | Docker Hub access token; do not use the account password |
| Secret | `DOCKERHUB_USERNAME` | Docker Hub namespace |
| Secret | `DOCKERHUB_REPOSITORY` | Existing public Docker Hub repository name |
| Secret | `GOOGLE_API_KEY` | Gemini Developer API key used only by trusted `main` runs |

Create a SonarQube project whose key is `agentic-devops-portfolio`, matching
`sonar-project.properties`. For SonarQube Cloud, set `SONAR_ORGANIZATION` to
the organization **key** shown in the SonarQube Cloud organization settings,
not the display name. Configure the Docker Hub repository as public in Docker
Hub; pushing an image does not itself change repository visibility.

To configure the settings without exposing tokens in the repository, edit the
git-ignored `.github/container-release.settings` placeholder file from the
repository root. Then authenticate GitHub CLI and upload the values:

```bash
gh auth login --hostname github.com
.github/scripts/configure-container-release-settings.sh
```

The helper refuses to upload unchanged placeholders and never prints token
values. A safe, commit-ready template is available at
`.github/container-release.settings.example`.

Pull requests run every analysis and gate but never publish. Pushes to `main`
publish the hardened `Dockerfile` only after approval. To prove blocking, run
the workflow manually with `Dockerfile.vulnerable`; the policy step fails,
scan reports are uploaded for review, no release bundle is produced, and the
publish job is skipped even if `publish` was requested.
