// Extra space under the Qur'on pages, so the footer sits a little lower.
export default function QuranLayout({ children }: { children: React.ReactNode }) {
  return <div className="pb-80 sm:pb-12">{children}</div>;
}
