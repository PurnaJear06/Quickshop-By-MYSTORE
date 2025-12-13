import { useState, useEffect } from 'react';
import { collection, onSnapshot, updateDoc, doc } from 'firebase/firestore';
import { db } from '../firebase/config';

const Orders = () => {
    const [orders, setOrders] = useState([]);
    const [loading, setLoading] = useState(true);
    const [filterStatus, setFilterStatus] = useState('All');
    const [selectedOrder, setSelectedOrder] = useState(null);
    const [searchTerm, setSearchTerm] = useState('');

    const statusFlow = ['Pending', 'Confirmed', 'Preparing', 'Out for Delivery', 'Delivered'];
    const statusColors = {
        'Pending': 'bg-amber-100 text-amber-700',
        'Confirmed': 'bg-blue-100 text-blue-700',
        'Preparing': 'bg-purple-100 text-purple-700',
        'Out for Delivery': 'bg-orange-100 text-orange-700',
        'Delivered': 'bg-emerald-100 text-emerald-700',
        'Cancelled': 'bg-red-100 text-red-700',
    };

    useEffect(() => {
        const unsubscribe = onSnapshot(collection(db, 'orders'), (snapshot) => {
            const ordersData = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data(), createdAt: doc.data().createdAt?.toDate?.() || new Date() }));
            ordersData.sort((a, b) => b.createdAt - a.createdAt);
            setOrders(ordersData);
            setLoading(false);
        });
        return () => unsubscribe();
    }, []);

    const updateOrderStatus = async (orderId, newStatus) => {
        try {
            await updateDoc(doc(db, 'orders', orderId), { status: newStatus, updatedAt: new Date() });
        } catch (error) {
            console.error('Error updating order:', error);
        }
    };

    const getNextStatus = (currentStatus) => {
        const index = statusFlow.indexOf(currentStatus);
        return index < statusFlow.length - 1 ? statusFlow[index + 1] : null;
    };

    const filteredOrders = orders.filter(order => {
        const matchesStatus = filterStatus === 'All' || order.status === filterStatus;
        const matchesSearch = !searchTerm ||
            order.orderNumber?.toLowerCase().includes(searchTerm.toLowerCase()) ||
            order.customerName?.toLowerCase().includes(searchTerm.toLowerCase());
        return matchesStatus && matchesSearch;
    });

    return (
        <div className="space-y-6">
            {/* Search and Filters */}
            <div className="flex flex-col sm:flex-row gap-4">
                {/* Search */}
                <div className="relative flex-1 max-w-md">
                    <svg className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                    <input
                        type="text"
                        placeholder="Search orders..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        className="w-full pl-10 pr-4 py-2.5 bg-white border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                    />
                </div>
            </div>

            {/* Status Tabs */}
            <div className="flex gap-2 overflow-x-auto pb-2">
                {['All', ...statusFlow, 'Cancelled'].map(status => (
                    <button
                        key={status}
                        onClick={() => setFilterStatus(status)}
                        className={`px-4 py-2 rounded-lg text-sm font-medium whitespace-nowrap transition-colors ${filterStatus === status
                                ? 'bg-emerald-500 text-white'
                                : 'bg-white border border-slate-200 text-slate-600 hover:bg-slate-50'
                            }`}
                    >
                        {status}
                        {status !== 'All' && (
                            <span className="ml-1.5 text-xs opacity-70">({orders.filter(o => o.status === status).length})</span>
                        )}
                    </button>
                ))}
            </div>

            {/* Orders Table */}
            <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
                {loading ? (
                    <div className="flex items-center justify-center py-12">
                        <div className="w-10 h-10 border-4 border-emerald-500 border-t-transparent rounded-full animate-spin"></div>
                    </div>
                ) : filteredOrders.length === 0 ? (
                    <div className="text-center py-12">
                        <svg className="w-12 h-12 mx-auto text-slate-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                        </svg>
                        <p className="text-slate-500 mt-2">No orders found</p>
                    </div>
                ) : (
                    <div className="overflow-x-auto">
                        <table className="w-full">
                            <thead>
                                <tr className="bg-slate-50 border-b border-slate-100">
                                    <th className="px-6 py-3 text-left text-xs font-semibold text-slate-500 uppercase">Order ID</th>
                                    <th className="px-6 py-3 text-left text-xs font-semibold text-slate-500 uppercase">Customer</th>
                                    <th className="px-6 py-3 text-left text-xs font-semibold text-slate-500 uppercase">Items</th>
                                    <th className="px-6 py-3 text-left text-xs font-semibold text-slate-500 uppercase">Amount</th>
                                    <th className="px-6 py-3 text-left text-xs font-semibold text-slate-500 uppercase">Status</th>
                                    <th className="px-6 py-3 text-left text-xs font-semibold text-slate-500 uppercase">Date</th>
                                    <th className="px-6 py-3 text-left text-xs font-semibold text-slate-500 uppercase">Action</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-100">
                                {filteredOrders.map(order => (
                                    <tr key={order.id} className="hover:bg-slate-50">
                                        <td className="px-6 py-4 text-sm font-medium text-slate-900">#{order.orderNumber || order.id.substring(0, 8)}</td>
                                        <td className="px-6 py-4 text-sm text-slate-600">{order.customerName || order.userName || 'Unknown'}</td>
                                        <td className="px-6 py-4 text-sm text-slate-500">{order.items?.length || 0} items</td>
                                        <td className="px-6 py-4 text-sm font-semibold text-slate-900">₹{(order.total || order.grandTotal || 0).toLocaleString()}</td>
                                        <td className="px-6 py-4">
                                            <span className={`inline-flex px-2.5 py-1 rounded-full text-xs font-medium ${statusColors[order.status] || 'bg-slate-100 text-slate-700'}`}>
                                                {order.status || 'Pending'}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4 text-sm text-slate-500">
                                            {order.createdAt?.toLocaleDateString?.('en-IN', { month: 'short', day: 'numeric', year: 'numeric' }) || 'N/A'}
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="flex gap-2">
                                                {getNextStatus(order.status) && (
                                                    <button onClick={() => updateOrderStatus(order.id, getNextStatus(order.status))} className="text-xs bg-emerald-50 text-emerald-600 px-2.5 py-1.5 rounded-lg font-medium hover:bg-emerald-100">
                                                        → {getNextStatus(order.status)}
                                                    </button>
                                                )}
                                                <button onClick={() => setSelectedOrder(order)} className="text-xs text-slate-600 hover:text-slate-900 px-2.5 py-1.5 rounded-lg hover:bg-slate-100">
                                                    View
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}
            </div>

            {/* Order Details Modal */}
            {selectedOrder && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
                    <div className="bg-white rounded-xl max-w-lg w-full max-h-[80vh] overflow-y-auto">
                        <div className="p-5 border-b border-slate-100 flex items-center justify-between">
                            <h2 className="text-xl font-bold text-slate-900">Order #{selectedOrder.orderNumber || selectedOrder.id.substring(0, 8)}</h2>
                            <button onClick={() => setSelectedOrder(null)} className="text-slate-400 hover:text-slate-600">
                                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                                </svg>
                            </button>
                        </div>
                        <div className="p-5 space-y-4">
                            <div className="grid grid-cols-2 gap-4 text-sm">
                                <div><p className="text-slate-500 text-xs uppercase">Customer</p><p className="font-medium text-slate-900">{selectedOrder.customerName || 'Unknown'}</p></div>
                                <div><p className="text-slate-500 text-xs uppercase">Phone</p><p className="font-medium text-slate-900">{selectedOrder.phone || 'N/A'}</p></div>
                                <div className="col-span-2"><p className="text-slate-500 text-xs uppercase">Address</p><p className="font-medium text-slate-900">{selectedOrder.address || 'N/A'}</p></div>
                            </div>
                            <div>
                                <p className="text-slate-500 text-xs uppercase mb-2">Items</p>
                                <div className="space-y-2">
                                    {selectedOrder.items?.map((item, i) => (
                                        <div key={i} className="flex justify-between text-sm bg-slate-50 p-3 rounded-lg">
                                            <span className="text-slate-700">{item.name} × {item.quantity}</span>
                                            <span className="font-medium text-slate-900">₹{item.price * item.quantity}</span>
                                        </div>
                                    )) || <p className="text-slate-400 text-sm">No items</p>}
                                </div>
                            </div>
                            <div className="flex justify-between pt-4 border-t border-slate-100">
                                <span className="font-semibold text-slate-900">Total</span>
                                <span className="font-bold text-emerald-600">₹{(selectedOrder.total || selectedOrder.grandTotal || 0).toLocaleString()}</span>
                            </div>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default Orders;
