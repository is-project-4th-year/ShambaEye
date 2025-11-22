'use client';

import Link from "next/link";
import { usePathname } from "next/navigation";

export default function Sidebar() {
    const pathname = usePathname();

    const isActive = (path: string) => pathname === path;

    return (
        <div className="w-64 h-screen bg-green-800 text-white flex flex-col">
            <div className="p-6 border-b border-green-700">
                <h1 className="text-2xl font-bold">🌱 ShambaEye</h1>
                <p className="text-green-200 text-sm mt-1">Admin Panel</p>
            </div>

            <nav className="flex-1 p-4 space-y-2">
                <Link
                    href="/"
                    className={`flex items-center p-3 rounded-lg transition-colors ${isActive('/') ? 'bg-green-700 text-white' : 'text-green-100 hover:bg-green-700'
                        }`}
                >
                    📊 Dashboard
                </Link>

                <Link
                    href="/analytics"
                    className={`flex items-center p-3 rounded-lg transition-colors ${isActive('/analytics') ? 'bg-green-700 text-white' : 'text-green-100 hover:bg-green-700'
                        }`}
                >
                    📈 Analytics
                </Link>

                <Link
                    href="/users"
                    className={`flex items-center p-3 rounded-lg transition-colors ${isActive('/users') ? 'bg-green-700 text-white' : 'text-green-100 hover:bg-green-700'
                        }`}
                >
                    👥 Users
                </Link>
            </nav>

            <div className="p-4 border-t border-green-700">
                <button className="w-full bg-red-600 hover:bg-red-500 p-3 rounded-lg transition-colors flex items-center justify-center gap-2">
                    🚪 Logout
                </button>
            </div>
        </div>
    );
}