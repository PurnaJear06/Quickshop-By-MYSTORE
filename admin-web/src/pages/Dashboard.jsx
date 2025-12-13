import { useState, useEffect } from 'react';
import { collection, getDocs } from 'firebase/firestore';
import { db } from '../firebase/config';
import StatCard from '../components/StatCard';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

const Dashboard = () => {
    const [stats, setStats] = useState({ revenue: 0, totalOrders: 0, pendingOrders: 0, avgOrderValue: 0 });
    const [recentOrders, setRecentOrders] = useState([]);
    const [loading, setLoading] = useState(true);

    const salesData = [
        { name: 'Mon', sales: 15000 },
        { name: 'Tue', sales: 35000 },
        { name: 'Wed', sales: 32000 },
        { name: 'Thu', sales: 45000 },
        { name: 'Fri', sales: 48000 },
        { name: 'Sat', sales: 75450 },
        { name: 'Sun', sales: 55000 },
    ];

    useEffect(() => { fetchDashboardData(); }, []);

    const fetchDashboardData = async () => {
        try {
            const ordersSnapshot = await getDocs(collection(db, 'orders'));
            const orders = ordersSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            const totalRevenue = orders.reduce((sum, order) => sum + (order.grandTotal || 0), 0);
            const pendingCount = orders.filter(order => order.orderStatus === 'pending').length;
            const avgValue = orders.length > 0 ? totalRevenue / orders.length : 0;
            setStats({ revenue: totalRevenue, totalOrders: orders.length, pendingOrders: pendingCount, avgOrderValue: avgValue });
            setRecentOrders(orders.sort((a, b) => (b.orderedAt?.seconds || 0) - (a.orderedAt?.seconds || 0)).slice(0, 5));
            setLoading(false);
        } catch (error) {
            console.error('Error:', error);
            setLoading(false);
        }
    };

    const getStatusStyle = (status) => {
        const styles = {
            delivered: 'bg-emerald-100 text-emerald-700',
            pending: 'bg-amber-100 text-amber-700',
            confirmed: 'bg-blue-100 text-blue-700',
            processing: 'bg-purple-100 text-purple-700',
            cancelled: 'bg-red-100 text-red-700',
        };
        return styles[status?.toLowerCase()] || 'bg-slate-100 text-slate-700';
    };

    if (loading) {
        return (
            <div className="flex items-center justify-center h-96">
                <div className="w-10 h-10 border-4 border-emerald-500 border-t-transparent rounded-full animate-spin"></div>
            </div>
        );
    }

    return (
        <div className="space-y-8">
            {/* Stats Grid - Matching prototype */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5">
                <StatCard
                    title="Today's Revenue"
                    value={`₹${stats.revenue.toLocaleString()}`}
                    icon={<span className="text-2xl">₹</span>}
                    isRevenue={true}
                    trend={true}
                />
                <StatCard
                    title="Total Orders"
                    value={stats.totalOrders}
                    icon={
                        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                        </svg>
                    }
                />
                <StatCard
                    title="Pending Orders"
                    value={stats.pendingOrders}
                    icon={
                        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                    }
                />
                <StatCard
                    title="Avg Order Value"
                    value={`₹${Math.round(stats.avgOrderValue)}`}
                    icon={
                        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                        </svg>
                    }
                />
            </div>

            {/* Weekly Sales Trend Chart */}
            <div className="bg-white rounded-xl p-6 shadow-sm">
                <h2 className="text-lg font-semibold text-slate-900 mb-4">Weekly Sales Trend</h2>
                <ResponsiveContainer width="100%" height={350}>
                    <AreaChart data={salesData} margin={{ top: 10, right: 20, left: 10, bottom: 0 }}>
                        <defs>
                            <linearGradient id="salesGradient" x1="0" y1="0" x2="0" y2="1">
                                <stop offset="0%" stopColor="#10B981" stopOpacity={0.3} />
                                <stop offset="100%" stopColor="#10B981" stopOpacity={0} />
                            </linearGradient>
                        </defs>
                        <CartesianGrid strokeDasharray="3 3" stroke="#E2E8F0" vertical={false} />
                        <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fill: '#64748B', fontSize: 12 }} />
                        <YAxis axisLine={false} tickLine={false} tick={{ fill: '#64748B', fontSize: 12 }} tickFormatter={(v) => v.toLocaleString()} width={70} />
                        <Tooltip
                            formatter={(value) => [`₹${value.toLocaleString()}`, 'Sales']}
                            contentStyle={{ backgroundColor: '#1E293B', border: 'none', borderRadius: '8px', padding: '8px 12px' }}
                            labelStyle={{ color: '#94A3B8' }}
                            itemStyle={{ color: '#10B981' }}
                        />
                        <Area type="monotone" dataKey="sales" stroke="#10B981" strokeWidth={2} fill="url(#salesGradient)" dot={{ fill: '#10B981', r: 4 }} activeDot={{ r: 6 }} />
                    </AreaChart>
                </ResponsiveContainer>
                <div className="flex justify-center mt-4">
                    <div className="flex items-center gap-2">
                        <span className="w-3 h-3 rounded-full bg-emerald-500"></span>
                        <span className="text-sm text-slate-600">Sales</span>
                    </div>
                </div>
            </div>

            {/* Recent Orders Table */}
            <div className="bg-white rounded-xl shadow-sm overflow-hidden">
                <div className="px-6 py-4 border-b border-slate-100">
                    <h2 className="text-lg font-semibold text-slate-900">Recent Orders</h2>
                </div>
                <div className="overflow-x-auto">
                    <table className="w-full">
                        <thead>
                            <tr className="bg-slate-50 border-b border-slate-100">
                                <th className="px-6 py-3 text-left text-xs font-semibold text-slate-500 uppercase">Order ID</th>
                                <th className="px-6 py-3 text-left text-xs font-semibold text-slate-500 uppercase">Customer</th>
                                <th className="px-6 py-3 text-left text-xs font-semibold text-slate-500 uppercase">Amount</th>
                                <th className="px-6 py-3 text-left text-xs font-semibold text-slate-500 uppercase">Status</th>
                                <th className="px-6 py-3 text-left text-xs font-semibold text-slate-500 uppercase">Date</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-100">
                            {recentOrders.length === 0 ? (
                                <tr><td colSpan="5" className="px-6 py-12 text-center text-slate-500">No orders yet</td></tr>
                            ) : (
                                recentOrders.map((order) => (
                                    <tr key={order.id} className="hover:bg-slate-50">
                                        <td className="px-6 py-4 text-sm font-medium text-slate-900">#QS-{order.orderNumber || order.id.substring(0, 8)}</td>
                                        <td className="px-6 py-4 text-sm text-slate-600">{order.customerName || 'Customer'}</td>
                                        <td className="px-6 py-4 text-sm text-slate-900 font-medium">₹{order.grandTotal?.toLocaleString() || 0}</td>
                                        <td className="px-6 py-4">
                                            <span className={`inline-flex px-2.5 py-1 rounded-full text-xs font-medium ${getStatusStyle(order.orderStatus)}`}>
                                                {order.orderStatus || 'Pending'}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4 text-sm text-slate-500">
                                            {order.orderedAt?.seconds ? new Date(order.orderedAt.seconds * 1000).toLocaleDateString('en-IN', { month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' }) : 'N/A'}
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
                <div className="px-6 py-3 border-t border-slate-100 flex justify-end">
                    <div className="flex items-center gap-1">
                        <button className="px-3 py-1 text-sm text-slate-400">&lt;</button>
                        <button className="px-3 py-1 text-sm bg-slate-100 text-slate-700 rounded">1</button>
                        <button className="px-3 py-1 text-sm text-slate-400">&gt;</button>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Dashboard;
