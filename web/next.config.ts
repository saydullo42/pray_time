import type { NextConfig } from "next";

// The browser may only talk to / load media from: this site, our API, and the
// two third parties the site uses (Google sign-in, alquran.cloud for the Qur'on text).
const apiOrigin = (() => {
  try {
    return new URL(process.env.NEXT_PUBLIC_API_BASE_URL ?? "").origin;
  } catch {
    return "";
  }
})();

const isProduction = process.env.NODE_ENV === "production";

const contentSecurityPolicy = [
  "default-src 'self'",
  // Next.js hydrates with inline scripts and the theme is set by a tiny inline
  // script, so 'unsafe-inline' is needed here. The rest of the policy is what
  // keeps injected code from sending the sign-in tokens anywhere (connect-src,
  // img-src, form-action, frame-src are all restricted to the origins below).
  "script-src 'self' 'unsafe-inline' https://accounts.google.com/gsi/client",
  "style-src 'self' 'unsafe-inline' https://accounts.google.com/gsi/style",
  `img-src 'self' data: blob: ${apiOrigin} https://*.googleusercontent.com https://accounts.google.com`,
  `media-src 'self' ${apiOrigin}`,
  "font-src 'self' data:",
  `connect-src 'self' ${apiOrigin} https://api.alquran.cloud https://accounts.google.com/gsi/`,
  "frame-src https://accounts.google.com/gsi/",
  "object-src 'none'",
  "base-uri 'self'",
  "form-action 'self'",
  "frame-ancestors 'none'",
  ...(apiOrigin.startsWith("https://") ? ["upgrade-insecure-requests"] : []),
]
  .join("; ")
  .replace(/\s+/g, " ");

const nextConfig: NextConfig = {
  agentRules: false,
  devIndicators: false,
  // Self-contained server (server.js + only the needed node_modules) for the Docker image.
  output: "standalone",
  async headers() {
    // Not in development: React's dev tooling needs eval and websockets.
    if (!isProduction) return [];
    return [
      {
        source: "/:path*",
        headers: [
          { key: "Content-Security-Policy", value: contentSecurityPolicy },
          { key: "X-Content-Type-Options", value: "nosniff" },
          { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
        ],
      },
    ];
  },
};

export default nextConfig;
