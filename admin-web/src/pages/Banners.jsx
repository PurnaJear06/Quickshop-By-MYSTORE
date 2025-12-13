import { useState, useEffect } from 'react';
import { collection, getDocs, addDoc, updateDoc, deleteDoc, doc } from 'firebase/firestore';
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import { db, storage } from '../firebase/config';
import { useDropzone } from 'react-dropzone';

const Banners = () => {
    const [banners, setBanners] = useState([]);
    const [loading, setLoading] = useState(true);
    const [showModal, setShowModal] = useState(false);
    const [editingBanner, setEditingBanner] = useState(null);
    const [filterCategory, setFilterCategory] = useState('All');
    const [image, setImage] = useState(null);
    const [imagePreview, setImagePreview] = useState('');

    const categories = ['All', 'Home', 'Grocery', 'Dairy', 'Fruits', 'Vegetables', 'Offers'];

    const [formData, setFormData] = useState({
        title: '', category: 'Home', linkType: 'none', linkValue: '', displayOrder: 1, startDate: '', endDate: '', isActive: true,
    });

    useEffect(() => { fetchBanners(); }, []);

    const fetchBanners = async () => {
        try {
            const snapshot = await getDocs(collection(db, 'banners'));
            const bannersData = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            bannersData.sort((a, b) => (a.displayOrder || 0) - (b.displayOrder || 0));
            setBanners(bannersData);
            setLoading(false);
        } catch (error) {
            console.error('Error:', error);
            setLoading(false);
        }
    };

    const { getRootProps, getInputProps } = useDropzone({
        accept: { 'image/*': ['.jpeg', '.jpg', '.png', '.webp'] },
        maxFiles: 1,
        onDrop: (acceptedFiles) => {
            setImage(acceptedFiles[0]);
            setImagePreview(URL.createObjectURL(acceptedFiles[0]));
        }
    });

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        try {
            let imageURL = editingBanner?.imageUrl || '';
            if (image) {
                const storageRef = ref(storage, `banners/${Date.now()}_${image.name}`);
                await uploadBytes(storageRef, image);
                imageURL = await getDownloadURL(storageRef);
            }
            const bannerData = { ...formData, imageUrl: imageURL, displayOrder: parseInt(formData.displayOrder), updatedAt: new Date() };
            if (editingBanner) {
                await updateDoc(doc(db, 'banners', editingBanner.id), bannerData);
            } else {
                bannerData.createdAt = new Date();
                await addDoc(collection(db, 'banners'), bannerData);
            }
            fetchBanners();
            closeModal();
        } catch (error) {
            console.error('Error:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async (bannerId) => {
        if (!confirm('Delete this banner?')) return;
        try {
            await deleteDoc(doc(db, 'banners', bannerId));
            fetchBanners();
        } catch (error) {
            console.error('Error:', error);
        }
    };

    const toggleStatus = async (banner) => {
        try {
            await updateDoc(doc(db, 'banners', banner.id), { isActive: !banner.isActive });
            fetchBanners();
        } catch (error) {
            console.error('Error:', error);
        }
    };

    const openModal = (banner = null) => {
        if (banner) {
            setEditingBanner(banner);
            setFormData({ title: banner.title || '', category: banner.category || 'Home', linkType: banner.linkType || 'none', linkValue: banner.linkValue || '', displayOrder: banner.displayOrder || 1, startDate: banner.startDate || '', endDate: banner.endDate || '', isActive: banner.isActive ?? true });
            if (banner.imageUrl) setImagePreview(banner.imageUrl);
        }
        setShowModal(true);
    };

    const closeModal = () => {
        setShowModal(false);
        setEditingBanner(null);
        setImage(null);
        setImagePreview('');
        setFormData({ title: '', category: 'Home', linkType: 'none', linkValue: '', displayOrder: 1, startDate: '', endDate: '', isActive: true });
    };

    const filteredBanners = banners.filter(b => filterCategory === 'All' || b.category === filterCategory);

    return (
        <div className="space-y-6">
            {/* Header with Add Button */}
            <div className="flex items-center justify-end">
                <button onClick={() => openModal()} className="inline-flex items-center gap-2 bg-emerald-500 hover:bg-emerald-600 text-white px-5 py-2.5 rounded-lg font-medium transition-colors">
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                    </svg>
                    Add Banner
                </button>
            </div>

            {/* Category Tabs */}
            <div className="flex gap-2 overflow-x-auto pb-2">
                {categories.map(cat => (
                    <button key={cat} onClick={() => setFilterCategory(cat)} className={`px-4 py-2 rounded-lg text-sm font-medium whitespace-nowrap transition-colors ${filterCategory === cat ? 'bg-emerald-500 text-white' : 'bg-white border border-slate-200 text-slate-600 hover:bg-slate-50'}`}>
                        {cat}
                    </button>
                ))}
            </div>

            {/* Banners Grid */}
            {loading ? (
                <div className="flex items-center justify-center py-12">
                    <div className="w-10 h-10 border-4 border-emerald-500 border-t-transparent rounded-full animate-spin"></div>
                </div>
            ) : filteredBanners.length === 0 ? (
                <div className="text-center py-12 bg-white rounded-xl border border-slate-200">
                    <svg className="w-12 h-12 mx-auto text-slate-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                    <p className="text-slate-500 mt-2">No banners found</p>
                </div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
                    {filteredBanners.map(banner => (
                        <div key={banner.id} className="bg-white rounded-xl border border-slate-200 overflow-hidden hover:shadow-lg transition-shadow">
                            <div className="aspect-[3/1] bg-slate-50 relative">
                                {banner.imageUrl ? (
                                    <img src={banner.imageUrl} alt={banner.title} className="w-full h-full object-cover" />
                                ) : (
                                    <div className="w-full h-full flex items-center justify-center">
                                        <svg className="w-12 h-12 text-slate-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                        </svg>
                                    </div>
                                )}
                                <span className={`absolute top-2 right-2 px-2 py-1 rounded-full text-xs font-medium ${banner.isActive ? 'bg-emerald-100 text-emerald-700' : 'bg-red-100 text-red-700'}`}>
                                    {banner.isActive ? 'Active' : 'Inactive'}
                                </span>
                            </div>
                            <div className="p-4">
                                <h3 className="font-semibold text-slate-900 truncate">{banner.title || 'Untitled'}</h3>
                                <div className="flex items-center gap-2 mt-1 text-xs text-slate-500">
                                    <span className="px-2 py-0.5 bg-slate-100 rounded">{banner.category}</span>
                                    <span>Order: {banner.displayOrder}</span>
                                </div>
                                <div className="flex gap-2 mt-3">
                                    <button onClick={() => toggleStatus(banner)} className={`flex-1 py-2 rounded-lg text-sm font-medium transition-colors ${banner.isActive ? 'bg-amber-50 text-amber-700 hover:bg-amber-100' : 'bg-emerald-50 text-emerald-700 hover:bg-emerald-100'}`}>
                                        {banner.isActive ? 'Deactivate' : 'Activate'}
                                    </button>
                                    <button onClick={() => openModal(banner)} className="flex-1 bg-slate-100 text-slate-700 py-2 rounded-lg text-sm font-medium hover:bg-slate-200 transition-colors">Edit</button>
                                    <button onClick={() => handleDelete(banner.id)} className="px-3 bg-red-50 text-red-600 py-2 rounded-lg text-sm hover:bg-red-100 transition-colors">
                                        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                                        </svg>
                                    </button>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            )}

            {/* Modal */}
            {showModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
                    <div className="bg-white rounded-xl max-w-lg w-full max-h-[90vh] overflow-y-auto">
                        <div className="p-5 border-b border-slate-100 flex items-center justify-between">
                            <h2 className="text-xl font-bold text-slate-900">{editingBanner ? 'Edit Banner' : 'Add New Banner'}</h2>
                            <button onClick={closeModal} className="text-slate-400 hover:text-slate-600">
                                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                                </svg>
                            </button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-5 space-y-4">
                            <div {...getRootProps()} className="border-2 border-dashed border-slate-200 rounded-lg text-center cursor-pointer hover:border-emerald-500 aspect-[3/1] overflow-hidden transition-colors">
                                <input {...getInputProps()} />
                                {imagePreview ? (
                                    <img src={imagePreview} alt="" className="w-full h-full object-cover" />
                                ) : (
                                    <div className="h-full flex flex-col items-center justify-center">
                                        <svg className="w-8 h-8 text-slate-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                        </svg>
                                        <p className="text-slate-500 text-sm mt-2">Drop banner image here</p>
                                    </div>
                                )}
                            </div>
                            <input type="text" required placeholder="Banner Title" value={formData.title} onChange={(e) => setFormData({ ...formData, title: e.target.value })} className="w-full px-4 py-2.5 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500/20" />
                            <div className="grid grid-cols-2 gap-3">
                                <select value={formData.category} onChange={(e) => setFormData({ ...formData, category: e.target.value })} className="px-4 py-2.5 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500/20">
                                    {categories.filter(c => c !== 'All').map(cat => <option key={cat} value={cat}>{cat}</option>)}
                                </select>
                                <input type="number" placeholder="Display Order" value={formData.displayOrder} onChange={(e) => setFormData({ ...formData, displayOrder: e.target.value })} className="px-4 py-2.5 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500/20" />
                            </div>
                            <div className="grid grid-cols-2 gap-3">
                                <div>
                                    <label className="text-xs text-slate-500 mb-1 block">Start Date</label>
                                    <input type="date" value={formData.startDate} onChange={(e) => setFormData({ ...formData, startDate: e.target.value })} className="w-full px-4 py-2.5 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500/20" />
                                </div>
                                <div>
                                    <label className="text-xs text-slate-500 mb-1 block">End Date</label>
                                    <input type="date" value={formData.endDate} onChange={(e) => setFormData({ ...formData, endDate: e.target.value })} className="w-full px-4 py-2.5 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500/20" />
                                </div>
                            </div>
                            <label className="flex items-center gap-2 cursor-pointer">
                                <input type="checkbox" checked={formData.isActive} onChange={(e) => setFormData({ ...formData, isActive: e.target.checked })} className="w-4 h-4 rounded text-emerald-500 focus:ring-emerald-500" />
                                <span className="text-sm text-slate-700">Banner is Active</span>
                            </label>
                            <div className="flex gap-3 pt-2">
                                <button type="button" onClick={closeModal} className="flex-1 px-4 py-2.5 border border-slate-200 rounded-lg hover:bg-slate-50 font-medium text-slate-700">Cancel</button>
                                <button type="submit" disabled={loading} className="flex-1 bg-emerald-500 text-white px-4 py-2.5 rounded-lg hover:bg-emerald-600 font-medium disabled:opacity-50">
                                    {loading ? 'Saving...' : 'Save Banner'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
};

export default Banners;
