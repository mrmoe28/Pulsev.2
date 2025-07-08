# 🚨 EMERGENCY: Vercel Platform Override Issue

## ❌ Critical Problem
Despite complete cleanup and fresh setup, Vercel continues to use pnpm:
```
Error: Command "pnpm install" exited with 1
ERR_PNPM_META_FETCH_FAIL
```

## 🔍 Root Cause Analysis
**Vercel Platform Issue**: Vercel's auto-detection system is completely ignoring our `installCommand` and forcing pnpm usage. This appears to be a platform-level override.

## 🛠️ Emergency Fixes Applied

### 1. Enhanced vercel.json with Aggressive Override
```json
{
  "version": 2,
  "installCommand": "npm run install-deps",
  "env": {
    "ENABLE_EXPERIMENTAL_COREPACK": "0",
    "COREPACK_ENABLE_STRICT": "0",
    "npm_config_user_agent": "npm"
  }
}
```

### 2. Custom Install Script in package.json
```json
{
  "scripts": {
    "install-deps": "npm install --legacy-peer-deps"
  }
}
```

### 3. Install Script Fallback
Created `install-npm.sh` with forced environment variables

### 4. Simplified .npmrc
Removed complex configurations that might trigger pnpm

## 🎯 Manual Vercel Dashboard Override

### CRITICAL: Manual Configuration Required
Since Vercel is ignoring vercel.json, **manually configure in Vercel Dashboard**:

1. **Go to**: Project Settings → General → Build & Development Settings
2. **Override Install Command**: 
   ```
   npm install --legacy-peer-deps --force
   ```
3. **Override Build Command**:
   ```
   npm run build
   ```
4. **Save Settings**

### Environment Variables to Add
```env
ENABLE_EXPERIMENTAL_COREPACK=0
COREPACK_ENABLE_STRICT=0
NPM_CONFIG_PACKAGE_MANAGER=npm
```

## 🔄 Alternative Solutions

### Option A: Deploy Different Branch
1. Create deployment branch with different structure
2. Use Vercel branch-specific settings

### Option B: Use Vercel CLI
```bash
vercel --prod --force
```

### Option C: Contact Vercel Support
This appears to be a platform issue where auto-detection overrides explicit configuration.

### Option D: Deploy as Single App (RECOMMENDED)
1. Copy `apps/web` contents to new repository
2. Remove monorepo structure entirely
3. Deploy as standalone Next.js app

## 🚀 Emergency Deployment Plan

### Immediate Action: Single App Deployment
```bash
# Create new repository structure
mkdir pulse-crm-standalone
cp -r apps/web/* pulse-crm-standalone/
cd pulse-crm-standalone

# Initialize git
git init
git add .
git commit -m "Standalone Pulse CRM deployment"

# Push to new repository
git remote add origin https://github.com/mrmoe28/pulse-crm-standalone.git
git push -u origin main
```

Then deploy the standalone repository to Vercel.

## ✅ Expected Resolution

### If Manual Override Works
```
✓ Using manual install command: npm install --legacy-peer-deps --force
✓ Dependencies installed with npm
✓ Build completed successfully
```

### If Standalone Deployment Required
- New repository without monorepo structure
- Standard Next.js deployment
- No package manager conflicts

## 📞 Next Steps

1. **Try Manual Dashboard Override** (5 minutes)
2. **If fails, create standalone deployment** (10 minutes)
3. **Contact Vercel Support** about auto-detection override issue

**Status: EMERGENCY FIXES APPLIED - MANUAL OVERRIDE REQUIRED 🚨**

---
*Emergency Response: July 8, 2025 - Pulse CRM Development Team*
*Issue: Vercel platform auto-detection overriding explicit npm configuration*
