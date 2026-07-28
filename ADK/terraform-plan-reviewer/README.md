# Terraform Plan Reviewer ADK Agent

> **Portfolio prototype:** model output is advisory and must not be the sole
> authorization for `terraform apply`. Add deterministic policy, protected
> approval, prompt-injection controls, and WIF before production use. See
> [production readiness](../../docs/PRODUCTION-READINESS.md).

Reviews Terraform plan text and returns a structured risk review.

This version uses a Google Cloud account-bound API key with Vertex AI:

```python
client = genai.Client(api_key=key, vertexai=True)
```

The API key must allow `aiplatform.googleapis.com` and be bound to a service
account with Vertex AI permissions.

## Run Locally

```bash
python -m pip install -r requirements.txt
cp .env.example .env
python run_review.py < terraform-plan.txt
```

## Terraform Cloud Plan Review

The GitHub Actions workflow runs a real Terraform Cloud speculative plan from:

```text
ADK/terraform-plan-reviewer/terraform/gcs-sample
```

Terraform Cloud target:

```text
organization: REPLACE_WITH_TFC_ORGANIZATION
workspace: REPLACE_WITH_TFC_WORKSPACE
```

The workflow sends the Terraform Cloud plan output to `run_review.py` without
printing the plan or model response to the Actions log. The agent result is
advisory and cannot authorize `terraform apply`.

Expected output:

```json
{
  "findings": [],
  "evidence": [],
  "recommendation": "safe-to-apply",
  "risk_summary": "..."
}
```
