# 🚨 URGENT: Vercel Still Using pnpm - Advanced Fix

## ❌ Critical Issue
Despite all npm configurations, Vercel logs show:
```
Running "install" command: `pnpm install`...
```

## 🔧 Advanced Solutions Applied

### 1. Aggressive npm Enforcement
```json
{
  "installCommand": "npm install --legacy-peer-deps --prefer-offline --no-audit",
  "buildCommand": "npm install --legacy-peer-deps && npm run build"
}
```

### 2. Enhanced Environment Variables
```json
{
  "PNPM_HOME": "",
  "npm_config_user_agent": "npm", 
  "npm_execpath": "npm",
  "SKIP_ENV_VALIDATION": "1"
}
```

### 3. Directory-Specific .npmrc
Created `/apps/web/.npmrc` with npm enforcement:
```
registry=https://registry.npmjs.org/
pnpm=false
yarn=false
user-agent=npm
```

### 4. Install Script Fallback
Created `install.sh` with forced npm installation

## 🚨 CRITICAL DEPLOYMENT SETTINGS

### Vercel Dashboard Configuration
**MUST VERIFY THESE SETTINGS:**

1. **Root Directory**: `apps/web` ✅
2. **Framework Preset**: Next.js ✅
3. **Build Settings Override**:
   - **Install Command**: `npm install --legacy-peer-deps`
   - **Build Command**: `npm run build`
   - **Output Directory**: `.next`

### Manual Environment Variables
Add these in Vercel Dashboard → Environment Variables:
```
ENABLE_EXPERIMENTAL_COREPACK=0
NPM_CONFIG_PACKAGE_MANAGER=npm
COREPACK_ENABLE_STRICT=0
PNPM_HOME=""
```

## 🔍 Root Cause Analysis

### Why Vercel Ignores installCommand
1. **Auto-Detection Priority**: Vercel may detect pnpm from:
   - Parent directory package.json
   - Turbo dependency requirements
   - Workspace configuration

2. **Monorepo Override**: Vercel might scan parent directories for package managers

3. **Framework Detection**: Next.js + Turbo combination triggers pnpm preference

## 🎯 Alternative Deployment Strategies

### Option A: Force Override in Vercel UI
1. Go to Project Settings → Functions
2. Set Install Command: `npm install --legacy-peer-deps --force`
3. Set Build Command: `npm run build`
4. Override any auto-detection

### Option B: Remove Turbo Temporarily
If pnpm persists, temporarily remove turbo dependency:
1. Edit root package.json
2. Remove turbo from dependencies
3. Use direct Next.js commands

### Option C: Deploy as Single App
1. Copy `/apps/web` contents to new repository
2. Remove monorepo structure
3. Deploy as standalone Next.js app

## 🧪 Testing Commands

### Local Verification
```bash
cd apps/web
rm -rf node_modules package-lock.json
npm install --legacy-peer-deps
npm run build
```

### Package Manager Check
```bash
which npm
npm --version
echo $NPM_CONFIG_PACKAGE_MANAGER
```

## 🚀 Next Steps

### Immediate Actions
1. **Try current deployment** with new configuration
2. **Check Vercel Dashboard** build settings
3. **Manually override** install command in UI if needed

### If Still Fails
1. **Contact Vercel Support** - this appears to be auto-detection override
2. **Deploy as standalone app** without monorepo
3. **Use different build strategy** (remove turbo entirely)

## 📞 Emergency Deployment Plan

### Quick Fix: Standalone Deployment
If monorepo continues causing issues:
1. Create new repo with just `apps/web` contents
2. Remove all turbo references
3. Deploy as simple Next.js app
4. This bypasses all monorepo auto-detection

**Status: MULTIPLE AGGRESSIVE FIXES APPLIED - TESTING REQUIRED 🔧**

---
*Emergency Fix: July 8, 2025 - Pulse CRM Development Team*
*Issue: Vercel auto-detection overriding explicit npm configuration*
