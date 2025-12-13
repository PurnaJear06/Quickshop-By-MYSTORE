import { useState, useEffect } from 'react';
import { collection, getDocs, addDoc, updateDoc, deleteDoc, doc } from 'firebase/firestore';
import { db } from '../firebase/config';
import { MapContainer, TileLayer, Marker, Circle, useMapEvents } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';

const DarkStores = () => {
    const [stores, setStores] = useState([]);
    const [loading, setLoading] = useState(true);
    const [showModal, setShowModal] = useState(false);
    const [editingStore, setEditingStore] = useState(null);
    const [selectedLocation, setSelectedLocation] = useState({ lat: 17.385, lng: 78.4867 });

    const [formData, setFormData] = useState({
        name: '', address: '', phone: '', manager: '', openTime: '09:00', closeTime: '22:00', radius: 5, isActive: true,
    });

    useEffect(() => { fetchStores(); }, []);

    const fetchStores = async () => {
        try {
            const snapshot = await getDocs(collection(db, 'darkStores'));
            const storesData = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            setStores(storesData);
            setLoading(false);
        } catch (error) {
            console.error('Error:', error);
            setLoading(false);
        }
    };

    const LocationMarker = () => {
        useMapEvents({
            click(e) {
                setSelectedLocation({ lat: e.latlng.lat, lng: e.latlng.lng });
            },
        });
        return <Marker position={[selectedLocation.lat, selectedLocation.lng]} />;
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        try {
            const storeData = { ...formData, location: selectedLocation, radius: parseInt(formData.radius), updatedAt: new Date() };
            if (editingStore) {
                await updateDoc(doc(db, 'darkStores', editingStore.id), storeData);
            } else {
                storeData.createdAt = new Date();
                await addDoc(collection(db, 'darkStores'), storeData);
            }
            fetchStores();
            closeModal();
        } catch (error) {
            console.error('Error:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async (storeId) => {
        if (!confirm('Delete this store?')) return;
        try {
            await deleteDoc(doc(db, 'darkStores', storeId));
            fetchStores();
        } catch (error) {
            console.error('Error:', error);
        }
    };

    const toggleStoreStatus = async (store) => {
        try {
            await updateDoc(doc(db, 'darkStores', store.id), { isActive: !store.isActive });
            fetchStores();
        } catch (error) {
            console.error('Error:', error);
        }
    };

    const openModal = (store = null) => {
        if (store) {
            setEditingStore(store);
            setFormData({ name: store.name || '', address: store.address || '', phone: store.phone || '', manager: store.manager || '', openTime: store.openTime || '09:00', closeTime: store.closeTime || '22:00', radius: store.radius || 5, isActive: store.isActive ?? true });
            if (store.location) setSelectedLocation(store.location);
        }
        setShowModal(true);
    };

    const closeModal = () => {
        setShowModal(false);
        setEditingStore(null);
        setFormData({ name: '', address: '', phone: '', manager: '', openTime: '09:00', closeTime: '22:00', radius: 5, isActive: true });
        setSelectedLocation({ lat: 17.385, lng: 78.4867 });
    };

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div></div>
                <button onClick={() => openModal()} className="inline-flex items-center gap-2 bg-emerald-500 hover:bg-emerald-600 text-white px-5 py-2.5 rounded-lg font-medium transition-colors">
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                    </svg>
                    Add Store
                </button>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                {/* Map */}
                <div className="bg-white rounded-xl border border-slate-200 overflow-hidden h-[500px]">
                    <MapContainer center={[17.385, 78.4867]} zoom={11} style={{ height: '100%', width: '100%' }}>
                        <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
                        {stores.map(store => store.location && (
                            <div key={store.id}>
                                <Marker position={[store.location.lat, store.location.lng]} />
                                <Circle center={[store.location.lat, store.location.lng]} radius={store.radius * 1000} pathOptions={{ color: store.isActive ? '#10B981' : '#EF4444', fillOpacity: 0.2 }} />
                            </div>
                        ))}
                    </MapContainer>
                </div>

                {/* Store Cards */}
                <div className="space-y-4 max-h-[500px] overflow-y-auto">
                    {loading ? (
                        <div className="flex items-center justify-center py-12">
                            <div className="w-10 h-10 border-4 border-emerald-500 border-t-transparent rounded-full animate-spin"></div>
                        </div>
                    ) : stores.length === 0 ? (
                        <div className="text-center py-12 bg-white rounded-xl border border-slate-200">
                            <svg className="w-12 h-12 mx-auto text-slate-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                            </svg>
                            <p className="text-slate-500 mt-2">No stores yet</p>
                        </div>
                    ) : (
                        stores.map(store => (
                            <div key={store.id} className="bg-white rounded-xl border border-slate-200 p-4">
                                <div className="flex items-start justify-between">
                                    <div>
                                        <div className="flex items-center gap-2">
                                            <h3 className="font-semibold text-slate-900">{store.name}</h3>
                                            <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${store.isActive ? 'bg-emerald-100 text-emerald-700' : 'bg-red-100 text-red-700'}`}>
                                                {store.isActive ? 'Active' : 'Inactive'}
                                            </span>
                                        </div>
                                        <p className="text-sm text-slate-500 mt-1">{store.address}</p>
                                        <div className="flex items-center gap-3 mt-2 text-xs text-slate-400">
                                            <span className="flex items-center gap-1">
                                                <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                                                </svg>
                                                {store.radius}km radius
                                            </span>
                                            <span className="flex items-center gap-1">
                                                <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                                                </svg>
                                                {store.openTime} - {store.closeTime}
                                            </span>
                                        </div>
                                    </div>
                                </div>
                                <div className="flex gap-2 mt-4">
                                    <button onClick={() => toggleStoreStatus(store)} className={`flex-1 py-2 rounded-lg text-sm font-medium transition-colors ${store.isActive ? 'bg-amber-50 text-amber-700 hover:bg-amber-100' : 'bg-emerald-50 text-emerald-700 hover:bg-emerald-100'}`}>
                                        {store.isActive ? 'Deactivate' : 'Activate'}
                                    </button>
                                    <button onClick={() => openModal(store)} className="flex-1 bg-slate-100 text-slate-700 py-2 rounded-lg text-sm font-medium hover:bg-slate-200 transition-colors">Edit</button>
                                    <button onClick={() => handleDelete(store.id)} className="px-3 bg-red-50 text-red-600 py-2 rounded-lg text-sm hover:bg-red-100 transition-colors">
                                        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                                        </svg>
                                    </button>
                                </div>
                            </div>
                        ))
                    )}
                </div>
            </div>

            {/* Modal */}
            {showModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50 overflow-y-auto">
                    <div className="bg-white rounded-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
                        <div className="p-5 border-b border-slate-100 flex items-center justify-between">
                            <h2 className="text-xl font-bold text-slate-900">{editingStore ? 'Edit Store' : 'Add New Store'}</h2>
                            <button onClick={closeModal} className="text-slate-400 hover:text-slate-600">
                                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                                </svg>
                            </button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-5 space-y-4">
                            <div className="h-48 rounded-lg overflow-hidden border border-slate-200">
                                <MapContainer center={[selectedLocation.lat, selectedLocation.lng]} zoom={13} style={{ height: '100%', width: '100%' }}>
                                    <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
                                    <LocationMarker />
                                    <Circle center={[selectedLocation.lat, selectedLocation.lng]} radius={formData.radius * 1000} pathOptions={{ color: '#10B981', fillOpacity: 0.2 }} />
                                </MapContainer>
                            </div>
                            <p className="text-xs text-slate-500 text-center">Click on map to set location</p>
                            <input type="text" required placeholder="Store Name" value={formData.name} onChange={(e) => setFormData({ ...formData, name: e.target.value })} className="w-full px-4 py-2.5 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500/20" />
                            <input type="text" required placeholder="Address" value={formData.address} onChange={(e) => setFormData({ ...formData, address: e.target.value })} className="w-full px-4 py-2.5 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500/20" />
                            <div className="grid grid-cols-2 gap-3">
                                <input type="tel" placeholder="Phone" value={formData.phone} onChange={(e) => setFormData({ ...formData, phone: e.target.value })} className="px-4 py-2.5 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500/20" />
                                <input type="text" placeholder="Manager" value={formData.manager} onChange={(e) => setFormData({ ...formData, manager: e.target.value })} className="px-4 py-2.5 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500/20" />
                            </div>
                            <div className="grid grid-cols-3 gap-3">
                                <div>
                                    <label className="text-xs text-slate-500 mb-1 block">Open Time</label>
                                    <input type="time" value={formData.openTime} onChange={(e) => setFormData({ ...formData, openTime: e.target.value })} className="w-full px-4 py-2.5 border border-slate-200 rounded-lg" />
                                </div>
                                <div>
                                    <label className="text-xs text-slate-500 mb-1 block">Close Time</label>
                                    <input type="time" value={formData.closeTime} onChange={(e) => setFormData({ ...formData, closeTime: e.target.value })} className="w-full px-4 py-2.5 border border-slate-200 rounded-lg" />
                                </div>
                                <div>
                                    <label className="text-xs text-slate-500 mb-1 block">Radius: {formData.radius}km</label>
                                    <input type="range" min="1" max="20" value={formData.radius} onChange={(e) => setFormData({ ...formData, radius: e.target.value })} className="w-full mt-2 accent-emerald-500" />
                                </div>
                            </div>
                            <label className="flex items-center gap-2 cursor-pointer">
                                <input type="checkbox" checked={formData.isActive} onChange={(e) => setFormData({ ...formData, isActive: e.target.checked })} className="w-4 h-4 rounded text-emerald-500 focus:ring-emerald-500" />
                                <span className="text-sm text-slate-700">Store is Active</span>
                            </label>
                            <div className="flex gap-3 pt-2">
                                <button type="button" onClick={closeModal} className="flex-1 px-4 py-2.5 border border-slate-200 rounded-lg hover:bg-slate-50 font-medium text-slate-700">Cancel</button>
                                <button type="submit" disabled={loading} className="flex-1 bg-emerald-500 text-white px-4 py-2.5 rounded-lg hover:bg-emerald-600 font-medium disabled:opacity-50">
                                    {loading ? 'Saving...' : 'Save Store'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
};

export default DarkStores;
