import Sidebar from "../components/Sidebar";
import DashboardCards from "../components/DashboardCards";

export default function Dashboard() {
    return (
        <div className="flex min-h-screen bg-gray-50">
            <Sidebar />
            <div className="flex-1 p-8">
                <div className="mb-8">
                    <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
                    <p className="text-gray-600 mt-2">Welcome to ShambaEye Admin Panel</p>
                </div>
                <DashboardCards />
            </div>
        </div>
    );
}