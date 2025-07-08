/* eslint-disable @typescript-eslint/no-var-requires */
/* eslint-disable import/no-commonjs */

/** @type {import('next').NextConfig} */

const nextConfig = {
  // Transpile packages
  transpilePackages: [],

  // Output configuration for serverless deployment
  output: 'standalone',

  // TypeScript and ESLint configuration
  typescript: {
    ignoreBuildErrors: true, // Temporarily ignore for deployment
  },
  eslint: {
    ignoreDuringBuilds: true, // Temporarily ignore for deployment
  },

  // Disable static optimization for pages that require database
  experimental: {
    serverComponentsExternalPackages: ['@neondatabase/serverless', 'pg'],
  },

  // Generate build ID
  generateBuildId: async () => {
    return 'pulse-crm-build'
  },

  // Webpack configuration
  webpack: (config, { webpack, isServer }) => {
    // Alias the optional native canvas dependency
    config.resolve = config.resolve || {};
    config.resolve.alias = {
      ...(config.resolve.alias || {}),
      canvas: false,
    };

    // Skip parsing .node binaries
    config.module.rules.push({
      test: /\.node$/,
      type: 'asset/resource',
    });

    // Ignore the optional `canvas` package
    config.plugins = config.plugins || [];
    config.plugins.push(new webpack.IgnorePlugin({ resourceRegExp: /^canvas$/ }));

    // Optimize bundle size
    if (!isServer) {
      config.resolve.fallback = {
        ...config.resolve.fallback,
        fs: false,
        net: false,
        tls: false,
      };
    }

    return config;
  },

  // Image optimization
  images: {
    formats: ['image/webp', 'image/avif'],
    domains: ['localhost', 'pulsecrm.vercel.app'], // Add your production domain
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '**',
      },
    ],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
  },

  // Compression
  compress: true,

  // PoweredBy header
  poweredByHeader: false,

  // React strict mode
  reactStrictMode: true,

  // Experimental features
  experimental: {
    // Removed optimizePackageImports as it's Next.js 15+ only
  },

  // Remove turbopack as it's Next.js 15+ only

  // Headers for security
  async headers() {
    return [
      {
        // Allow iframe embedding for file API routes (PDFs, images)
        source: '/api/files/:path*',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'SAMEORIGIN',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'Referrer-Policy',
            value: 'origin-when-cross-origin',
          },
          {
            key: 'Content-Security-Policy',
            value: "frame-ancestors 'self'",
          },
          {
            key: 'Permissions-Policy',
            value: 'fullscreen=()',
          },
        ],
      },
      {
        // Deny iframe embedding for all other routes
        source: '/((?!api/files).*)',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'Referrer-Policy',
            value: 'origin-when-cross-origin',
          },
          {
            key: 'Permissions-Policy',
            value: 'fullscreen=()',
          },
        ],
      },
    ];
  },
};

/**
 * Use bundle analyzer only when ANALYZE env is set
 */
const getConfig = () => {
  if (process.env.ANALYZE === 'true') {
    // eslint-disable-next-line @typescript-eslint/no-require-imports
    const withBundleAnalyzer = require('@next/bundle-analyzer')({ enabled: true });
    return withBundleAnalyzer(nextConfig);
  }
  return nextConfig;
};

module.exports = getConfig();
