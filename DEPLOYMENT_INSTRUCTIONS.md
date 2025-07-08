# 🚀 Pulse CRM Deployment Instructions

## Environment Variables for Vercel Dashboard

Copy these environment variables to your Vercel project dashboard:

### Required Variables
```
NODE_ENV=production
NEXTAUTH_SECRET=3SkSzMUYc00vcY7KBvA9TOHEIfwtZgVB9TIP+KkBgPY=
NEXTAUTH_URL=https://your-app-name.vercel.app
```

### Database (Update with your Neon PostgreSQL credentials)
```
POSTGRES_URL=postgresql://username:password@host/database
POSTGRES_PRISMA_URL=postgresql://username:password@host/database?pgbouncer=true&connect_timeout=15
POSTGRES_URL_NON_POOLING=postgresql://username:password@host/database
```

### Email (Update with your SMTP credentials)
```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-gmail-app-password
SMTP_FROM="PulseCRM <noreply@your-domain.com>"
```

## Vercel Project Settings
- **Framework Preset:** Next.js
- **Build Command:** npm run build
- **Output Directory:** .next
- **Install Command:** npm install --legacy-peer-deps
- **Node.js Version:** 20.x

## Quick Deploy Links
- [Import to Vercel](https://vercel.com/new)
- [Neon Database](https://neon.tech)
- [Gmail App Passwords](https://support.google.com/accounts/answer/185833)

## Next Steps
1. Create Vercel project from GitHub repository
2. Add environment variables in Vercel dashboard
3. Configure custom domain (optional)
4. Deploy!

Generated on: 2025-07-08T22:03:56.914Z
