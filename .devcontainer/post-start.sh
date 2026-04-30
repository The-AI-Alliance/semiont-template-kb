#!/usr/bin/env bash
set -euo pipefail

# Runs on every Codespace start (creation and resume). Brings up the backend
# stack via backend.yml + the Codespace overrides + the observe profile.

cd "$(git rev-parse --show-toplevel)"

ENV_FILE=".devcontainer/.env"
ADMIN_FILE=".devcontainer/admin.json"
if [[ ! -f "$ENV_FILE" || ! -f "$ADMIN_FILE" ]]; then
  echo "ERROR: $ENV_FILE or $ADMIN_FILE missing — re-run .devcontainer/post-create.sh"
  exit 1
fi

set -a
# shellcheck source=/dev/null
. "$ENV_FILE"
ADMIN_EMAIL=$(awk -F'"' '/"email"/{print $4}' "$ADMIN_FILE")
ADMIN_PASSWORD=$(awk -F'"' '/"password"/{print $4}' "$ADMIN_FILE")
set +a

print_banner() {
  cat <<EOF

──────────────────────────────────────────────────────────────────────
Semiont admin credentials (saved to $ADMIN_FILE)
──────────────────────────────────────────────────────────────────────
  email:    $ADMIN_EMAIL
  password: $ADMIN_PASSWORD
──────────────────────────────────────────────────────────────────────

EOF
}

# Print credentials up front so the user sees them even if compose fails.
print_banner

if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
  cat <<EOF
WARNING: ANTHROPIC_API_KEY is not set.
  Add it as a Codespaces user secret at:
    https://github.com/settings/codespaces
  Then rebuild the container (Codespaces: Rebuild Container).

EOF
fi

echo "Bringing up backend stack (compose up -d --wait)..."

COMPOSE_OK=true
if ! docker compose \
  -f .semiont/compose/backend.yml \
  -f .devcontainer/docker-compose.codespaces.yml \
  --profile observe \
  up -d --wait; then
  COMPOSE_OK=false
fi

# Best-effort embedding-model pull (idempotent, ignored on failure)
docker compose -f .semiont/compose/backend.yml exec -T ollama \
  ollama pull nomic-embed-text 2>/dev/null || true

if $COMPOSE_OK; then
  cat <<EOF

Semiont stack is up.
  Backend API    → port 4000  (forwarded by Codespaces)
  Jaeger UI      → port 16686
  Neo4j Browser  → port 7474   (login: neo4j / localpass)

EOF
  print_banner
  echo "Bring down with:  docker compose -f .semiont/compose/backend.yml --profile observe down"
else
  cat <<EOF

ERROR: docker compose up did not bring all services healthy.

Diagnostics:
  docker compose -f .semiont/compose/backend.yml ps
  docker compose -f .semiont/compose/backend.yml logs --tail=200 backend
  docker compose -f .semiont/compose/backend.yml logs --tail=200 worker
  docker compose -f .semiont/compose/backend.yml logs --tail=200 smelter

After fixing, retry:
  bash .devcontainer/post-start.sh

EOF
  print_banner
  exit 1
fi
