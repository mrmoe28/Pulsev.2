#!/bin/bash
# Force npm installation for Vercel
echo "Forcing npm installation..."
export COREPACK_ENABLE_STRICT=0
export ENABLE_EXPERIMENTAL_COREPACK=0
export NPM_CONFIG_PACKAGE_MANAGER=npm
export PNPM_HOME=""

# Remove any pnpm traces
rm -f pnpm-lock.yaml
rm -f .pnpmrc

# Install with npm
npm install --legacy-peer-deps --prefer-offline --no-audit
