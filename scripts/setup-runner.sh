#!/usr/bin/env bash
set -euo pipefail

# GitHub Actions self-hosted runner installer.
# Downloads, extracts, and configures a runner in _runner/ at the repo root.
RUNNER_REPO_URL="https://github.com/bagas-adi/poc-infra-config-ai"
TOKEN="AE6QLCPXIZLMBO6MRC5V23TKBRMAG"
RUNNER_VERSION="2.334.0"
RUNNER_DIR="$(cd "$(dirname "$0")/.." && pwd)/_runner"

# ── Flags ────────────────────────────────────────────────────────────────────

FORCE=false
for arg in "$@"; do
    case "$arg" in
        --force) FORCE=true ;;
        --help|-h)
            echo "Usage: $0 [--force]"
            echo ""
            echo "Downloads and configures a GitHub Actions self-hosted runner."
            echo ""
            echo "Options:"
            echo "  --force   Re-download even if _runner/ already exists"
            echo ""
            echo "Environment variables (optional, will prompt if not set):"
            echo "  RUNNER_REPO_URL   GitHub repository URL (e.g. https://github.com/owner/repo)"
            echo "  RUNNER_TOKEN      Runner registration token from GitHub Settings > Actions > Runners"
            exit 0
            ;;
    esac
done

# ── Detect OS and architecture ───────────────────────────────────────────────

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "$OS" in
    linux)  RUNNER_OS="linux" ;;
    darwin) RUNNER_OS="osx" ;;
    *)
        echo "Error: unsupported OS: $OS"
        exit 1
        ;;
esac

case "$ARCH" in
    x86_64|amd64)  RUNNER_ARCH="x64" ;;
    aarch64|arm64) RUNNER_ARCH="arm64" ;;
    *)
        echo "Error: unsupported architecture: $ARCH"
        exit 1
        ;;
esac

TARBALL="actions-runner-${RUNNER_OS}-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz"
DOWNLOAD_URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${TARBALL}"

echo "Platform: ${RUNNER_OS}/${RUNNER_ARCH}"
echo "Runner version: ${RUNNER_VERSION}"
echo "Download URL: ${DOWNLOAD_URL}"
echo ""

# ── Download and extract ─────────────────────────────────────────────────────

if [ -d "$RUNNER_DIR" ] && [ "$FORCE" = false ]; then
    echo "Runner directory already exists at ${RUNNER_DIR}"
    echo "Use --force to re-download, or skip to configuration."
    echo ""
else
    rm -rf "$RUNNER_DIR"
    mkdir -p "$RUNNER_DIR"

    echo "Downloading runner..."
    curl -fSL -o "/tmp/${TARBALL}" "$DOWNLOAD_URL"

    echo "Extracting to ${RUNNER_DIR}..."
    tar -xzf "/tmp/${TARBALL}" -C "$RUNNER_DIR"
    rm -f "/tmp/${TARBALL}"

    echo "Download complete."
    echo ""
fi

# ── Ensure _runner/ is in .gitignore ─────────────────────────────────────────

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GITIGNORE="${REPO_ROOT}/.gitignore"

if ! grep -qxF '_runner/' "$GITIGNORE" 2>/dev/null; then
    echo '_runner/' >> "$GITIGNORE"
    echo "Added _runner/ to .gitignore"
fi

# ── Configure ────────────────────────────────────────────────────────────────

if [ -f "${RUNNER_DIR}/.runner" ]; then
    echo "Runner is already configured."
    echo ""
else
    REPO_URL="${RUNNER_REPO_URL:-}"
    TOKEN="${RUNNER_TOKEN:-}"

    if [ -z "$REPO_URL" ]; then
        read -rp "GitHub repository URL (e.g. https://github.com/owner/repo): " REPO_URL
    fi

    if [ -z "$TOKEN" ]; then
        echo ""
        echo "Generate a runner token at:"
        echo "  ${REPO_URL}/settings/actions/runners/new"
        echo ""
        read -rp "Runner registration token: " TOKEN
    fi

    cd "$RUNNER_DIR"
    ./config.sh \
        --url "$REPO_URL" \
        --token "$TOKEN" \
        --name "$(hostname)-local" \
        --labels "self-hosted,local" \
        --work "_work" \
        --unattended \
        --replace
fi

# ── Done ─────────────────────────────────────────────────────────────────────

echo ""
echo "============================================"
echo "  Self-hosted runner is ready!"
echo "============================================"
echo ""
echo "Start interactively:"
echo "  cd ${RUNNER_DIR} && ./run.sh"
echo ""
echo "  -- or with Make --"
echo "  make start-runner"
echo ""
echo "Install as a system service (Linux only):"
echo "  cd ${RUNNER_DIR} && sudo ./svc.sh install"
echo "  sudo ./svc.sh start"
echo ""
