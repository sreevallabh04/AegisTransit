import type { Metadata } from "next";
import { Outfit, JetBrains_Mono } from "next/font/google";
import "./globals.css";

const outfit = Outfit({
  subsets: ["latin"],
  variable: "--font-outfit",
});

const jetbrains = JetBrains_Mono({
  subsets: ["latin"],
  variable: "--font-jetbrains",
});

export const metadata: Metadata = {
  title: "Smart Bus Admin — Emergency Intelligence",
  description: "Admin analytics for bus accident and passenger health monitoring",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className={`${outfit.variable} ${jetbrains.variable}`}>
      <body className="font-sans min-h-screen">
        <div className="flex min-h-screen flex-col">
          <header className="sticky top-0 z-50 border-b border-slate-800 bg-slate-950/90 backdrop-blur-md">
            <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 sm:px-6">
              <a href="/" className="flex items-center gap-2">
                <span className="text-2xl">🚌</span>
                <span className="text-lg font-semibold tracking-tight text-white">
                  Smart Bus Admin
                </span>
              </a>
              <nav className="flex items-center gap-1">
                <NavLink href="/">Dashboard</NavLink>
                <NavLink href="/bus">Bus sensors</NavLink>
                <NavLink href="/passengers">Passengers</NavLink>
              </nav>
            </div>
          </header>
          <main className="flex-1">{children}</main>
          <footer className="border-t border-slate-800 py-4 text-center text-sm text-slate-500">
            Emergency Intelligence System — Admin view
          </footer>
        </div>
      </body>
    </html>
  );
}

function NavLink({
  href,
  children,
}: {
  href: string;
  children: React.ReactNode;
}) {
  return (
    <a
      href={href}
      className="rounded-lg px-3 py-2 text-sm font-medium text-slate-400 transition hover:bg-slate-800 hover:text-white focus:outline-none focus:ring-2 focus:ring-bus-500"
    >
      {children}
    </a>
  );
}
