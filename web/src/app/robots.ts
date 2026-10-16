import type { MetadataRoute } from "next";

import { SITE_URL } from "@/lib/site";

// Everything except the public pages sits behind sign-in.
export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: "*",
      allow: ["/", "/privacy", "/delete-account"],
      disallow: ["/login", "/profile", "/tracking", "/quran", "/dua", "/dashboard"],
    },
    sitemap: `${SITE_URL}/sitemap.xml`,
  };
}
