# Security policy

## Reporting a vulnerability

Do not include credentials, tokens, private images, or production scanner
reports in a public issue. Use the repository owner's private vulnerability
reporting channel when enabled. Otherwise contact the maintainer privately
before disclosure.

Include the affected commit, file and line, realistic attack path, impact, and
a minimal reproduction that does not contain secrets.

## Security model

This repository is a portfolio/reference implementation. Its deterministic
scanners and policy scripts—not the language model—control release
authorization. The ADK/Vertex AI stage is advisory and cannot approve, reject,
waive, suppress, downgrade, publish, or override a finding. A result of
`policy_decision: not_evaluated` is neither a pass nor approval.

Intentionally vulnerable files are limited to clearly named training fixtures,
including `Dockerfile.vulnerable`, `deployment.vulnerable.yaml`, and
`examples/insecure`. They must never be deployed or published.

## Credential policy

- Never commit API keys, service-account JSON, access tokens, webhook URLs,
  account-specific IDs, generated WIF credential files, or `.env` files.
- Prefer GitHub OIDC and WIF over long-lived Google Cloud keys.
- Store Docker Hub and SonarCloud tokens in GitHub Actions secrets.
- Treat reports and build artifacts as potentially sensitive and sanitize them
  before sharing.
- Rotate and revoke any credential immediately if it is exposed, including in
  Git history or logs.

## Supported scope

Security fixes are accepted for the current default branch. Educational
fixtures may intentionally trigger scanners, but an unintended path that lets
those fixtures bypass policy or reach publishing is reportable.

