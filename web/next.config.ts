import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  agentRules: false,
  devIndicators: false,
  // Self-contained server (server.js + only the needed node_modules) for the Docker image.
  output: "standalone",
};

export default nextConfig;
