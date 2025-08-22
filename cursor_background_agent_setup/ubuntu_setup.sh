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
  libncurses-dev \
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

# Ensure asdf is initialized for future shells (idempotent)
ASDF_INIT_BLOCK_START="# >>> asdf setup (ubuntu_setup.sh) >>>"
ASDF_INIT_BLOCK_END="# <<< asdf setup (ubuntu_setup.sh) <<<"
ASDF_INIT_SNIPPET='export ASDF_DIR="$HOME/.asdf"
. "$ASDF_DIR/asdf.sh"
if [ -f "$ASDF_DIR/completions/asdf.bash" ]; then
  . "$ASDF_DIR/completions/asdf.bash"
fi'

for rc in "$HOME/.bashrc" "$HOME/.profile"; do
  # Create file if it does not exist
  [ -e "$rc" ] || touch "$rc"
  # Append block only if not already present
  if ! grep -Fqx "$ASDF_INIT_BLOCK_START" "$rc"; then
    {
      echo "$ASDF_INIT_BLOCK_START"
      printf '%s\n' "$ASDF_INIT_SNIPPET"
      echo "$ASDF_INIT_BLOCK_END"
    } >> "$rc"
  fi
done

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

printf "\nSetup complete. Detected tool versions (from %s):\n" "$TOOL_VERSIONS_FILE"
if [ -f "$TOOL_VERSIONS_FILE" ]; then
  cat "$TOOL_VERSIONS_FILE"
fi
echo "---"
asdf current || true

echo ""
echo "🎉 Setup complete! Activating asdf and testing tools..."

# Source asdf to make tools available
. "$ASDF_DIR/asdf.sh"

# Test that tools are working
echo "Testing installed tools:"
if command -v elixir >/dev/null 2>&1; then
  echo "✅ Elixir: $(elixir --version | head -1)"
else
  echo "❌ Elixir not found"
fi

if command -v erl >/dev/null 2>&1; then
  echo "✅ Erlang: $(erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell 2>/dev/null)"
else
  echo "❌ Erlang not found"
fi

if command -v mix >/dev/null 2>&1; then
  echo "✅ Mix: $(mix --version | head -1)"
else
  echo "❌ Mix not found"
fi

echo ""
echo "Note: Tools are activated for this script execution. To use them in your current shell:"
echo "   source ~/.asdf/asdf.sh"
echo "Or start a new shell session. Future shell sessions will automatically have access to these tools."
