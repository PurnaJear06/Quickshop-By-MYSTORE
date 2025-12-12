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

    // Form state
    const [formData, setFormData] = useState({
        name: '',
        description: '',
        price: '',
        mrp: '',
        gst: '5',
        category: 'Dairy',
        unit: 'kg',
        quantity: '',
        stock: '50',
        isAvailable: true,
        isFeatured: false,
    });
    const [images, setImages] = useState([]);
    const [imagePreivews, setImagePreviews] = useState([]);

    const categories = ['All', 'Dairy', 'Fruits', 'Vegetables', 'Snacks', 'Beverages', 'Personal Care'];

    useEffect(() => {
        fetchProducts();
    }, []);

    const fetchProducts = async () => {
        try {
            const querySnapshot = await getDocs(collection(db, 'products'));
            const productsData = querySnapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            }));
            setProducts(productsData);
            setLoading(false);
        } catch (error) {
            console.error('Error fetching products:', error);
            setLoading(false);
        }
    };

    const { getRootProps, getInputProps } = useDropzone({
        accept: {
            'image/*': ['.jpeg', '.jpg', '.png', '.webp']
        },
        maxFiles: 3,
        onDrop: (acceptedFiles) => {
            if (images.length + acceptedFiles.length > 3) {
                alert('Maximum 3 images allowed');
                return;
            }
            setImages(prev => [...prev, ...acceptedFiles]);

            // Create previews
            acceptedFiles.forEach(file => {
                const reader = new FileReader();
                reader.onload = () => {
                    setImagePreviews(prev => [...prev, reader.result]);
                };
                reader.readAsDataURL(file);
            });
        }
    });

    const removeImage = (index) => {
        setImages(prev => prev.filter((_, i) => i !== index));
        setImagePreviews(prev => prev.filter((_, i) => i !== index));
    };

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
            // Upload images
            const imageURLs = images.length > 0 ? await uploadImages() : [];

            const productData = {
                ...formData,
                price: parseFloat(formData.price),
                mrp: parseFloat(formData.mrp),
                gst: parseFloat(formData.gst),
                quantity: parseFloat(formData.quantity),
                stock: parseInt(formData.stock),
                discountPercentage: Math.round(((formData.mrp - formData.price) / formData.mrp) * 100),
                imageURL: imageURLs[0] || '',
                images: imageURLs,
                createdAt: new Date(),
                updatedAt: new Date(),
            };

            if (editingProduct) {
                await updateDoc(doc(db, 'products', editingProduct.id), productData);
            } else {
                await addDoc(collection(db, 'products'), productData);
            }

            fetchProducts();
            closeModal();
        } catch (error) {
            console.error('Error saving product:', error);
            alert('Error saving product');
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async (productId) => {
        if (!confirm('Are you sure you want to delete this product?')) return;

        try {
            await deleteDoc(doc(db, 'products', productId));
            fetchProducts();
        } catch (error) {
            console.error('Error deleting product:', error);
            alert('Error deleting product');
        }
    };

    const openModal = (product = null) => {
        if (product) {
            setEditingProduct(product);
            setFormData({
                name: product.name,
                description: product.description || '',
                price: product.price,
                mrp: product.mrp,
                gst: product.gst || 5,
                category: product.category,
                unit: product.unit,
                quantity: product.quantity,
                stock: product.stock || 50,
                isAvailable: product.isAvailable,
                isFeatured: product.isFeatured || false,
            });
            if (product.images && product.images.length > 0) {
                setImagePreviews(product.images);
            }
        }
        setShowModal(true);
    };

    const closeModal = () => {
        setShowModal(false);
        setEditingProduct(null);
        setFormData({
            name: '',
            description: '',
            price: '',
            mrp: '',
            gst: '5',
            category: 'Dairy',
            unit: 'kg',
            quantity: '',
            stock: '50',
            isAvailable: true,
            isFeatured: false,
        });
        setImages([]);
        setImagePreviews([]);
    };

    const filteredProducts = products.filter(product => {
        const matchesSearch = product.name.toLowerCase().includes(searchTerm.toLowerCase());
        const matchesCategory = filterCategory === 'All' || product.category === filterCategory;
        return matchesSearch && matchesCategory;
    });

    return (
        <div>
            <div className="flex items-center justify-between mb-6">
                <h1 className="text-3xl font-bold">Products Management</h1>
                <button
                    onClick={() => openModal()}
                    className="bg-primary hover:bg-primary-dark text-white px-6 py-3 rounded-lg font-medium"
                >
                    + Add Product
                </button>
            </div>

            {/* Filters */}
            <div className="flex gap-4 mb-6">
                <input
                    type="text"
                    placeholder="Search products..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                />
                <select
                    value={filterCategory}
                    onChange={(e) => setFilterCategory(e.target.value)}
                    className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                >
                    {categories.map(cat => (
                        <option key={cat} value={cat}>{cat}</option>
                    ))}
                </select>
            </div>

            {/* Products Grid */}
            {loading ? (
                <div className="text-center py-12">Loading products...</div>
            ) : filteredProducts.length === 0 ? (
                <div className="text-center py-12 bg-white rounded-lg">
                    <p className="text-gray-500">No products found. Add your first product!</p>
                </div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                    {filteredProducts.map(product => (
                        <div key={product.id} className="bg-white rounded-lg shadow overflow-hidden">
                            <div className="h-48 bg-gray-200 relative">
                                {product.imageURL || product.images?.[0] ? (
                                    <img
                                        src={product.imageURL || product.images[0]}
                                        alt={product.name}
                                        className="w-full h-full object-cover"
                                    />
                                ) : (
                                    <div className="flex items-center justify-center h-full text-gray-400">
                                        No Image
                                    </div>
                                )}
                                {product.isFeatured && (
                                    <span className="absolute top-2 right-2 bg-yellow-500 text-white text-xs px-2 py-1 rounded">
                                        Featured
                                    </span>
                                )}
                            </div>
                            <div className="p-4">
                                <h3 className="font-bold text-lg mb-1">{product.name}</h3>
                                <p className="text-gray-600 text-sm mb-2">{product.category}</p>
                                <div className="flex items-center gap-2 mb-2">
                                    <span className="text-2xl font-bold text-primary">₹{product.price}</span>
                                    {product.mrp > product.price && (
                                        <>
                                            <span className="text-gray-400 line-through">₹{product.mrp}</span>
                                            <span className="text-green-600 text-sm font-medium">
                                                {product.discountPercentage}% off
                                            </span>
                                        </>
                                    )}
                                </div>
                                <p className="text-sm text-gray-600 mb-3">Stock: {product.stock || 0}</p>
                                <div className="flex items-center gap-2">
                                    <span className={`px-2 py-1 rounded-full text-xs ${product.isAvailable ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                                        }`}>
                                        {product.isAvailable ? 'Available' : 'Unavailable'}
                                    </span>
                                </div>
                                <div className="flex gap-2 mt-4">
                                    <button
                                        onClick={() => openModal(product)}
                                        className="flex-1 bg-blue-500 hover:bg-blue-600 text-white py-2 rounded"
                                    >
                                        Edit
                                    </button>
                                    <button
                                        onClick={() => handleDelete(product.id)}
                                        className="flex-1 bg-red-500 hover:bg-red-600 text-white py-2 rounded"
                                    >
                                        Delete
                                    </button>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            )}

            {/* Add/Edit Modal */}
            {showModal && (
                <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50 overflow-y-auto">
                    <div className="bg-white rounded-lg max-w-2xl w-full my-8">
                        <div className="p-6 border-b">
                            <h2 className="text-2xl font-bold">
                                {editingProduct ? 'Edit Product' : 'Add New Product'}
                            </h2>
                        </div>
                        <form onSubmit={handleSubmit} className="p-6">
                            {/* Image Upload */}
                            <div className="mb-6">
                                <label className="block text-sm font-medium mb-2">Product Images (Max 3)</label>
                                <div {...getRootProps()} className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center cursor-pointer hover:border-primary">
                                    <input {...getInputProps()} />
                                    <p className="text-gray-600">Drag & drop images here, or click to select</p>
                                    <p className="text-sm text-gray-400 mt-1">Up to 3 images</p>
                                </div>
                                {imagePreviews.length > 0 && (
                                    <div className="grid grid-cols-3 gap-4 mt-4">
                                        {imagePreviews.map((preview, index) => (
                                            <div key={index} className="relative">
                                                <img src={preview} alt={`Preview ${index + 1}`} className="w-full h-32 object-cover rounded" />
                                                <button
                                                    type="button"
                                                    onClick={() => removeImage(index)}
                                                    className="absolute top-1 right-1 bg-red-500 text-white rounded-full w-6 h-6 flex items-center justify-center"
                                                >
                                                    ×
                                                </button>
                                            </div>
                                        ))}
                                    </div>
                                )}
                            </div>

                            <div className="grid grid-cols-2 gap-4 mb-4">
                                <div>
                                    <label className="block text-sm font-medium mb-1">Product Name*</label>
                                    <input
                                        type="text"
                                        required
                                        value={formData.name}
                                        onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                        className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-primary"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium mb-1">Category*</label>
                                    <select
                                        required
                                        value={formData.category}
                                        onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                                        className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-primary"
                                    >
                                        {categories.filter(c => c !== 'All').map(cat => (
                                            <option key={cat} value={cat}>{cat}</option>
                                        ))}
                                    </select>
                                </div>
                            </div>

                            <div className="mb-4">
                                <label className="block text-sm font-medium mb-1">Description</label>
                                <textarea
                                    value={formData.description}
                                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                                    className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-primary"
                                    rows="2"
                                />
                            </div>

                            <div className="grid grid-cols-2 gap-4 mb-4">
                                <div>
                                    <label className="block text-sm font-medium mb-1">Price (₹)*</label>
                                    <input
                                        type="number"
                                        required
                                        step="0.01"
                                        value={formData.price}
                                        onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                                        className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-primary"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium mb-1">MRP (₹)*</label>
                                    <input
                                        type="number"
                                        required
                                        step="0.01"
                                        value={formData.mrp}
                                        onChange={(e) => setFormData({ ...formData, mrp: e.target.value })}
                                        className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-primary"
                                    />
                                </div>
                            </div>

                            <div className="grid grid-cols-3 gap-4 mb-4">
                                <div>
                                    <label className="block text-sm font-medium mb-1">GST (%)</label>
                                    <input
                                        type="number"
                                        value={formData.gst}
                                        onChange={(e) => setFormData({ ...formData, gst: e.target.value })}
                                        className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-primary"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium mb-1">Unit*</label>
                                    <select
                                        required
                                        value={formData.unit}
                                        onChange={(e) => setFormData({ ...formData, unit: e.target.value })}
                                        className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-primary"
                                    >
                                        <option value="kg">kg</option>
                                        <option value="g">g</option>
                                        <option value="piece">piece</option>
                                        <option value="liter">liter</option>
                                        <option value="ml">ml</option>
                                    </select>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium mb-1">Quantity*</label>
                                    <input
                                        type="number"
                                        required
                                        step="0.01"
                                        value={formData.quantity}
                                        onChange={(e) => setFormData({ ...formData, quantity: e.target.value })}
                                        className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-primary"
                                    />
                                </div>
                            </div>

                            <div className="mb-4">
                                <label className="block text-sm font-medium mb-1">Stock Quantity</label>
                                <input
                                    type="number"
                                    value={formData.stock}
                                    onChange={(e) => setFormData({ ...formData, stock: e.target.value })}
                                    className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-primary"
                                />
                            </div>

                            <div className="flex gap-6 mb-6">
                                <label className="flex items-center">
                                    <input
                                        type="checkbox"
                                        checked={formData.isAvailable}
                                        onChange={(e) => setFormData({ ...formData, isAvailable: e.target.checked })}
                                        className="mr-2"
                                    />
                                    Available
                                </label>
                                <label className="flex items-center">
                                    <input
                                        type="checkbox"
                                        checked={formData.isFeatured}
                                        onChange={(e) => setFormData({ ...formData, isFeatured: e.target.checked })}
                                        className="mr-2"
                                    />
                                    Featured
                                </label>
                            </div>

                            <div className="flex gap-3">
                                <button
                                    type="button"
                                    onClick={closeModal}
                                    className="flex-1 px-4 py-2 border border-gray-300 rounded hover:bg-gray-50"
                                >
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    disabled={loading}
                                    className="flex-1 bg-primary hover:bg-primary-dark text-white px-4 py-2 rounded disabled:opacity-50"
                                >
                                    {loading ? 'Saving...' : (editingProduct ? 'Update Product' : 'Save Product')}
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
