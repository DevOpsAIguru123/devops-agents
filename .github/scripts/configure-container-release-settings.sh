#!/usr/bin/env bash
set -euo pipefail

settings_file="${1:-.github/container-release.settings}"
repository="${2:-}"

if [[ ! -f "$settings_file" ]]; then
  echo "Settings file not found: $settings_file" >&2
  exit 1
fi

read_setting() {
  local name="$1"
  sed -n "s/^${name}=//p" "$settings_file" | tail -n 1
}

sonar_host_url="$(read_setting SONAR_HOST_URL)"
sonar_token="$(read_setting SONAR_TOKEN)"
dockerhub_username="$(read_setting DOCKERHUB_USERNAME)"
dockerhub_repository="$(read_setting DOCKERHUB_REPOSITORY)"
dockerhub_token="$(read_setting DOCKERHUB_TOKEN)"

require_real_value() {
  local name="$1"
  local value="$2"
  if [[ -z "$value" || "$value" == REPLACE_ME* || "$value" == "https://sonarqube.example.com" ]]; then
    echo "Replace the placeholder for $name in $settings_file" >&2
    exit 1
  fi
}

require_real_value SONAR_HOST_URL "$sonar_host_url"
require_real_value SONAR_TOKEN "$sonar_token"
require_real_value DOCKERHUB_USERNAME "$dockerhub_username"
require_real_value DOCKERHUB_REPOSITORY "$dockerhub_repository"
require_real_value DOCKERHUB_TOKEN "$dockerhub_token"

gh auth status --hostname github.com >/dev/null

if [[ -z "$repository" ]]; then
  repository="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
fi

printf '%s' "$sonar_token" | gh secret set SONAR_TOKEN --repo "$repository"
printf '%s' "$dockerhub_token" | gh secret set DOCKERHUB_TOKEN --repo "$repository"
printf '%s' "$sonar_host_url" | gh secret set SONAR_HOST_URL --repo "$repository"
printf '%s' "$dockerhub_username" | gh secret set DOCKERHUB_USERNAME --repo "$repository"
printf '%s' "$dockerhub_repository" | gh secret set DOCKERHUB_REPOSITORY --repo "$repository"

echo "Configured GitHub Actions settings for $repository:"
echo "- secrets: SONAR_TOKEN, SONAR_HOST_URL, DOCKERHUB_TOKEN, DOCKERHUB_USERNAME, DOCKERHUB_REPOSITORY"
