#!/usr/bin/env bash
set -euo pipefail

# ── UXSpecialty v2 Deploy Script ─────────────────────────────
# Usage: ./scripts/deploy.sh
# Prerequisites: .env file exists, Docker & Docker Compose installed

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[DEPLOY]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()  { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

# ── Pre-flight Checks ────────────────────────────────────────
command -v docker >/dev/null 2>&1 || err "Docker is not installed"
docker compose version >/dev/null 2>&1 || err "Docker Compose v2 is not installed"
[[ -f .env ]] || err ".env file not found. Copy .env.template to .env and fill in values."

# ── Registry Login ───────────────────────────────────────────
if [[ -n "${DO_REGISTRY_TOKEN:-}" ]]; then
    log "Logging in to DigitalOcean Container Registry..."
    echo "$DO_REGISTRY_TOKEN" | docker login registry.digitalocean.com -u "$DO_REGISTRY_TOKEN" --password-stdin
else
    warn "DO_REGISTRY_TOKEN not set. Skipping registry login."
    warn "If pull fails, run: echo YOUR_TOKEN | docker login registry.digitalocean.com -u YOUR_TOKEN --password-stdin"
fi

# ── Pull Latest Images ───────────────────────────────────────
log "Pulling latest images..."
docker compose pull api portal admin

# ── Deploy Services ──────────────────────────────────────────
log "Starting services..."
docker compose up -d --remove-orphans

# ── Health Check ─────────────────────────────────────────────
log "Waiting for services to be healthy..."
sleep 5

# Check all containers are running
SERVICES=("npm" "api" "portal" "admin" "mysql")
ALL_OK=true

for svc in "${SERVICES[@]}"; do
    STATUS=$(docker compose ps "$svc" --format json 2>/dev/null | grep -o '"Health":"[^"]*"' | head -1 || echo "unknown")
    RUNNING=$(docker compose ps "$svc" --format json 2>/dev/null | grep -o '"State":"[^"]*"' | head -1 || echo "unknown")

    if echo "$RUNNING" | grep -q "running"; then
        log "$svc is running"
    else
        warn "$svc may not be running: $RUNNING"
        ALL_OK=false
    fi
done

# ── Cleanup Old Images ───────────────────────────────────────
log "Cleaning up unused images..."
docker image prune -f >/dev/null 2>&1

if $ALL_OK; then
    log "Deploy completed successfully!"
else
    warn "Some services may need attention. Run: docker compose ps"
fi
