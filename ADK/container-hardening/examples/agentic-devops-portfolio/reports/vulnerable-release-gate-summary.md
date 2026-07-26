# Intentionally Vulnerable Release Gate Report

> Training fixture only. This image must not be published or deployed.

## Outcome

- Candidate: `agentic-devops-portfolio:vulnerable-demo`
- Image ID: `sha256:17a440013c6dd3b76b0e9c4a8ebfa08293beceaeabcadffc14118d2ce8ecd65e`
- Base OS: Debian 13.6
- Policy decision: `blocked`
- Publish allowed: `false`
- Docker Hub push: **not attempted**

The release gate returned exit code `1`, so a CI publish job placed after the gate cannot run.

## Trivy image findings

Trivy scanned the real locally built image, including OS packages and embedded secrets.

| Severity | Vulnerability occurrences |
| --- | ---: |
| CRITICAL | 5 |
| HIGH | 60 |
| MEDIUM | 126 |
| LOW | 120 |
| UNKNOWN | 36 |
| **Total** | **347** |

There are 181 unique CVE identifiers. No embedded secrets were detected. The absence of secrets does not override vulnerability or configuration failures.

Representative CRITICAL findings normalized by the agent include:

- `CVE-2026-13221` in `perl-base` 5.40.1-6
- `CVE-2026-42496` in `perl-base` 5.40.1-6
- `CVE-2026-57433` in `perl-base` 5.40.1-6
- `CVE-2026-6653` in `libxml2` 2.12.7+dfsg+really2.9.14-2.1+deb13u3
- `CVE-2026-8376` in `perl-base` 5.40.1-6

The agent reported `policy_decision: not_evaluated`, which is not approval. Its role here is to normalize and explain scanner evidence; it does not authorize publishing.

## Trivy configuration findings

Trivy scanned `Dockerfile.vulnerable` and `deployment.vulnerable.yaml` and found 25 misconfigurations:

| Severity | Misconfigurations |
| --- | ---: |
| HIGH | 7 |
| MEDIUM | 5 |
| LOW | 13 |

The training fixtures intentionally include a root container, privileged execution, host networking and PID access, privilege escalation, dangerous Linux capabilities, a writable root filesystem, and missing runtime safeguards.

## Deterministic release policy

The policy gate blocks when any of these conditions is true:

- at least one HIGH or CRITICAL vulnerability exists;
- at least one HIGH or CRITICAL misconfiguration exists;
- any embedded secret exists; or
- required scan evidence is invalid or unavailable.

This candidate was blocked for both of these independent reasons:

1. 65 HIGH/CRITICAL vulnerability occurrences.
2. 7 HIGH/CRITICAL misconfigurations.

Machine-readable evidence is in `vulnerable-policy-decision.json`. Raw scanner evidence is in `vulnerable-image-trivy.json` and `vulnerable-config-trivy.json`.

## Safe CI/CD ordering

1. Build a local candidate image using an immutable base digest.
2. Scan the image and deployment configuration with Trivy.
3. Normalize and triage findings with the agent.
4. Evaluate the deterministic release policy.
5. Tag and push only when the gate exits `0` and `publish_allowed` is `true`.

For this run, processing stopped at step 4. The local image has only the local tag `agentic-devops-portfolio:vulnerable-demo`; no Docker Hub repository tag was created.
