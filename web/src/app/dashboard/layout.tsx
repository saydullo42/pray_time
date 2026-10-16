import type { Metadata } from "next";

// A private page for the owner: keep it out of search results.
export const metadata: Metadata = {
  title: "Dashboard — Pray Time",
  robots: { index: false, follow: false },
};

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return children;
}
