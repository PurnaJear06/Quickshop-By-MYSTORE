import { useState, useEffect } from 'react';
import { collection, getDocs, addDoc, updateDoc, deleteDoc, doc } from 'firebase/firestore';
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import { db, storage } from '../firebase/config';
import { useDropzone } from 'react-dropzone';

const Products = () => {
    const [products, setProducts] = useState([]);
    const [loading, setLoading] = useState(true);
    const [showModal, setShowModal] = useState(false);
    const [editingProduct, setEditingProduct] = useState(null);
    const [searchTerm, setSearchTerm] = useState('');
    const [filterCategory, setFilterCategory] = useState('All');
    const [images, setImages] = useState([]);
    const [imagePreviews, setImagePreviews] = useState([]);

    const categories = ['All', 'Grocery', 'Dairy', 'Fruits', 'Vegetables', 'Snacks', 'Beverages', 'Personal Care'];

    const [formData, setFormData] = useState({
        name: '', description: '', price: '', mrp: '', gst: '5', category: 'Grocery',
        unit: 'kg', quantity: '1', stock: '100', isAvailable: true, isFeatured: false,
    });

    useEffect(() => { fetchProducts(); }, []);

    const fetchProducts = async () => {
        try {
            const querySnapshot = await getDocs(collection(db, 'products'));
            const productsData = querySnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            setProducts(productsData);
            setLoading(false);
        } catch (error) {
            console.error('Error fetching products:', error);
            setLoading(false);
        }
    };

    const { getRootProps, getInputProps } = useDropzone({
        accept: { 'image/*': ['.jpeg', '.jpg', '.png', '.webp'] },
        maxFiles: 3,
        onDrop: (acceptedFiles) => {
            setImages([...images, ...acceptedFiles].slice(0, 3));
            const newPreviews = acceptedFiles.map(file => URL.createObjectURL(file));
            setImagePreviews([...imagePreviews, ...newPreviews].slice(0, 3));
        }
    });

    const uploadImages = async () => {
        const uploadPromises = images.map(async (image) => {
            const storageRef = ref(storage, `products/${Date.now()}_${image.name}`);
            await uploadBytes(storageRef, image);
            return getDownloadURL(storageRef);
        });
        return Promise.all(uploadPromises);
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        try {
            let imageURLs = editingProduct?.images || [];
            if (images.length > 0) imageURLs = await uploadImages();

            const productData = {
                ...formData,
                price: parseFloat(formData.price),
                mrp: parseFloat(formData.mrp),
                gst: parseFloat(formData.gst),
                stock: parseInt(formData.stock),
                images: imageURLs,
                discountPercentage: Math.round(((parseFloat(formData.mrp) - parseFloat(formData.price)) / parseFloat(formData.mrp)) * 100),
                updatedAt: new Date(),
            };

            if (editingProduct) {
                await updateDoc(doc(db, 'products', editingProduct.id), productData);
            } else {
                productData.createdAt = new Date();
                await addDoc(collection(db, 'products'), productData);
            }
            fetchProducts();
            closeModal();
        } catch (error) {
            console.error('Error saving product:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async (productId) => {
        if (!confirm('Delete this product?')) return;
        try {
            await deleteDoc(doc(db, 'products', productId));
            fetchProducts();
        } catch (error) {
            console.error('Error:', error);
        }
    };

    const openModal = (product = null) => {
        if (product) {
            setEditingProduct(product);
            setFormData({ name: product.name || '', description: product.description || '', price: product.price?.toString() || '', mrp: product.mrp?.toString() || '', gst: product.gst?.toString() || '5', category: product.category || 'Grocery', unit: product.unit || 'kg', quantity: product.quantity || '1', stock: product.stock?.toString() || '100', isAvailable: product.isAvailable ?? true, isFeatured: product.isFeatured ?? false });
            if (product.images?.length > 0) setImagePreviews(product.images);
        }
        setShowModal(true);
    };

    const closeModal = () => {
        setShowModal(false);
        setEditingProduct(null);
        setImages([]);
        setImagePreviews([]);
        setFormData({ name: '', description: '', price: '', mrp: '', gst: '5', category: 'Grocery', unit: 'kg', quantity: '1', stock: '100', isAvailable: true, isFeatured: false });
    };

    const filteredProducts = products.filter(product => {
        const matchesSearch = product.name?.toLowerCase().includes(searchTerm.toLowerCase());
        const matchesCategory = filterCategory === 'All' || product.category === filterCategory;
        return matchesSearch && matchesCategory;
    });

    return (
        <div className="space-y-6">
            {/* Header with Search and Add Button */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div className="flex items-center gap-4 flex-1">
                    {/* Search */}
                    <div className="relative flex-1 max-w-md">
                        <svg className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                        </svg>
                        <input
                            type="text"
                            placeholder="Search products..."
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                            className="w-full pl-10 pr-4 py-2.5 bg-white border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500"
                        />
                    </div>
                    {/* Category Filter */}
                    <select
                        value={filterCategory}
                        onChange={(e) => setFilterCategory(e.target.value)}
                        className="px-4 py-2.5 bg-white border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                    >
                        {categories.map(cat => <option key={cat} value={cat}>{cat}</option>)}
                    </select>
                </div>
                {/* Add Button */}
                <button
                    onClick={() => openModal()}
                    className="inline-flex items-center gap-2 bg-emerald-500 hover:bg-emerald-600 text-white px-5 py-2.5 rounded-lg font-medium transition-colors"
                >
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                    </svg>
                    Add Product
                </button>
            </div>

            {/* Products Grid */}
            {loading ? (
                <div className="flex items-center justify-center py-12">
                    <div className="w-10 h-10 border-4 border-emerald-500 border-t-transparent rounded-full animate-spin"></div>
                </div>
            ) : filteredProducts.length === 0 ? (
                <div className="text-center py-12 bg-white rounded-xl border border-slate-200">
                    <p className="text-slate-500">No products found</p>
                </div>
            ) : (
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
                    {filteredProducts.map(product => (
                        <div key={product.id} className="bg-white rounded-xl border border-slate-200 overflow-hidden hover:shadow-lg transition-shadow">
                            {/* Product Image */}
                            <div className="aspect-square bg-slate-50 relative">
                                {product.images?.[0] ? (
                                    <img src={product.images[0]} alt={product.name} className="w-full h-full object-cover" />
                                ) : (
                                    <div className="w-full h-full flex items-center justify-center">
                                        <svg className="w-16 h-16 text-slate-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                                        </svg>
                                    </div>
                                )}
                                {/* Category Badge */}
                                <span className="absolute top-3 left-3 bg-slate-900 text-white text-xs px-2 py-1 rounded-full">
                                    {product.category}
                                </span>
                                {!product.isAvailable && (
                                    <div className="absolute inset-0 bg-black/50 flex items-center justify-center">
                                        <span className="text-white font-medium">Out of Stock</span>
                                    </div>
                                )}
                            </div>
                            {/* Product Info */}
                            <div className="p-4">
                                <h3 className="font-semibold text-slate-900 truncate">{product.name}</h3>
                                <p className="text-xs text-slate-500 mt-1">{product.quantity} {product.unit}</p>
                                <div className="flex items-center gap-2 mt-2">
                                    <span className="text-lg font-bold text-emerald-600">₹{product.price}</span>
                                    {product.mrp > product.price && (
                                        <span className="text-sm text-slate-400 line-through">₹{product.mrp}</span>
                                    )}
                                </div>
                                {/* Actions */}
                                <div className="flex gap-2 mt-3">
                                    <button onClick={() => openModal(product)} className="flex-1 bg-slate-100 text-slate-700 py-2 rounded-lg text-sm font-medium hover:bg-slate-200 transition-colors">
                                        Edit
                                    </button>
                                    <button onClick={() => handleDelete(product.id)} className="px-3 bg-red-50 text-red-600 py-2 rounded-lg text-sm hover:bg-red-100 transition-colors">
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

            {/* Add/Edit Product Modal */}
            {showModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50 overflow-y-auto">
                    <div className="bg-white rounded-xl max-w-lg w-full max-h-[90vh] overflow-y-auto">
                        <div className="p-5 border-b border-slate-100 flex items-center justify-between">
                            <h2 className="text-xl font-bold text-slate-900">{editingProduct ? 'Edit Product' : 'Add New Product'}</h2>
                            <button onClick={closeModal} className="text-slate-400 hover:text-slate-600">
                                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                                </svg>
                            </button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-5 space-y-4">
                            {/* Image Upload */}
                            <div {...getRootProps()} className="border-2 border-dashed border-slate-200 rounded-lg p-6 text-center cursor-pointer hover:border-emerald-500 transition-colors">
                                <input {...getInputProps()} />
                                {imagePreviews.length > 0 ? (
                                    <div className="flex gap-2 justify-center">
                                        {imagePreviews.map((preview, i) => <img key={i} src={preview} alt="" className="w-20 h-20 object-cover rounded-lg" />)}
                                    </div>
                                ) : (
                                    <div>
                                        <svg className="w-10 h-10 mx-auto text-slate-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                        </svg>
                                        <p className="text-slate-500 text-sm mt-2">Drop images here or click to upload (max 3)</p>
                                    </div>
                                )}
                            </div>
                            {/* Form Fields */}
                            <input type="text" required placeholder="Product Name" value={formData.name} onChange={(e) => setFormData({ ...formData, name: e.target.value })} className="w-full px-4 py-2.5 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500" />
                            <textarea placeholder="Description" value={formData.description} onChange={(e) => setFormData({ ...formData, description: e.target.value })} className="w-full px-4 py-2.5 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500/20" rows="2" />
                            <div className="grid grid-cols-2 gap-3">
                                <input type="number" required placeholder="Price (₹)" value={formData.price} onChange={(e) => setFormData({ ...formData, price: e.target.value })} className="px-4 py-2.5 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500/20" />
                                <input type="number" required placeholder="MRP (₹)" value={formData.mrp} onChange={(e) => setFormData({ ...formData, mrp: e.target.value })} className="px-4 py-2.5 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500/20" />
                            </div>
                            <div className="grid grid-cols-2 gap-3">
                                <select value={formData.category} onChange={(e) => setFormData({ ...formData, category: e.target.value })} className="px-4 py-2.5 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500/20">
                                    {categories.filter(c => c !== 'All').map(cat => <option key={cat} value={cat}>{cat}</option>)}
                                </select>
                                <input type="number" placeholder="Stock" value={formData.stock} onChange={(e) => setFormData({ ...formData, stock: e.target.value })} className="px-4 py-2.5 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500/20" />
                            </div>
                            <div className="flex gap-6">
                                <label className="flex items-center gap-2 cursor-pointer">
                                    <input type="checkbox" checked={formData.isAvailable} onChange={(e) => setFormData({ ...formData, isAvailable: e.target.checked })} className="w-4 h-4 rounded text-emerald-500 focus:ring-emerald-500" />
                                    <span className="text-sm text-slate-700">Available</span>
                                </label>
                                <label className="flex items-center gap-2 cursor-pointer">
                                    <input type="checkbox" checked={formData.isFeatured} onChange={(e) => setFormData({ ...formData, isFeatured: e.target.checked })} className="w-4 h-4 rounded text-emerald-500 focus:ring-emerald-500" />
                                    <span className="text-sm text-slate-700">Featured</span>
                                </label>
                            </div>
                            {/* Actions */}
                            <div className="flex gap-3 pt-2">
                                <button type="button" onClick={closeModal} className="flex-1 px-4 py-2.5 border border-slate-200 rounded-lg hover:bg-slate-50 font-medium text-slate-700 transition-colors">Cancel</button>
                                <button type="submit" disabled={loading} className="flex-1 bg-emerald-500 text-white px-4 py-2.5 rounded-lg hover:bg-emerald-600 font-medium disabled:opacity-50 transition-colors">
                                    {loading ? 'Saving...' : 'Save Product'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
};

export default Products;
