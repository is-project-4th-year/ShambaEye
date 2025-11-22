'use client';

import { useQuery } from '@tanstack/react-query';
import axios from 'axios';

interface Stats {
    totalUsers: number;
    totalScans: number;
    activeUsers: number;
    successRate: number;
}

export default function DashboardCards() {
    const { data: stats, isLoading, error } = useQuery<Stats>({
        queryKey: ['dashboard-stats'],
        queryFn: async () => {
            const [usersRes, scansRes] = await Promise.all([
                axios.get('/api/users'),
                axios.get('/api/scans')
            ]);

            const users = usersRes.data.users || [];
            const scans = scansRes.data.scans || [];

            // Calculate real stats
            const totalUsers = users.length;
            const totalScans = scans.length;

            // Active users: users with at least one scan in the last 30 days
            const thirtyDaysAgo = new Date();
            thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

            const activeUsers = users.filter((user: any) => {
                // Check if user has any scans in the last 30 days
                const userScans = scans.filter((scan: any) =>
                    scan.userId === user.uid &&
                    scan.timestamp &&
                    new Date(scan.timestamp._seconds * 1000) > thirtyDaysAgo
                );
                return userScans.length > 0;
            }).length;

            // Success rate: percentage of scans with high confidence (>80%)
            const successfulScans = scans.filter((scan: any) =>
                scan.confidence && scan.confidence > 0.8
            ).length;
            const successRate = totalScans > 0 ? Math.round((successfulScans / totalScans) * 100) : 0;

            return {
                totalUsers,
                totalScans,
                activeUsers,
                successRate
            };
        },
        refetchInterval: 30000, // Refetch every 30 seconds
    });

    if (isLoading) {
        return (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                {[...Array(4)].map((_, index) => (
                    <div key={index} className="bg-white p-6 rounded-lg shadow-lg border border-gray-100 animate-pulse">
                        <div className="flex items-center justify-between">
                            <div>
                                <div className="h-4 bg-gray-200 rounded w-20 mb-2"></div>
                                <div className="h-8 bg-gray-200 rounded w-12"></div>
                            </div>
                            <div className="bg-gray-200 p-3 rounded-full w-16 h-16"></div>
                        </div>
                    </div>
                ))}
            </div>
        );
    }

    if (error) {
        return (
            <div className="bg-red-50 border border-red-200 rounded-lg p-6">
                <div className="flex items-center">
                    <div className="text-red-500 text-2xl mr-3">⚠️</div>
                    <div>
                        <h3 className="text-red-800 font-medium">Failed to load dashboard data</h3>
                        <p className="text-red-600 text-sm mt-1">Please check your connection and try again.</p>
                    </div>
                </div>
            </div>
        );
    }

    const cards = [
        {
            title: "Total Users",
            value: stats?.totalUsers || 0,
            icon: "👥",
            color: "bg-blue-500",
            description: "Registered farmers"
        },
        {
            title: "Total Scans",
            value: stats?.totalScans || 0,
            icon: "🔍",
            color: "bg-green-500",
            description: "Plant analyses performed"
        },
        {
            title: "Active Users",
            value: stats?.activeUsers || 0,
            icon: "🔥",
            color: "bg-orange-500",
            description: "Active in last 30 days"
        },
        {
            title: "Success Rate",
            value: `${stats?.successRate || 0}%`,
            icon: "📈",
            color: "bg-purple-500",
            description: "High confidence analyses"
        }
    ];

    return (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {cards.map((card, index) => (
                <div key={index} className="bg-white p-6 rounded-lg shadow-lg border border-gray-100 hover:shadow-xl transition-shadow duration-200">
                    <div className="flex items-center justify-between">
                        <div>
                            <p className="text-gray-600 text-sm font-medium">{card.title}</p>
                            <p className="text-3xl font-bold text-gray-900 mt-2">{card.value}</p>
                            <p className="text-gray-400 text-xs mt-1">{card.description}</p>
                        </div>
                        <div className={`${card.color} p-3 rounded-full text-white text-2xl`}>
                            {card.icon}
                        </div>
                    </div>
                </div>
            ))}
        </div>
    );
}