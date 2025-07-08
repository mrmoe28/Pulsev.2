#!/bin/bash
set -e

echo "🔧 Forcing npm installation..."

# Remove any pnpm traces
rm -f pnpm-lock.yaml .pnpmrc
export ENABLE_EXPERIMENTAL_COREPACK=0
export COREPACK_ENABLE_STRICT=0
export NPM_CONFIG_PACKAGE_MANAGER=npm

# Verify npm is being used
echo "Package manager: $(which npm)"
echo "npm version: $(npm --version)"

# Install with npm
npm install --legacy-peer-deps --verbose

echo "✅ npm installation complete"
