# Agentic DevOps Portfolio — Container Security Summary

## Result

The locally built portfolio image produced no vulnerability, secret, or
Dockerfile misconfiguration findings in the Trivy scan completed on
July 26, 2026.

This is a point-in-time scanner result, not a permanent guarantee and not an
admission-policy approval.

```yaml
image: agentic-devops-portfolio:local
image_id: sha256:3b33669de833a38e33e677cdebfdbb2f46fe0bf547943a2e5e304d9b717c5af6
platform: linux/arm64
operating_system: Alpine 3.24.1
vulnerabilities: 0
secrets: 0
source_secrets: 0
misconfigurations: 0
policy_decision: not_evaluated
```

## Runtime verification

- Container started successfully and reached Docker `healthy` status.
- `/` returned HTTP 200.
- `/healthz` returned `ok`.
- Runtime user is `nginx` rather than root.
- The site listens on unprivileged port 8080.
- The response includes CSP, frame denial, MIME-sniffing protection,
  referrer policy, and permissions policy headers.
- Static content is read-only in the image.
- The NGINX base image is pinned to an immutable manifest digest.

## Evidence

- `trivy-image-2026-07-26.json` — full Trivy image vulnerability and secret scan.
- `trivy-config-2026-07-26.json` — full Trivy Dockerfile/configuration scan.
- `trivy-source-secrets-2026-07-26.json` — build-context secret scan.
- `sbom.cdx.json` — CycloneDX inventory for the packaged image.

## Interpretation

Zero findings means the Trivy database and enabled scanners did not identify a
known issue in this exact image at scan time. A later database update can
produce new findings without any source-code change. CI should therefore scan
every built digest and schedule recurring registry rescans.

`policy_decision: not_evaluated` is not approval. A deployment pipeline should
evaluate the saved evidence against an explicit organization policy before
promoting this image.
