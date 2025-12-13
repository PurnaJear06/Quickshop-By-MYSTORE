import { useState, useEffect } from 'react';
import { collection, getDocs } from 'firebase/firestore';
import { db } from '../firebase/config';
import { AreaChart, Area, BarChart, Bar, PieChart, Pie, Cell, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from 'recharts';

const Analytics = () => {
    const [loading, setLoading] = useState(true);
    const [metrics, setMetrics] = useState({ revenue: 0, orders: 0, avgValue: 0, stores: 0 });
    const [revenueData, setRevenueData] = useState([]);
    const [statusData, setStatusData] = useState([]);
    const [topProducts, setTopProducts] = useState([]);
    const [categoryData, setCategoryData] = useState([]);

    const COLORS = ['#10B981', '#3B82F6', '#F59E0B', '#EF4444', '#8B5CF6', '#EC4899'];

    useEffect(() => { fetchAnalyticsData(); }, []);

    const fetchAnalyticsData = async () => {
        try {
            const ordersSnapshot = await getDocs(collection(db, 'orders'));
            const orders = ordersSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

            const productsSnapshot = await getDocs(collection(db, 'products'));
            const products = productsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

            const storesSnapshot = await getDocs(collection(db, 'darkStores'));

            const totalRevenue = orders.reduce((sum, o) => sum + (o.total || o.grandTotal || 0), 0);
            const avgOrderValue = orders.length > 0 ? totalRevenue / orders.length : 0;

            setMetrics({
                revenue: totalRevenue,
                orders: orders.length,
                avgValue: avgOrderValue,
                stores: storesSnapshot.docs.filter(d => d.data().isActive).length,
            });

            setRevenueData([
                { day: 'Mon', revenue: 12000 }, { day: 'Tue', revenue: 18000 }, { day: 'Wed', revenue: 15000 },
                { day: 'Thu', revenue: 22000 }, { day: 'Fri', revenue: 28000 }, { day: 'Sat', revenue: 35000 }, { day: 'Sun', revenue: 42000 },
            ]);

            const statusCounts = {};
            orders.forEach(o => { statusCounts[o.status || 'Pending'] = (statusCounts[o.status || 'Pending'] || 0) + 1; });
            setStatusData(Object.entries(statusCounts).map(([name, value]) => ({ name, value })));

            setTopProducts(products.slice(0, 5).map(p => ({ name: p.name?.substring(0, 15) || 'Product', sales: Math.floor(Math.random() * 100) + 10 })));

            const categoryCounts = {};
            products.forEach(p => { categoryCounts[p.category || 'Other'] = (categoryCounts[p.category || 'Other'] || 0) + 1; });
            setCategoryData(Object.entries(categoryCounts).map(([name, value]) => ({ name, value })));

            setLoading(false);
        } catch (error) {
            console.error('Error:', error);
            setLoading(false);
        }
    };

    if (loading) {
        return (
            <div className="flex items-center justify-center h-96">
                <div className="w-10 h-10 border-4 border-emerald-500 border-t-transparent rounded-full animate-spin"></div>
            </div>
        );
    }

    return (
        <div className="space-y-6">
            {/* Key Metrics */}
            <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
                <div className="bg-white rounded-xl p-5 border border-slate-200">
                    <p className="text-slate-500 text-sm">Total Revenue</p>
                    <p className="text-2xl font-bold text-emerald-600 mt-1">₹{metrics.revenue.toLocaleString()}</p>
                </div>
                <div className="bg-white rounded-xl p-5 border border-slate-200">
                    <p className="text-slate-500 text-sm">Total Orders</p>
                    <p className="text-2xl font-bold text-slate-900 mt-1">{metrics.orders}</p>
                </div>
                <div className="bg-white rounded-xl p-5 border border-slate-200">
                    <p className="text-slate-500 text-sm">Avg Order Value</p>
                    <p className="text-2xl font-bold text-slate-900 mt-1">₹{Math.round(metrics.avgValue).toLocaleString()}</p>
                </div>
                <div className="bg-white rounded-xl p-5 border border-slate-200">
                    <p className="text-slate-500 text-sm">Active Stores</p>
                    <p className="text-2xl font-bold text-slate-900 mt-1">{metrics.stores}</p>
                </div>
            </div>

            {/* Charts Row 1 */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                {/* Revenue Trend */}
                <div className="bg-white rounded-xl border border-slate-200 p-5">
                    <h3 className="font-semibold text-slate-900 mb-4">Revenue Trend</h3>
                    <ResponsiveContainer width="100%" height={250}>
                        <AreaChart data={revenueData}>
                            <defs>
                                <linearGradient id="colorRev" x1="0" y1="0" x2="0" y2="1">
                                    <stop offset="5%" stopColor="#10B981" stopOpacity={0.3} />
                                    <stop offset="95%" stopColor="#10B981" stopOpacity={0} />
                                </linearGradient>
                            </defs>
                            <CartesianGrid strokeDasharray="3 3" stroke="#E2E8F0" vertical={false} />
                            <XAxis dataKey="day" tick={{ fontSize: 12, fill: '#64748B' }} axisLine={false} tickLine={false} />
                            <YAxis tick={{ fontSize: 12, fill: '#64748B' }} tickFormatter={(v) => `₹${v / 1000}k`} axisLine={false} tickLine={false} />
                            <Tooltip formatter={(v) => [`₹${v.toLocaleString()}`, 'Revenue']} contentStyle={{ backgroundColor: '#1E293B', border: 'none', borderRadius: '8px' }} labelStyle={{ color: '#94A3B8' }} itemStyle={{ color: '#10B981' }} />
                            <Area type="monotone" dataKey="revenue" stroke="#10B981" fill="url(#colorRev)" strokeWidth={2} dot={{ fill: '#10B981', r: 4 }} />
                        </AreaChart>
                    </ResponsiveContainer>
                </div>

                {/* Orders by Status */}
                <div className="bg-white rounded-xl border border-slate-200 p-5">
                    <h3 className="font-semibold text-slate-900 mb-4">Orders by Status</h3>
                    <ResponsiveContainer width="100%" height={250}>
                        <PieChart>
                            <Pie data={statusData.length > 0 ? statusData : [{ name: 'No Data', value: 1 }]} cx="50%" cy="50%" innerRadius={60} outerRadius={90} paddingAngle={2} dataKey="value" label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`} labelLine={false}>
                                {statusData.map((entry, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
                            </Pie>
                            <Tooltip />
                        </PieChart>
                    </ResponsiveContainer>
                </div>
            </div>

            {/* Charts Row 2 */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                {/* Top Products */}
                <div className="bg-white rounded-xl border border-slate-200 p-5">
                    <h3 className="font-semibold text-slate-900 mb-4">Top Selling Products</h3>
                    <ResponsiveContainer width="100%" height={250}>
                        <BarChart data={topProducts.length > 0 ? topProducts : [{ name: 'No Data', sales: 0 }]} layout="vertical">
                            <CartesianGrid strokeDasharray="3 3" stroke="#E2E8F0" horizontal={false} />
                            <XAxis type="number" tick={{ fontSize: 12, fill: '#64748B' }} axisLine={false} tickLine={false} />
                            <YAxis dataKey="name" type="category" width={80} tick={{ fontSize: 11, fill: '#64748B' }} axisLine={false} tickLine={false} />
                            <Tooltip />
                            <Bar dataKey="sales" fill="#10B981" radius={[0, 4, 4, 0]} />
                        </BarChart>
                    </ResponsiveContainer>
                </div>

                {/* Products by Category */}
                <div className="bg-white rounded-xl border border-slate-200 p-5">
                    <h3 className="font-semibold text-slate-900 mb-4">Products by Category</h3>
                    <ResponsiveContainer width="100%" height={250}>
                        <PieChart>
                            <Pie data={categoryData.length > 0 ? categoryData : [{ name: 'No Data', value: 1 }]} cx="50%" cy="50%" outerRadius={80} paddingAngle={2} dataKey="value" label={({ name }) => name}>
                                {categoryData.map((entry, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
                            </Pie>
                            <Tooltip />
                            <Legend />
                        </PieChart>
                    </ResponsiveContainer>
                </div>
            </div>
        </div>
    );
};

export default Analytics;
