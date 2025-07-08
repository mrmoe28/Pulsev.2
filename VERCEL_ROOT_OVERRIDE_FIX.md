# 🚨 CRITICAL FIX: Vercel Ignoring installCommand

## ❌ Root Cause Identified
Vercel logs show:
```
> Detected ENABLE_EXPERIMENTAL_COREPACK=1 and "npm@11.4.2" in package.json
Running "install" command: `pnpm install`...
```

**Problem**: Vercel is completely ignoring our `installCommand` in `apps/web/vercel.json`

## 🔧 Definitive Solution Applied

### 1. Created Root-Level vercel.json
Since Vercel is reading from root directory despite "Root Directory" setting:
```json
{
  "installCommand": "npm install --legacy-peer-deps",
  "buildCommand": "cd apps/web && npm install --legacy-peer-deps && npm run build",
  "outputDirectory": "apps/web/.next"
}
```

### 2. Modified Root package.json Scripts
Removed turbo dependency in build commands:
```json
{
  "build": "cd apps/web && npm run build",
  "vercel-build": "cd apps/web && npm run build"
}
```

### 3. Environment Variables Override
```json
{
  "ENABLE_EXPERIMENTAL_COREPACK": "0",
  "NPM_CONFIG_PACKAGE_MANAGER": "npm",
  "COREPACK_ENABLE_STRICT": "0"
}
```

## 🎯 Why This Fixes The Issue

### Vercel Detection Logic
1. **Root Directory Setting Ignored**: Vercel scans from repository root first
2. **turbo Triggers pnpm**: Turbo framework prefers pnpm, causing auto-detection
3. **Corepack Override**: Despite our settings, Vercel enables corepack internally

### Our Solution
1. **Root-Level Override**: Place vercel.json at repository root
2. **Direct Build Commands**: Bypass turbo entirely for Vercel builds
3. **Explicit npm Installation**: Double npm install ensures npm usage

## 📋 Critical Deployment Instructions

### Vercel Dashboard Settings
**IMPORTANT**: You can now deploy with:
- ✅ **Root Directory**: Leave as ROOT (don't set to apps/web)
- ✅ **Framework**: Next.js (still detects correctly)
- ✅ **Build Command**: Uses our root vercel.json configuration
- ✅ **Install Command**: Forces npm via root configuration

### Expected Behavior
```
Running "install" command: `npm install --legacy-peer-deps`...
cd apps/web && npm install --legacy-peer-deps && npm run build
```

## 🚀 Deployment Process

### 1. Configuration Files
- ✅ **Root vercel.json**: Forces npm from repository root
- ✅ **Root package.json**: Direct build commands (no turbo)
- ✅ **apps/web/vercel.json**: Production features (functions, images, security)

### 2. Build Flow
1. Vercel reads root vercel.json
2. Installs with npm at root level
3. Changes to apps/web directory  
4. Runs npm install again (ensures dependencies)
5. Builds Next.js application
6. Uses apps/web/.next as output

### 3. All Features Maintained
- ✅ **API Functions**: Configured in apps/web/vercel.json
- ✅ **Image Optimization**: Full configuration maintained
- ✅ **Security Headers**: All headers and policies active
- ✅ **Performance**: Clean URLs, redirects, caching

## ✅ Expected Success Indicators

### Build Logs Should Show
```
Running "install" command: `npm install --legacy-peer-deps`...
✓ Dependencies installed with npm
cd apps/web && npm install --legacy-peer-deps && npm run build
✓ Building Next.js application
```

### No More Errors
- ❌ No more `pnpm install` commands
- ❌ No more ERR_PNPM_META_FETCH_FAIL
- ❌ No more corepack conflicts

**Status: ROOT-LEVEL OVERRIDE APPLIED - SHOULD FORCE NPM! 🚀**

---
*Critical Fix Applied: July 8, 2025 - Pulse CRM Development Team*
*Solution: Root-level vercel.json override to bypass Vercel auto-detection*
