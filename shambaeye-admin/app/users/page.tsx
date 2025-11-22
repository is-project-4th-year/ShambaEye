'use client';
import { useState, useEffect } from 'react';
import Sidebar from '../../components/Sidebar';
import axios from 'axios';

interface User {
    uid: string;
    fullName: string;
    email: string;
    location: string;
    farmSize: number;
    createdAt: any;
    preferredLanguage?: string;
}

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
    originalImageUrl?: string;
}

export default function Users() {
    const [users, setUsers] = useState<User[]>([]);
    const [scans, setScans] = useState<Scan[]>([]);
    const [loading, setLoading] = useState(true);
    const [selectedUser, setSelectedUser] = useState<User | null>(null);
    const [isEditModalOpen, setIsEditModalOpen] = useState(false);
    const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
    const [isAddModalOpen, setIsAddModalOpen] = useState(false);
    const [isScansModalOpen, setIsScansModalOpen] = useState(false);
    const [userScans, setUserScans] = useState<Scan[]>([]);
    const [scansLoading, setScansLoading] = useState(false);
    const [searchTerm, setSearchTerm] = useState('');

    useEffect(() => {
        fetchUsers();
        fetchScans();
    }, []);

    const fetchUsers = async () => {
        try {
            const response = await axios.get('/api/users');
            setUsers(response.data.users || []);
        } catch (error) {
            console.error('Error fetching users:', error);
        } finally {
            setLoading(false);
        }
    };

    const fetchScans = async () => {
        try {
            const response = await axios.get('/api/scans');
            setScans(response.data.scans || []);
        } catch (error) {
            console.error('Error fetching scans:', error);
        }
    };

    const handleEdit = (user: User) => {
        setSelectedUser(user);
        setIsEditModalOpen(true);
    };

    const handleDelete = (user: User) => {
        setSelectedUser(user);
        setIsDeleteModalOpen(true);
    };

    const handleViewScans = async (user: User) => {
        setSelectedUser(user);
        setScansLoading(true);
        setIsScansModalOpen(true);

        try {
            // Filter scans for this specific user
            const userScansData = scans.filter(scan => scan.userId === user.uid);
            setUserScans(userScansData);
        } catch (error) {
            console.error('Error fetching user scans:', error);
            alert('Failed to load user scans');
        } finally {
            setScansLoading(false);
        }
    };

    const confirmDelete = async () => {
        if (!selectedUser) return;

        try {
            await axios.delete(`/api/users/${selectedUser.uid}`);
            setUsers(users.filter(user => user.uid !== selectedUser.uid));
            setIsDeleteModalOpen(false);
            setSelectedUser(null);
        } catch (error) {
            console.error('Error deleting user:', error);
            alert('Failed to delete user');
        }
    };

    const handleUpdateUser = async (updatedUser: User) => {
        try {
            await axios.put(`/api/users/${updatedUser.uid}`, updatedUser);
            setUsers(users.map(user =>
                user.uid === updatedUser.uid ? updatedUser : user
            ));
            setIsEditModalOpen(false);
            setSelectedUser(null);
        } catch (error) {
            console.error('Error updating user:', error);
            alert('Failed to update user');
        }
    };

    const handleAddUser = async (newUser: Omit<User, 'uid' | 'createdAt'> & { password: string }) => {
        try {
            const response = await axios.post('/api/users', newUser);
            if (response.data.success) {
                fetchUsers();
                setIsAddModalOpen(false);
            } else {
                alert('Failed to add user: ' + response.data.error);
            }
        } catch (error: any) {
            console.error('Error adding user:', error);
            alert('Failed to add user: ' + (error.response?.data?.error || error.message));
        }
    };

    const filteredUsers = users.filter(user =>
        user.fullName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        user.email?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        user.location?.toLowerCase().includes(searchTerm.toLowerCase())
    );

    // Calculate user stats
    const getUserScanStats = (userId: string) => {
        const userScans = scans.filter(scan => scan.userId === userId);
        return {
            totalScans: userScans.length,
            uniqueDiseases: new Set(userScans.map(scan => scan.disease)).size,
            avgConfidence: userScans.length > 0
                ? userScans.reduce((acc, scan) => acc + (scan.confidence || 0), 0) / userScans.length
                : 0
        };
    };

    if (loading) {
        return (
            <div className="flex min-h-screen bg-gray-50">
                <Sidebar />
                <div className="flex-1 p-8">
                    <div className="animate-pulse">
                        <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
                        <div className="h-12 bg-gray-200 rounded mb-4"></div>
                        {[...Array(5)].map((_, i) => (
                            <div key={i} className="h-16 bg-gray-200 rounded mb-2"></div>
                        ))}
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="flex min-h-screen bg-gray-50">
            <Sidebar />

            <div className="flex-1 p-8">
                <div className="mb-8">
                    <h1 className="text-3xl font-bold text-gray-900">Users Management</h1>
                    <p className="text-gray-600 mt-2">Manage all ShambaEye users and their profiles</p>
                </div>

                {/* Stats Cards */}
                <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
                    <div className="bg-white p-4 rounded-lg shadow border border-gray-100">
                        <div className="flex items-center">
                            <div className="bg-blue-100 p-3 rounded-lg mr-4">
                                <span className="text-blue-600 text-2xl">👥</span>
                            </div>
                            <div>
                                <p className="text-gray-500 text-sm">Total Users</p>
                                <p className="text-2xl font-bold text-gray-900">{users.length}</p>
                            </div>
                        </div>
                    </div>

                    <div className="bg-white p-4 rounded-lg shadow border border-gray-100">
                        <div className="flex items-center">
                            <div className="bg-green-100 p-3 rounded-lg mr-4">
                                <span className="text-green-600 text-2xl">🌍</span>
                            </div>
                            <div>
                                <p className="text-gray-500 text-sm">Locations</p>
                                <p className="text-2xl font-bold text-gray-900">
                                    {new Set(users.map(u => u.location)).size}
                                </p>
                            </div>
                        </div>
                    </div>

                    <div className="bg-white p-4 rounded-lg shadow border border-gray-100">
                        <div className="flex items-center">
                            <div className="bg-purple-100 p-3 rounded-lg mr-4">
                                <span className="text-purple-600 text-2xl">🔍</span>
                            </div>
                            <div>
                                <p className="text-gray-500 text-sm">Total Scans</p>
                                <p className="text-2xl font-bold text-gray-900">{scans.length}</p>
                            </div>
                        </div>
                    </div>

                    <div className="bg-white p-4 rounded-lg shadow border border-gray-100">
                        <div className="flex items-center">
                            <div className="bg-orange-100 p-3 rounded-lg mr-4">
                                <span className="text-orange-600 text-2xl">📅</span>
                            </div>
                            <div>
                                <p className="text-gray-500 text-sm">Active Users</p>
                                <p className="text-2xl font-bold text-gray-900">
                                    {users.filter(user => {
                                        const userScans = scans.filter(scan => scan.userId === user.uid);
                                        return userScans.length > 0;
                                    }).length}
                                </p>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Search and Controls */}
                <div className="bg-white p-6 rounded-lg shadow mb-6">
                    <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                        <div className="flex-1 w-full">
                            <div className="relative">
                                <input
                                    type="text"
                                    placeholder="Search users by name, email, or location..."
                                    value={searchTerm}
                                    onChange={(e) => setSearchTerm(e.target.value)}
                                    className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                                />
                                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                    <span className="text-gray-400">🔍</span>
                                </div>
                            </div>
                        </div>
                        <button
                            onClick={() => setIsAddModalOpen(true)}
                            className="bg-green-600 hover:bg-green-700 text-white px-6 py-2 rounded-lg transition-colors flex items-center gap-2"
                        >
                            <span>+</span>
                            Add User
                        </button>
                    </div>
                </div>

                {/* Users Table */}
                <div className="bg-white rounded-lg shadow overflow-hidden">
                    <div className="overflow-x-auto">
                        <table className="min-w-full divide-y divide-gray-200">
                            <thead className="bg-gray-50">
                                <tr>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        User
                                    </th>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        Contact
                                    </th>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        Farm Details
                                    </th>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        Scan Stats
                                    </th>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        Joined
                                    </th>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        Actions
                                    </th>
                                </tr>
                            </thead>
                            <tbody className="bg-white divide-y divide-gray-200">
                                {filteredUsers.length === 0 ? (
                                    <tr>
                                        <td colSpan={6} className="px-6 py-8 text-center text-gray-500">
                                            <div className="flex flex-col items-center">
                                                <span className="text-4xl mb-2">👥</span>
                                                <p className="text-lg">No users found</p>
                                                <p className="text-sm">Try adjusting your search terms</p>
                                            </div>
                                        </td>
                                    </tr>
                                ) : (
                                    filteredUsers.map((user) => {
                                        const scanStats = getUserScanStats(user.uid);
                                        return (
                                            <tr key={user.uid} className="hover:bg-gray-50 transition-colors">
                                                <td className="px-6 py-4 whitespace-nowrap">
                                                    <div className="flex items-center">
                                                        <div className="flex-shrink-0 h-10 w-10 bg-green-500 rounded-full flex items-center justify-center text-white font-bold">
                                                            {user.fullName?.[0]?.toUpperCase() || 'U'}
                                                        </div>
                                                        <div className="ml-4">
                                                            <div className="text-sm font-medium text-gray-900">
                                                                {user.fullName || 'No Name'}
                                                            </div>
                                                            <div className="text-sm text-gray-500">
                                                                {user.preferredLanguage || 'English'}
                                                            </div>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td className="px-6 py-4 whitespace-nowrap">
                                                    <div className="text-sm text-gray-900">{user.email}</div>
                                                    <div className="text-sm text-gray-500">{user.location || 'Not specified'}</div>
                                                </td>
                                                <td className="px-6 py-4 whitespace-nowrap">
                                                    <div className="text-sm text-gray-900">
                                                        {user.farmSize ? `${user.farmSize} acres` : 'Not specified'}
                                                    </div>
                                                </td>
                                                <td className="px-6 py-4 whitespace-nowrap">
                                                    <div className="text-sm">
                                                        <div className="text-gray-900">
                                                            {scanStats.totalScans} scans
                                                        </div>
                                                        <div className="text-gray-500 text-xs">
                                                            {scanStats.uniqueDiseases} diseases • {(scanStats.avgConfidence * 100).toFixed(1)}% avg confidence
                                                        </div>
                                                    </div>
                                                </td>
                                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                                    {user.createdAt?._seconds
                                                        ? new Date(user.createdAt._seconds * 1000).toLocaleDateString()
                                                        : 'Unknown'
                                                    }
                                                </td>
                                                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                                                    <div className="flex space-x-2">
                                                        <button
                                                            onClick={() => handleEdit(user)}
                                                            className="text-blue-600 hover:text-blue-900 bg-blue-50 hover:bg-blue-100 px-3 py-1 rounded text-xs transition-colors"
                                                        >
                                                            Edit
                                                        </button>
                                                        <button
                                                            onClick={() => handleDelete(user)}
                                                            className="text-red-600 hover:text-red-900 bg-red-50 hover:bg-red-100 px-3 py-1 rounded text-xs transition-colors"
                                                        >
                                                            Delete
                                                        </button>
                                                        <button
                                                            onClick={() => handleViewScans(user)}
                                                            className="text-green-600 hover:text-green-900 bg-green-50 hover:bg-green-100 px-3 py-1 rounded text-xs transition-colors"
                                                        >
                                                            View Scans
                                                        </button>
                                                    </div>
                                                </td>
                                            </tr>
                                        );
                                    })
                                )}
                            </tbody>
                        </table>
                    </div>
                </div>

                {/* Edit User Modal */}
                {isEditModalOpen && selectedUser && (
                    <EditUserModal
                        user={selectedUser}
                        onClose={() => {
                            setIsEditModalOpen(false);
                            setSelectedUser(null);
                        }}
                        onSave={handleUpdateUser}
                    />
                )}

                {/* Delete Confirmation Modal */}
                {isDeleteModalOpen && selectedUser && (
                    <DeleteConfirmationModal
                        user={selectedUser}
                        onClose={() => {
                            setIsDeleteModalOpen(false);
                            setSelectedUser(null);
                        }}
                        onConfirm={confirmDelete}
                    />
                )}

                {/* Add User Modal */}
                {isAddModalOpen && (
                    <AddUserModal
                        onClose={() => setIsAddModalOpen(false)}
                        onSave={handleAddUser}
                    />
                )}

                {/* View Scans Modal */}
                {isScansModalOpen && selectedUser && (
                    <ViewScansModal
                        user={selectedUser}
                        scans={userScans}
                        loading={scansLoading}
                        onClose={() => {
                            setIsScansModalOpen(false);
                            setSelectedUser(null);
                            setUserScans([]);
                        }}
                    />
                )}
            </div>
        </div>
    );
}

// Edit User Modal Component (unchanged)
function EditUserModal({ user, onClose, onSave }: { user: User; onClose: () => void; onSave: (user: User) => void }) {
    const [formData, setFormData] = useState(user);

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        onSave(formData);
    };

    return (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
            <div className="bg-white rounded-lg max-w-md w-full">
                <div className="p-6 border-b border-gray-200">
                    <h2 className="text-xl font-semibold text-gray-900">Edit User</h2>
                </div>
                <form onSubmit={handleSubmit} className="p-6 space-y-4">
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Full Name</label>
                        <input
                            type="text"
                            value={formData.fullName || ''}
                            onChange={(e) => setFormData({ ...formData, fullName: e.target.value })}
                            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                        />
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
                        <input
                            type="email"
                            value={formData.email || ''}
                            onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                        />
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Location</label>
                        <input
                            type="text"
                            value={formData.location || ''}
                            onChange={(e) => setFormData({ ...formData, location: e.target.value })}
                            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                        />
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Farm Size (acres)</label>
                        <input
                            type="number"
                            value={formData.farmSize || ''}
                            onChange={(e) => setFormData({ ...formData, farmSize: Number(e.target.value) })}
                            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                        />
                    </div>
                    <div className="flex justify-end space-x-3 pt-4">
                        <button
                            type="button"
                            onClick={onClose}
                            className="px-4 py-2 text-gray-600 hover:text-gray-800 border border-gray-300 rounded-lg transition-colors"
                        >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
                        >
                            Save Changes
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
}

// Delete Confirmation Modal Component (unchanged)
function DeleteConfirmationModal({ user, onClose, onConfirm }: { user: User; onClose: () => void; onConfirm: () => void }) {
    return (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
            <div className="bg-white rounded-lg max-w-md w-full">
                <div className="p-6 border-b border-gray-200">
                    <h2 className="text-xl font-semibold text-gray-900">Delete User</h2>
                </div>
                <div className="p-6">
                    <p className="text-gray-600 mb-4">
                        Are you sure you want to delete <strong>{user.fullName}</strong>? This action cannot be undone.
                    </p>
                    <div className="flex justify-end space-x-3">
                        <button
                            onClick={onClose}
                            className="px-4 py-2 text-gray-600 hover:text-gray-800 border border-gray-300 rounded-lg transition-colors"
                        >
                            Cancel
                        </button>
                        <button
                            onClick={onConfirm}
                            className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
                        >
                            Delete User
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
}

// Add User Modal Component (unchanged)
function AddUserModal({ onClose, onSave }: { onClose: () => void; onSave: (user: any) => void }) {
    const [formData, setFormData] = useState({
        fullName: '',
        email: '',
        location: '',
        farmSize: 0,
        password: 'TempPassword123!',
        preferredLanguage: 'en'
    });

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        onSave(formData);
    };

    return (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
            <div className="bg-white rounded-lg max-w-md w-full">
                <div className="p-6 border-b border-gray-200">
                    <h2 className="text-xl font-semibold text-gray-900">Add New User</h2>
                </div>
                <form onSubmit={handleSubmit} className="p-6 space-y-4">
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Full Name *</label>
                        <input
                            type="text"
                            required
                            value={formData.fullName}
                            onChange={(e) => setFormData({ ...formData, fullName: e.target.value })}
                            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                            placeholder="Enter full name"
                        />
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Email *</label>
                        <input
                            type="email"
                            required
                            value={formData.email}
                            onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                            placeholder="Enter email address"
                        />
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Location</label>
                        <input
                            type="text"
                            value={formData.location}
                            onChange={(e) => setFormData({ ...formData, location: e.target.value })}
                            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                            placeholder="Enter location"
                        />
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Farm Size (acres)</label>
                        <input
                            type="number"
                            value={formData.farmSize}
                            onChange={(e) => setFormData({ ...formData, farmSize: Number(e.target.value) })}
                            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                            placeholder="Enter farm size"
                        />
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Temporary Password</label>
                        <input
                            type="text"
                            value={formData.password}
                            onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                            placeholder="Enter temporary password"
                        />
                        <p className="text-xs text-gray-500 mt-1">User will need to change this on first login</p>
                    </div>
                    <div className="flex justify-end space-x-3 pt-4">
                        <button
                            type="button"
                            onClick={onClose}
                            className="px-4 py-2 text-gray-600 hover:text-gray-800 border border-gray-300 rounded-lg transition-colors"
                        >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
                        >
                            Add User
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
}

// View Scans Modal Component (NEW)
function ViewScansModal({ user, scans, loading, onClose }: { user: User; scans: Scan[]; loading: boolean; onClose: () => void }) {
    const formatDiseaseName = (disease: string) => {
        return disease.replace('Tomato___', '').replace(/_/g, ' ');
    };

    const formatDate = (timestamp: { _seconds: number; _nanoseconds: number }) => {
        return new Date(timestamp._seconds * 1000).toLocaleDateString() + ' ' +
            new Date(timestamp._seconds * 1000).toLocaleTimeString();
    };

    return (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
            <div className="bg-white rounded-lg max-w-4xl w-full max-h-[90vh] overflow-hidden">
                <div className="p-6 border-b border-gray-200">
                    <div className="flex justify-between items-center">
                        <h2 className="text-xl font-semibold text-gray-900">
                            Scan History - {user.fullName}
                        </h2>
                        <button
                            onClick={onClose}
                            className="text-gray-400 hover:text-gray-600 text-2xl"
                        >
                            ×
                        </button>
                    </div>
                    <p className="text-gray-600 mt-1">
                        {scans.length} total scans • {new Set(scans.map(scan => scan.disease)).size} unique diseases
                    </p>
                </div>

                <div className="overflow-y-auto max-h-[calc(90vh-120px)]">
                    {loading ? (
                        <div className="p-8 text-center">
                            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600 mx-auto"></div>
                            <p className="text-gray-600 mt-4">Loading scans...</p>
                        </div>
                    ) : scans.length === 0 ? (
                        <div className="p-8 text-center">
                            <div className="text-6xl mb-4">🔍</div>
                            <h3 className="text-lg font-semibold text-gray-700 mb-2">No Scans Found</h3>
                            <p className="text-gray-500">This user hasn't performed any plant scans yet.</p>
                        </div>
                    ) : (
                        <div className="p-6">
                            <div className="space-y-4">
                                {scans.map((scan, index) => (
                                    <div key={index} className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow">
                                        <div className="flex justify-between items-start mb-3">
                                            <div>
                                                <h3 className="font-semibold text-gray-900">
                                                    {formatDiseaseName(scan.disease)}
                                                </h3>
                                                <p className="text-sm text-gray-500">
                                                    {formatDate(scan.timestamp)} • {scan.isOnline ? 'Online' : 'Offline'} Analysis
                                                </p>
                                            </div>
                                            <div className="text-right">
                                                <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${scan.severity === 'Severe' ? 'bg-red-100 text-red-800' :
                                                        scan.severity === 'Moderate' ? 'bg-orange-100 text-orange-800' :
                                                            'bg-green-100 text-green-800'
                                                    }`}>
                                                    {scan.severity || 'Unknown'}
                                                </span>
                                                <div className="text-sm text-gray-500 mt-1">
                                                    {(scan.confidence * 100).toFixed(1)}% confidence
                                                </div>
                                            </div>
                                        </div>

                                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
                                            <div>
                                                <h4 className="font-medium text-gray-700 mb-1">Treatment Type</h4>
                                                <p className="text-gray-600">{scan.treatment?.type || 'Not specified'}</p>
                                            </div>
                                            <div>
                                                <h4 className="font-medium text-gray-700 mb-1">Symptoms</h4>
                                                <p className="text-gray-600">{scan.treatment?.symptoms || 'No symptoms recorded'}</p>
                                            </div>
                                        </div>

                                        {scan.originalImageUrl && (
                                            <div className="mt-3">
                                                <a
                                                    href={scan.originalImageUrl}
                                                    target="_blank"
                                                    rel="noopener noreferrer"
                                                    className="text-blue-600 hover:text-blue-800 text-sm flex items-center gap-1"
                                                >
                                                    <span>📷</span>
                                                    View Original Image
                                                </a>
                                            </div>
                                        )}
                                    </div>
                                ))}
                            </div>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}