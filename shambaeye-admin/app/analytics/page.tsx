'use client';
import { useEffect, useState } from 'react';
import Sidebar from '../../components/Sidebar';
import {
    BarChart, Bar, XAxis, YAxis, Tooltip, CartesianGrid,
    PieChart, Pie, Cell, LineChart, Line, ResponsiveContainer,
    Legend
} from 'recharts';
import axios from 'axios';

interface Scan {
    disease: string;
    severity: string;
    confidence: number;
    isOnline: boolean;
    userId: string;
    timestamp: { _seconds: number; _nanoseconds: number };
    treatment: {
        type: string;
        symptoms: string;
        chemical_treatment: string;
        organic_treatment: string;
        prevention: string;
    };
}

interface User {
    uid: string;
    location: string;
    farmSize: number;
    fullName: string;
}

// Define proper types for chart data
interface DiseaseData {
    disease: string;
    count: number;
}

interface SeverityData {
    severity: string;
    count: number;
}

interface MonthlyData {
    month: string;
    scans: number;
}

interface TreatmentData {
    type: string;
    count: number;
}

interface ConfidenceData {
    range: string;
    count: number;
}

interface OnlineOfflineData {
    type: string;
    count: number;
}

interface UserActivityData {
    user: string;
    scans: number;
    location: string;
}

export default function Analytics() {
    const [scans, setScans] = useState<Scan[]>([]);
    const [users, setUsers] = useState<User[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchData = async () => {
            try {
                const [scansRes, usersRes] = await Promise.all([
                    axios.get('/api/scans'),
                    axios.get('/api/users')
                ]);
                setScans(scansRes.data.scans || []);
                setUsers(usersRes.data.users || []);
            } catch (error) {
                console.error('Error fetching data:', error);
            } finally {
                setLoading(false);
            }
        };
        fetchData();
    }, []);

    if (loading) {
        return (
            <div className="flex min-h-screen bg-gray-50">
                <Sidebar />
                <div className="flex-1 p-8">
                    <div className="animate-pulse">
                        <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
                        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                            <div className="h-80 bg-gray-200 rounded"></div>
                            <div className="h-80 bg-gray-200 rounded"></div>
                        </div>
                    </div>
                </div>
            </div>
        );
    }

    // Filter out scans with no disease data
    const validScans = scans.filter(scan => scan && scan.disease);

    // 1. Disease Distribution with safe data processing
    const diseaseDistribution = validScans.reduce((acc: Record<string, number>, scan) => {
        if (scan.disease) {
            const disease = scan.disease.replace('Tomato___', '').replace(/_/g, ' ');
            acc[disease] = (acc[disease] || 0) + 1;
        }
        return acc;
    }, {});

    const diseaseData: DiseaseData[] = Object.entries(diseaseDistribution)
        .map(([disease, count]) => ({ disease, count }))
        .sort((a, b) => b.count - a.count);

    // 2. Severity Analysis with safe defaults
    const severityData = validScans.reduce((acc: Record<string, number>, scan) => {
        const severity = scan.severity || 'Unknown';
        acc[severity] = (acc[severity] || 0) + 1;
        return acc;
    }, {});

    const severityChartData: SeverityData[] = Object.entries(severityData)
        .map(([severity, count]) => ({ severity, count }));

    // 3. Monthly Scan Trends with safe date handling
    const monthlyData = validScans.reduce((acc: Record<string, number>, scan) => {
        if (scan.timestamp && scan.timestamp._seconds) {
            const date = new Date(scan.timestamp._seconds * 1000);
            const monthYear = `${date.getMonth() + 1}/${date.getFullYear()}`;
            acc[monthYear] = (acc[monthYear] || 0) + 1;
        }
        return acc;
    }, {});

    const monthlyChartData: MonthlyData[] = Object.entries(monthlyData)
        .map(([month, count]) => ({ month, scans: count }))
        .sort((a, b) => {
            const [aMonth, aYear] = a.month.split('/').map(Number);
            const [bMonth, bYear] = b.month.split('/').map(Number);
            return aYear - bYear || aMonth - bMonth;
        });

    // 4. Treatment Type Analysis with safe access
    const treatmentTypeData = validScans.reduce((acc: Record<string, number>, scan) => {
        const type = scan.treatment?.type || 'Unknown';
        acc[type] = (acc[type] || 0) + 1;
        return acc;
    }, {});

    const treatmentChartData: TreatmentData[] = Object.entries(treatmentTypeData)
        .map(([type, count]) => ({ type, count }));

    // 5. Confidence Level Analysis
    const confidenceRanges = validScans.reduce((acc: Record<string, number>, scan) => {
        const confidence = scan.confidence || 0;
        let range = '';
        if (confidence >= 0.9) range = '90-100%';
        else if (confidence >= 0.8) range = '80-89%';
        else if (confidence >= 0.7) range = '70-79%';
        else range = 'Below 70%';

        acc[range] = (acc[range] || 0) + 1;
        return acc;
    }, {});

    const confidenceData: ConfidenceData[] = Object.entries(confidenceRanges)
        .map(([range, count]) => ({ range, count }));

    // 6. Online vs Offline Analysis
    const onlineOfflineData = validScans.reduce((acc: Record<string, number>, scan) => {
        const type = scan.isOnline ? 'Online' : 'Offline';
        acc[type] = (acc[type] || 0) + 1;
        return acc;
    }, {});

    const onlineOfflineChartData: OnlineOfflineData[] = Object.entries(onlineOfflineData)
        .map(([type, count]) => ({ type, count }));

    // 7. User Activity (Scans per User)
    const userActivity = validScans.reduce((acc: Record<string, number>, scan) => {
        if (scan.userId) {
            acc[scan.userId] = (acc[scan.userId] || 0) + 1;
        }
        return acc;
    }, {});

    const userActivityData: UserActivityData[] = Object.entries(userActivity)
        .map(([userId, count]) => {
            const user = users.find(u => u.uid === userId);
            return {
                user: user?.fullName || 'Unknown User',
                scans: count,
                location: user?.location || 'Unknown'
            };
        })
        .sort((a, b) => b.scans - a.scans)
        .slice(0, 5); // Top 5 users

    const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884D8', '#82CA9D'];

    // Key Metrics
    const totalScans = validScans.length;
    const uniqueDiseases = new Set(validScans.map(scan => scan.disease)).size;
    const averageConfidence = validScans.length > 0
        ? validScans.reduce((acc, scan) => acc + (scan.confidence || 0), 0) / validScans.length
        : 0;
    const onlineScans = validScans.filter(scan => scan.isOnline).length;

    // Custom label renderer for PieChart
    const renderCustomizedLabel = ({
        cx, cy, midAngle, innerRadius, outerRadius, percent
    }: any) => {
        const RADIAN = Math.PI / 180;
        const radius = innerRadius + (outerRadius - innerRadius) * 0.5;
        const x = cx + radius * Math.cos(-midAngle * RADIAN);
        const y = cy + radius * Math.sin(-midAngle * RADIAN);

        return (
            <text x={x} y={y} fill="white" textAnchor={x > cx ? 'start' : 'end'} dominantBaseline="central">
                {`${(percent * 100).toFixed(0)}%`}
            </text>
        );
    };

    return (
        <div className="flex min-h-screen bg-gray-50">
            <Sidebar />
            <div className="flex-1 p-8">
                <div className="mb-8">
                    <h1 className="text-3xl font-bold text-gray-900">Analytics Dashboard</h1>
                    <p className="text-gray-600 mt-2">
                        {validScans.length > 0
                            ? `Analyzing ${validScans.length} plant health scans`
                            : 'No scan data available'}
                    </p>
                </div>

                {validScans.length === 0 ? (
                    <div className="bg-white p-8 rounded-lg shadow-lg text-center">
                        <div className="text-6xl mb-4">🔍</div>
                        <h2 className="text-2xl font-bold text-gray-700 mb-2">No Scan Data Available</h2>
                        <p className="text-gray-500">Scan data will appear here once users start analyzing plants.</p>
                    </div>
                ) : (
                    <>
                        {/* Key Metrics */}
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                            <div className="bg-white p-6 rounded-lg shadow-lg border border-gray-100">
                                <div className="flex items-center justify-between">
                                    <div>
                                        <p className="text-gray-600 text-sm font-medium">Total Scans</p>
                                        <p className="text-3xl font-bold text-gray-900 mt-2">{totalScans}</p>
                                    </div>
                                    <div className="bg-blue-500 p-3 rounded-full text-white text-2xl">
                                        🔍
                                    </div>
                                </div>
                            </div>

                            <div className="bg-white p-6 rounded-lg shadow-lg border border-gray-100">
                                <div className="flex items-center justify-between">
                                    <div>
                                        <p className="text-gray-600 text-sm font-medium">Unique Diseases</p>
                                        <p className="text-3xl font-bold text-gray-900 mt-2">{uniqueDiseases}</p>
                                    </div>
                                    <div className="bg-green-500 p-3 rounded-full text-white text-2xl">
                                        🦠
                                    </div>
                                </div>
                            </div>

                            <div className="bg-white p-6 rounded-lg shadow-lg border border-gray-100">
                                <div className="flex items-center justify-between">
                                    <div>
                                        <p className="text-gray-600 text-sm font-medium">Avg Confidence</p>
                                        <p className="text-3xl font-bold text-gray-900 mt-2">
                                            {(averageConfidence * 100).toFixed(1)}%
                                        </p>
                                    </div>
                                    <div className="bg-purple-500 p-3 rounded-full text-white text-2xl">
                                        📈
                                    </div>
                                </div>
                            </div>

                            <div className="bg-white p-6 rounded-lg shadow-lg border border-gray-100">
                                <div className="flex items-center justify-between">
                                    <div>
                                        <p className="text-gray-600 text-sm font-medium">Online Scans</p>
                                        <p className="text-3xl font-bold text-gray-900 mt-2">{onlineScans}</p>
                                    </div>
                                    <div className="bg-orange-500 p-3 rounded-full text-white text-2xl">
                                        🌐
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Charts Grid */}
                        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                            {/* Disease Distribution Pie Chart */}
                            <div className="bg-white p-6 rounded-lg shadow-lg">
                                <h2 className="text-xl font-semibold mb-4">Disease Distribution</h2>
                                <ResponsiveContainer width="100%" height={300}>
                                    <PieChart>
                                        <Pie
                                            data={diseaseData}
                                            dataKey="count"
                                            nameKey="disease"
                                            cx="50%"
                                            cy="50%"
                                            outerRadius={100}
                                            label={renderCustomizedLabel}
                                            labelLine={false}
                                        >
                                            {diseaseData.map((entry, index) => (
                                                <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                                            ))}
                                        </Pie>
                                        <Tooltip formatter={(value: number, name: string) => [`${value} scans`, name]} />
                                        <Legend />
                                    </PieChart>
                                </ResponsiveContainer>
                            </div>

                            {/* Severity Analysis Bar Chart */}
                            <div className="bg-white p-6 rounded-lg shadow-lg">
                                <h2 className="text-xl font-semibold mb-4">Severity Analysis</h2>
                                <ResponsiveContainer width="100%" height={300}>
                                    <BarChart data={severityChartData}>
                                        <CartesianGrid strokeDasharray="3 3" />
                                        <XAxis dataKey="severity" />
                                        <YAxis />
                                        <Tooltip />
                                        <Legend />
                                        <Bar dataKey="count" fill="#4CAF50" />
                                    </BarChart>
                                </ResponsiveContainer>
                            </div>

                            {/* Monthly Trends Line Chart */}
                            {monthlyChartData.length > 0 && (
                                <div className="bg-white p-6 rounded-lg shadow-lg">
                                    <h2 className="text-xl font-semibold mb-4">Scan Trends Over Time</h2>
                                    <ResponsiveContainer width="100%" height={300}>
                                        <LineChart data={monthlyChartData}>
                                            <CartesianGrid strokeDasharray="3 3" />
                                            <XAxis dataKey="month" />
                                            <YAxis />
                                            <Tooltip />
                                            <Legend />
                                            <Line type="monotone" dataKey="scans" stroke="#8884d8" strokeWidth={2} />
                                        </LineChart>
                                    </ResponsiveContainer>
                                </div>
                            )}

                            {/* Treatment Type Analysis */}
                            <div className="bg-white p-6 rounded-lg shadow-lg">
                                <h2 className="text-xl font-semibold mb-4">Treatment Types</h2>
                                <ResponsiveContainer width="100%" height={300}>
                                    <BarChart data={treatmentChartData}>
                                        <CartesianGrid strokeDasharray="3 3" />
                                        <XAxis dataKey="type" />
                                        <YAxis />
                                        <Tooltip />
                                        <Legend />
                                        <Bar dataKey="count" fill="#FF8042" />
                                    </BarChart>
                                </ResponsiveContainer>
                            </div>

                            {/* Confidence Levels */}
                            <div className="bg-white p-6 rounded-lg shadow-lg">
                                <h2 className="text-xl font-semibold mb-4">Confidence Levels</h2>
                                <ResponsiveContainer width="100%" height={300}>
                                    <BarChart data={confidenceData}>
                                        <CartesianGrid strokeDasharray="3 3" />
                                        <XAxis dataKey="range" />
                                        <YAxis />
                                        <Tooltip />
                                        <Legend />
                                        <Bar dataKey="count" fill="#0088FE" />
                                    </BarChart>
                                </ResponsiveContainer>
                            </div>

                            {/* Online vs Offline Analysis */}
                            <div className="bg-white p-6 rounded-lg shadow-lg">
                                <h2 className="text-xl font-semibold mb-4">Analysis Mode</h2>
                                <ResponsiveContainer width="100%" height={300}>
                                    <PieChart>
                                        <Pie
                                            data={onlineOfflineChartData}
                                            dataKey="count"
                                            nameKey="type"
                                            cx="50%"
                                            cy="50%"
                                            outerRadius={100}
                                            label={renderCustomizedLabel}
                                            labelLine={false}
                                        >
                                            {onlineOfflineChartData.map((entry, index) => (
                                                <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                                            ))}
                                        </Pie>
                                        <Tooltip formatter={(value: number, name: string) => [`${value} scans`, name]} />
                                        <Legend />
                                    </PieChart>
                                </ResponsiveContainer>
                            </div>
                        </div>

                        {/* Top Users Table */}
                        {userActivityData.length > 0 && (
                            <div className="mt-8 bg-white p-6 rounded-lg shadow-lg">
                                <h2 className="text-xl font-semibold mb-4">Top Active Users</h2>
                                <div className="overflow-x-auto">
                                    <table className="min-w-full divide-y divide-gray-200">
                                        <thead className="bg-gray-50">
                                            <tr>
                                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                                    User
                                                </th>
                                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                                    Location
                                                </th>
                                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                                    Total Scans
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody className="bg-white divide-y divide-gray-200">
                                            {userActivityData.map((user, index) => (
                                                <tr key={index} className="hover:bg-gray-50">
                                                    <td className="px-6 py-4 whitespace-nowrap">
                                                        <div className="text-sm font-medium text-gray-900">
                                                            {user.user}
                                                        </div>
                                                    </td>
                                                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                                        {user.location}
                                                    </td>
                                                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                                        <span className="bg-green-100 text-green-800 px-2 py-1 rounded-full">
                                                            {user.scans} scans
                                                        </span>
                                                    </td>
                                                </tr>
                                            ))}
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        )}
                    </>
                )}
            </div>
        </div>
    );
}