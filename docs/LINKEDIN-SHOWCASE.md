# LinkedIn showcase guide

Use this guide to present the project as a working DevSecOps reference without
exposing credentials or overstating what the AI stage controls.

## The story in one sentence

I built two policy-driven container release pipelines—Google ADK/Vertex AI and
Claude Agent SDK/Sonnet 5—that use AI to explain deterministic SonarCloud and
Trivy evidence while policy and protected human approval retain release control.

## Five-minute demonstration

1. Show the numbered architecture diagram in the root README.
2. Open a successful `Claude comprehensive container release` or
   `Container security release` run.
3. Point out the parallel SonarCloud and pre-build Trivy configuration stages.
4. Open the pre-build, image-security, and consolidated HTML/PDF artifacts.
5. Show that the agent is advisory and that the report records its status and
   scoped deterministic policy decision separately.
6. Show an intentionally blocked `Dockerfile.vulnerable` run and explain that
   reporting continues while building or publishing is denied.
7. Explain that approval and publishing are skipped on pull requests and are
   available only through trusted `main` release events.

## Recommended screenshots

Capture only repository pages that contain no secret values or account-specific
configuration:

1. The numbered architecture diagram.
2. A successful workflow graph showing every security and reporting stage.
3. The top of the consolidated report with the overall deterministic decision.
4. An intentionally blocked pre-build summary.
5. The Claude report lines showing `requested_model: claude-sonnet-5`, verified
   provider model, completed status, and `policy_unchanged: true`.

Crop out browser tabs, personal bookmarks, billing details, local paths,
temporary artifact URLs, project/account identifiers, and secret names or
values that are not needed for the story.

## Suggested LinkedIn post

> I built an agentic DevSecOps container release reference with two complete
> implementations: Google ADK + Vertex AI and Claude Agent SDK + Sonnet 5.
>
> The pipeline scans source code with SonarCloud, checks Docker/Kubernetes
> configuration with Trivy before building, scans the exact container image for
> vulnerabilities and secrets, applies deterministic release policy, and
> generates three HTML/PDF reports for engineering, security, and approvers.
>
> The key design decision: AI is advisory, not authoritative. It can prioritize
> findings, explain risk, and propose verification steps—but it cannot approve,
> waive, publish, or override policy. Publishing requires deterministic approval
> plus a protected GitHub Environment review.
>
> I also included an intentionally vulnerable candidate to demonstrate that the
> pipeline blocks unsafe releases while preserving evidence and reports.
>
> Stack: GitHub Actions, Docker, Trivy, SonarCloud, Google ADK/Vertex AI, Claude
> Agent SDK/Sonnet 5, Python, SARIF, HTML/PDF reporting, WIF, and Docker Hub.
>
> Repository: <PUBLIC_REPOSITORY_URL>
>
> #DevSecOps #PlatformEngineering #ContainerSecurity #GitHubActions
> #AgenticAI #GoogleCloud #ClaudeAI #Trivy #SonarCloud

## Accurate claims

- “AI-assisted triage over deterministic scanner evidence.”
- “Policy-driven release authorization with protected human approval.”
- “The agent is tool-disabled, bounded, and non-authoritative.”
- “The sample demonstrates successful and intentionally blocked outcomes.”
- “This is a portfolio/reference implementation with documented production
  requirements.”

Avoid claiming that the agent proves exploitability, eliminates all
vulnerabilities, replaces security review, autonomously approves releases, or
makes the reference implementation production-ready for every organization.

## Before publishing

- Make the repository public only after reviewing its full history for secrets.
- Confirm GitHub Actions logs and checked-in reports contain no account IDs,
  credentials, tokens, billing information, or local filesystem paths.
- Replace `<PUBLIC_REPOSITORY_URL>` in the post, not in committed source.
- Verify `LICENSE`, `SECURITY.md`, and `THIRD_PARTY_NOTICES.md` render correctly.
- Keep the intentionally vulnerable fixtures clearly labeled and never publish
  their images to a registry.
