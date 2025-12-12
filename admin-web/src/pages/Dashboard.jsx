import { useState, useEffect } from 'react';
import { collection, getDocs, query, where, orderBy, limit } from 'firebase/firestore';
import { db } from '../firebase/config';
import StatCard from '../components/StatCard';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

const Dashboard = () => {
    const [stats, setStats] = useState({
        revenue: 0,
        totalOrders: 0,
        pendingOrders: 0,
        avgOrderValue: 0,
    });
    const [recentOrders, setRecentOrders] = useState([]);
    const [loading, setLoading] = useState(true);

    // Sample revenue data for chart
    const revenueData = [
        { name: 'Mon', revenue: 12000 },
        { name: 'Tue', revenue: 18000 },
        { name: 'Wed', revenue: 15000 },
        { name: 'Thu', revenue: 22000 },
        { name: 'Fri', revenue: 28000 },
        { name: 'Sat', revenue: 35000 },
        { name: 'Sun', revenue: 42000 },
    ];

    useEffect(() => {
        fetchDashboardData();
    }, []);

    const fetchDashboardData = async () => {
        try {
            // Fetch orders
            const ordersSnapshot = await getDocs(collection(db, 'orders'));
            const orders = ordersSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

            // Calculate stats
            const totalRevenue = orders.reduce((sum, order) => sum + (order.grandTotal || 0), 0);
            const pendingCount = orders.filter(order => order.orderStatus === 'pending').length;
            const avgValue = orders.length > 0 ? totalRevenue / orders.length : 0;

            setStats({
                revenue: totalRevenue,
                totalOrders: orders.length,
                pendingOrders: pendingCount,
                avgOrderValue: avgValue,
            });

            // Get recent orders
            const recentOrdersList = orders
                .sort((a, b) => (b.orderedAt?.seconds || 0) - (a.orderedAt?.seconds || 0))
                .slice(0, 5);
            setRecentOrders(recentOrdersList);

            setLoading(false);
        } catch (error) {
            console.error('Error fetching dashboard data:', error);
            setLoading(false);
        }
    };

    if (loading) {
        return (
            <div className="flex items-center justify-center h-64">
                <div className="text-gray-500">Loading...</div>
            </div>
        );
    }

    return (
        <div>
            <h1 className="text-3xl font-bold mb-6">Dashboard</h1>
            <p className="text-gray-600 mb-8">Welcome back, Purna!</p>

            {/* Stats Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                <StatCard
                    title="Today's Revenue"
                    value={`₹${stats.revenue.toLocaleString()}`}
                    icon="💰"
                    trend={12}
                />
                <StatCard
                    title="Total Orders"
                    value={stats.totalOrders}
                    icon="📦"
                    trend={8}
                />
                <StatCard
                    title="Pending Orders"
                    value={stats.pendingOrders}
                    icon="⏱️"
                />
                <StatCard
                    title="Avg Order Value"
                    value={`₹${Math.round(stats.avgOrderValue)}`}
                    icon="📊"
                    trend={5}
                />
            </div>

            {/* Revenue Chart */}
            <div className="bg-white rounded-lg shadow p-6 mb-8">
                <h2 className="text-xl font-bold mb-4">Weekly Revenue</h2>
                <ResponsiveContainer width="100%" height={300}>
                    <LineChart data={revenueData}>
                        <CartesianGrid strokeDasharray="3 3" />
                        <XAxis dataKey="name" />
                        <YAxis />
                        <Tooltip />
                        <Line type="monotone" dataKey="revenue" stroke="#22C55E" strokeWidth={2} />
                    </LineChart>
                </ResponsiveContainer>
            </div>

            {/* Recent Orders */}
            <div className="bg-white rounded-lg shadow">
                <div className="p-6 border-b border-gray-200">
                    <h2 className="text-xl font-bold">Recent Orders</h2>
                </div>
                <div className="overflow-x-auto">
                    <table className="w-full">
                        <thead className="bg-gray-50">
                            <tr>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Order ID</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Customer</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Amount</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-200">
                            {recentOrders.length === 0 ? (
                                <tr>
                                    <td colSpan="4" className="px-6 py-4 text-center text-gray-500">
                                        No orders yet
                                    </td>
                                </tr>
                            ) : (
                                recentOrders.map((order) => (
                                    <tr key={order.id}>
                                        <td className="px-6 py-4 text-sm font-medium text-gray-900">
                                            #{order.orderNumber || order.id.substring(0, 8)}
                                        </td>
                                        <td className="px-6 py-4 text-sm text-gray-500">
                                            {order.customerName || 'Unknown'}
                                        </td>
                                        <td className="px-6 py-4 text-sm text-gray-500">
                                            ₹{(order.grandTotal || 0).toLocaleString()}
                                        </td>
                                        <td className="px-6 py-4 text-sm">
                                            <span className={`px-2 py-1 rounded-full text-xs font-medium ${order.orderStatus === 'delivered'
                                                    ? 'bg-green-100 text-green-800'
                                                    : order.orderStatus === 'pending'
                                                        ? 'bg-yellow-100 text-yellow-800'
                                                        : 'bg-blue-100 text-blue-800'
                                                }`}>
                                                {order.orderStatus || 'pending'}
                                            </span>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
};

export default Dashboard;
