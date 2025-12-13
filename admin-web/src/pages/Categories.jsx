import { useState, useEffect } from 'react';
import { collection, getDocs, addDoc, updateDoc, deleteDoc, doc } from 'firebase/firestore';
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import { db, storage } from '../firebase/config';
import { useDropzone } from 'react-dropzone';

const Categories = () => {
    const [categories, setCategories] = useState([]);
    const [loading, setLoading] = useState(true);
    const [showModal, setShowModal] = useState(false);
    const [editingCategory, setEditingCategory] = useState(null);
    const [icon, setIcon] = useState(null);
    const [iconPreview, setIconPreview] = useState('');

    const colorPresets = ['#22C55E', '#3B82F6', '#EF4444', '#F59E0B', '#8B5CF6', '#EC4899', '#14B8A6', '#6366F1', '#F97316', '#84CC16'];

    const [formData, setFormData] = useState({
        name: '', description: '', color: '#22C55E', displayOrder: 1, isActive: true,
    });

    useEffect(() => { fetchCategories(); }, []);

    const fetchCategories = async () => {
        try {
            const snapshot = await getDocs(collection(db, 'categories'));
            const categoriesData = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            categoriesData.sort((a, b) => (a.displayOrder || 0) - (b.displayOrder || 0));
            setCategories(categoriesData);
            setLoading(false);
        } catch (error) {
            console.error('Error:', error);
            setLoading(false);
        }
    };

    const { getRootProps, getInputProps } = useDropzone({
        accept: { 'image/*': ['.jpeg', '.jpg', '.png', '.webp', '.svg'] },
        maxFiles: 1,
        onDrop: (acceptedFiles) => {
            setIcon(acceptedFiles[0]);
            setIconPreview(URL.createObjectURL(acceptedFiles[0]));
        }
    });

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        try {
            let iconURL = editingCategory?.iconUrl || '';
            if (icon) {
                const storageRef = ref(storage, `categories/${Date.now()}_${icon.name}`);
                await uploadBytes(storageRef, icon);
                iconURL = await getDownloadURL(storageRef);
            }
            const categoryData = { ...formData, iconUrl: iconURL, displayOrder: parseInt(formData.displayOrder), updatedAt: new Date() };
            if (editingCategory) {
                await updateDoc(doc(db, 'categories', editingCategory.id), categoryData);
            } else {
                categoryData.createdAt = new Date();
                await addDoc(collection(db, 'categories'), categoryData);
            }
            fetchCategories();
            closeModal();
        } catch (error) {
            console.error('Error:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async (categoryId) => {
        if (!confirm('Delete this category?')) return;
        try {
            await deleteDoc(doc(db, 'categories', categoryId));
            fetchCategories();
        } catch (error) {
            console.error('Error:', error);
        }
    };

    const toggleStatus = async (category) => {
        try {
            await updateDoc(doc(db, 'categories', category.id), { isActive: !category.isActive });
            fetchCategories();
        } catch (error) {
            console.error('Error:', error);
        }
    };

    const openModal = (category = null) => {
        if (category) {
            setEditingCategory(category);
            setFormData({ name: category.name || '', description: category.description || '', color: category.color || '#22C55E', displayOrder: category.displayOrder || 1, isActive: category.isActive ?? true });
            if (category.iconUrl) setIconPreview(category.iconUrl);
        }
        setShowModal(true);
    };

    const closeModal = () => {
        setShowModal(false);
        setEditingCategory(null);
        setIcon(null);
        setIconPreview('');
        setFormData({ name: '', description: '', color: '#22C55E', displayOrder: 1, isActive: true });
    };

    const stats = {
        total: categories.length,
        active: categories.filter(c => c.isActive).length,
        inactive: categories.filter(c => !c.isActive).length,
    };

    return (
        <div className="p-6">
            <div className="flex items-center justify-between mb-6">
                <h1 className="text-2xl font-bold">Categories Management</h1>
                <button onClick={() => openModal()} className="bg-primary hover:bg-primary-dark text-white px-5 py-2 rounded-lg font-medium">+ Add Category</button>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-3 gap-4 mb-6">
                <div className="bg-white rounded-xl border border-gray-100 p-4 text-center"><p className="text-gray-500 text-sm">Total</p><p className="text-2xl font-bold">{stats.total}</p></div>
                <div className="bg-green-50 rounded-xl border border-green-100 p-4 text-center"><p className="text-green-600 text-sm">Active</p><p className="text-2xl font-bold text-green-700">{stats.active}</p></div>
                <div className="bg-red-50 rounded-xl border border-red-100 p-4 text-center"><p className="text-red-600 text-sm">Inactive</p><p className="text-2xl font-bold text-red-700">{stats.inactive}</p></div>
            </div>

            {/* Categories Grid */}
            {loading ? (
                <div className="text-center py-12 text-gray-500">Loading...</div>
            ) : categories.length === 0 ? (
                <div className="text-center py-12 bg-white rounded-xl border border-gray-100"><p className="text-gray-500">No categories found</p></div>
            ) : (
                <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-4">
                    {categories.map(category => (
                        <div key={category.id} className="bg-white rounded-xl border border-gray-100 overflow-hidden hover:shadow-md transition-shadow">
                            <div className="p-4 text-center" style={{ backgroundColor: `${category.color}15` }}>
                                <div className="w-16 h-16 rounded-xl mx-auto flex items-center justify-center text-3xl" style={{ backgroundColor: category.color }}>
                                    {category.iconUrl ? <img src={category.iconUrl} alt="" className="w-10 h-10 object-contain" /> : '📁'}
                                </div>
                            </div>
                            <div className="p-4">
                                <h3 className="font-semibold text-center truncate">{category.name}</h3>
                                <p className="text-xs text-gray-500 text-center mt-1">Order: {category.displayOrder}</p>
                                <div className="flex items-center justify-center gap-2 mt-2">
                                    <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${category.isActive ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
                                        {category.isActive ? 'Active' : 'Inactive'}
                                    </span>
                                </div>
                                <div className="flex gap-1 mt-3">
                                    <button onClick={() => toggleStatus(category)} className={`flex-1 py-1.5 rounded-lg text-xs font-medium ${category.isActive ? 'bg-yellow-50 text-yellow-700' : 'bg-green-50 text-green-700'}`}>
                                        {category.isActive ? '⏸️' : '▶️'}
                                    </button>
                                    <button onClick={() => openModal(category)} className="flex-1 bg-blue-50 text-blue-600 py-1.5 rounded-lg text-xs font-medium">✏️</button>
                                    <button onClick={() => handleDelete(category.id)} className="flex-1 bg-red-50 text-red-600 py-1.5 rounded-lg text-xs">🗑️</button>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            )}

            {/* Modal */}
            {showModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
                    <div className="bg-white rounded-xl max-w-md w-full max-h-[90vh] overflow-y-auto">
                        <div className="p-5 border-b border-gray-100"><h2 className="text-xl font-bold">{editingCategory ? 'Edit Category' : 'Add Category'}</h2></div>
                        <form onSubmit={handleSubmit} className="p-5 space-y-4">
                            <div {...getRootProps()} className="border-2 border-dashed border-gray-200 rounded-lg p-4 text-center cursor-pointer hover:border-primary">
                                <input {...getInputProps()} />
                                {iconPreview ? <img src={iconPreview} alt="" className="w-16 h-16 object-contain mx-auto" /> : <p className="text-gray-500 text-sm">Drop icon image here</p>}
                            </div>
                            <input type="text" required placeholder="Category Name" value={formData.name} onChange={(e) => setFormData({ ...formData, name: e.target.value })} className="w-full px-3 py-2 border rounded-lg" />
                            <textarea placeholder="Description" value={formData.description} onChange={(e) => setFormData({ ...formData, description: e.target.value })} className="w-full px-3 py-2 border rounded-lg" rows="2" />
                            <div>
                                <p className="text-sm text-gray-500 mb-2">Color</p>
                                <div className="flex flex-wrap gap-2">
                                    {colorPresets.map(color => (
                                        <button key={color} type="button" onClick={() => setFormData({ ...formData, color })} className={`w-8 h-8 rounded-full border-2 ${formData.color === color ? 'border-gray-800' : 'border-transparent'}`} style={{ backgroundColor: color }} />
                                    ))}
                                </div>
                            </div>
                            <input type="number" placeholder="Display Order" value={formData.displayOrder} onChange={(e) => setFormData({ ...formData, displayOrder: e.target.value })} className="w-full px-3 py-2 border rounded-lg" />
                            <label className="flex items-center gap-2"><input type="checkbox" checked={formData.isActive} onChange={(e) => setFormData({ ...formData, isActive: e.target.checked })} /> Category is Active</label>
                            <div className="flex gap-3 pt-2">
                                <button type="button" onClick={closeModal} className="flex-1 px-4 py-2 border border-gray-200 rounded-lg">Cancel</button>
                                <button type="submit" disabled={loading} className="flex-1 bg-primary text-white px-4 py-2 rounded-lg">{loading ? 'Saving...' : 'Save'}</button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
};

export default Categories;
