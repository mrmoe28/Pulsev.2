# 🚀 Pulse CRM - Automated Deployment Scripts

This directory contains automated deployment scripts to prepare your Pulse CRM for Vercel deployment with zero configuration hassle.

## Quick Start

### Option 1: Node.js Deployment Utility (Recommended)
```bash
npm run deploy:prepare
```

### Option 2: Bash Deployment Script
```bash
npm run deploy:bash
# or
./deploy-to-vercel.sh
```

## What These Scripts Do

### ✅ **Automated Tasks**
- **Environment Validation** - Checks Node.js and NPM versions
- **Dependency Analysis** - Verifies packages and identifies issues
- **Build Testing** - Runs production build locally
- **Environment Variables** - Generates secure production config
- **Git Integration** - Handles uncommitted changes
- **Security Checks** - Validates configuration files
- **Documentation** - Creates deployment instructions

### 📁 **Generated Files**
- `.env.production` - Production environment variables
- `DEPLOYMENT_INSTRUCTIONS.md` - Copy/paste guide for Vercel
- `DEPLOYMENT_CHECKLIST.md` - Step-by-step deployment tasks

## Deployment Process

### Step 1: Run Preparation Script
```bash
npm run deploy:prepare
```

### Step 2: Follow Generated Instructions
1. Open `DEPLOYMENT_INSTRUCTIONS.md`
2. Copy environment variables to Vercel dashboard
3. Configure project settings
4. Deploy!

## Manual Deployment Steps

If you prefer to deploy manually:

### 1. Environment Variables
Set these in your Vercel dashboard:

```env
NODE_ENV=production
NEXTAUTH_SECRET=your-32-character-secret
NEXTAUTH_URL=https://your-app-name.vercel.app
POSTGRES_URL=your-neon-database-url
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-gmail-app-password
```

### 2. Vercel Project Settings
- **Framework:** Next.js
- **Build Command:** `npm run build`
- **Install Command:** `npm install --legacy-peer-deps`
- **Output Directory:** `.next`
- **Node.js Version:** 20.x

### 3. Database Setup
1. Create Neon PostgreSQL database
2. Update `POSTGRES_URL` with connection string
3. Run database migration after deployment

## Features Ready for Production

### 🏢 **Solar CRM Capabilities**
- Customer management and lead tracking
- Contractor scheduling and management
- Contract creation and e-signatures
- Document management system
- Project pipeline (quote → install → PTO)
- Financial tracking and reporting

### 🔒 **Security Features**
- Multi-tenant organization isolation
- Role-based access control
- Secure password hashing
- JWT session management
- CSRF protection
- Security headers configured

### ⚡ **Performance Optimizations**
- Next.js 14 with App Router
- Image optimization
- Code splitting
- Compression enabled
- CDN integration via Vercel

## Troubleshooting

### Build Failures
- Run `npm run build` locally first
- Check `DEPLOYMENT_INSTRUCTIONS.md` for environment variables
- Verify Node.js version is 18+ 

### Database Issues
- Ensure Neon PostgreSQL URL is correct
- Check connection string format
- Verify database is accessible

### Authentication Problems
- Confirm `NEXTAUTH_SECRET` is set
- Verify `NEXTAUTH_URL` matches deployment URL
- Check domain configuration

## Support

- **Vercel Docs:** https://vercel.com/docs
- **Next.js Docs:** https://nextjs.org/docs
- **Neon Database:** https://neon.tech/docs

## Quick Deploy Links

- [Import to Vercel](https://vercel.com/new)
- [Create Neon Database](https://neon.tech)
- [Gmail App Passwords](https://support.google.com/accounts/answer/185833)

---

**🎯 Your Pulse CRM is production-ready and optimized for solar contractor workflows!**