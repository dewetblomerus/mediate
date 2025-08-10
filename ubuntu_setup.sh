#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Minimal Ubuntu setup for asdf + tools from .tool-versions

if ! command -v apt-get >/dev/null 2>&1; then
  echo "This script is intended for Ubuntu/Debian (apt-get not found)." >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
SUDO=""
if command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
fi

$SUDO apt-get update -y
$SUDO apt-get install -y \
  autoconf \
  automake \
  build-essential \
  ca-certificates \
  curl \
  git \
  gnupg \
  libncurses5-dev \
  libreadline-dev \
  libssl-dev \
  m4 \
  unzip \
  zlib1g-dev

# Install asdf if missing
ASDF_DIR="${ASDF_DIR:-$HOME/.asdf}"
if [ ! -d "$ASDF_DIR" ]; then
  git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR" --branch v0.14.1
fi

# shellcheck source=/dev/null
. "$ASDF_DIR/asdf.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOL_VERSIONS_FILE="$REPO_DIR/.tool-versions"

if [ -f "$TOOL_VERSIONS_FILE" ]; then
  # Add plugins for each tool in .tool-versions
  awk '!/^[[:space:]]*($|#)/ {print $1}' "$TOOL_VERSIONS_FILE" | sort -u | while read -r tool; do
    if ! asdf plugin list | grep -qx "$tool"; then
      asdf plugin add "$tool"
    fi
    if [ "$tool" = "nodejs" ] && [ -f "$ASDF_DIR/plugins/nodejs/bin/import-release-team-keyring" ]; then
      bash "$ASDF_DIR/plugins/nodejs/bin/import-release-team-keyring"
    fi
  done

  asdf install
  asdf reshim
fi

# Prepare Elixir local tooling if available
if command -v mix >/dev/null 2>&1; then
  mix local.hex --force || true
  mix local.rebar --force || true
fi

echo "\nSetup complete. Current tool versions (if any):"
asdf tool-versions || true
