import { useState, useEffect } from 'react';
import { doc, getDoc, setDoc } from 'firebase/firestore';
import { db } from '../firebase/config';

const Settings = () => {
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [activeTab, setActiveTab] = useState('general');
    const [saved, setSaved] = useState(false);

    const [settings, setSettings] = useState({
        // General
        appName: 'QuickShop', tagline: 'Your 10-minute grocery', supportEmail: 'support@quickshop.com', supportPhone: '+91 9876543210', currency: 'INR', timezone: 'Asia/Kolkata',
        // Delivery
        minOrderAmount: 99, deliveryFee: 25, freeDeliveryThreshold: 499, maxDeliveryRadius: 10, estimatedDeliveryTime: '10-15 mins', enableDeliverySlots: false,
        // Orders
        orderIdPrefix: 'QS', enableCOD: true, enableOnlinePayment: true, autoConfirmOrders: false,
        // Notifications
        enableEmailNotifications: true, enablePushNotifications: true, enableSMSNotifications: false,
        // Maintenance
        maintenanceMode: false, maintenanceMessage: 'We are currently under maintenance. Please check back later.',
    });

    const tabs = [
        { id: 'general', name: 'General', icon: '⚙️' },
        { id: 'delivery', name: 'Delivery', icon: '🚚' },
        { id: 'orders', name: 'Orders', icon: '📦' },
        { id: 'notifications', name: 'Notifications', icon: '🔔' },
        { id: 'maintenance', name: 'Maintenance', icon: '🔧' },
    ];

    useEffect(() => { fetchSettings(); }, []);

    const fetchSettings = async () => {
        try {
            const docRef = doc(db, 'settings', 'app');
            const docSnap = await getDoc(docRef);
            if (docSnap.exists()) setSettings({ ...settings, ...docSnap.data() });
            setLoading(false);
        } catch (error) {
            console.error('Error:', error);
            setLoading(false);
        }
    };

    const saveSettings = async () => {
        setSaving(true);
        try {
            await setDoc(doc(db, 'settings', 'app'), { ...settings, updatedAt: new Date() });
            setSaved(true);
            setTimeout(() => setSaved(false), 2000);
        } catch (error) {
            console.error('Error:', error);
        } finally {
            setSaving(false);
        }
    };

    const updateSetting = (key, value) => setSettings({ ...settings, [key]: value });

    if (loading) return <div className="p-6 text-center py-20 text-gray-500">Loading settings...</div>;

    return (
        <div className="p-6">
            <div className="flex items-center justify-between mb-6">
                <h1 className="text-2xl font-bold">Settings</h1>
                <button onClick={saveSettings} disabled={saving} className="bg-primary hover:bg-primary-dark text-white px-5 py-2 rounded-lg font-medium disabled:opacity-50">
                    {saving ? 'Saving...' : saved ? '✓ Saved!' : 'Save Changes'}
                </button>
            </div>

            {/* Tabs */}
            <div className="flex gap-2 mb-6 overflow-x-auto pb-2">
                {tabs.map(tab => (
                    <button key={tab.id} onClick={() => setActiveTab(tab.id)} className={`px-4 py-2 rounded-lg text-sm font-medium whitespace-nowrap flex items-center gap-2 ${activeTab === tab.id ? 'bg-primary text-white' : 'bg-white border border-gray-200 text-gray-600'}`}>
                        <span>{tab.icon}</span> {tab.name}
                    </button>
                ))}
            </div>

            <div className="bg-white rounded-xl border border-gray-100 p-6">
                {/* General Tab */}
                {activeTab === 'general' && (
                    <div className="space-y-5">
                        <h3 className="font-bold text-lg mb-4">General Settings</h3>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div><label className="block text-sm text-gray-500 mb-1">App Name</label><input type="text" value={settings.appName} onChange={(e) => updateSetting('appName', e.target.value)} className="w-full px-3 py-2 border rounded-lg" /></div>
                            <div><label className="block text-sm text-gray-500 mb-1">Tagline</label><input type="text" value={settings.tagline} onChange={(e) => updateSetting('tagline', e.target.value)} className="w-full px-3 py-2 border rounded-lg" /></div>
                            <div><label className="block text-sm text-gray-500 mb-1">Support Email</label><input type="email" value={settings.supportEmail} onChange={(e) => updateSetting('supportEmail', e.target.value)} className="w-full px-3 py-2 border rounded-lg" /></div>
                            <div><label className="block text-sm text-gray-500 mb-1">Support Phone</label><input type="tel" value={settings.supportPhone} onChange={(e) => updateSetting('supportPhone', e.target.value)} className="w-full px-3 py-2 border rounded-lg" /></div>
                            <div><label className="block text-sm text-gray-500 mb-1">Currency</label><select value={settings.currency} onChange={(e) => updateSetting('currency', e.target.value)} className="w-full px-3 py-2 border rounded-lg"><option value="INR">INR (₹)</option><option value="USD">USD ($)</option></select></div>
                            <div><label className="block text-sm text-gray-500 mb-1">Timezone</label><select value={settings.timezone} onChange={(e) => updateSetting('timezone', e.target.value)} className="w-full px-3 py-2 border rounded-lg"><option value="Asia/Kolkata">Asia/Kolkata (IST)</option><option value="UTC">UTC</option></select></div>
                        </div>
                    </div>
                )}

                {/* Delivery Tab */}
                {activeTab === 'delivery' && (
                    <div className="space-y-5">
                        <h3 className="font-bold text-lg mb-4">Delivery Settings</h3>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div><label className="block text-sm text-gray-500 mb-1">Min Order Amount (₹)</label><input type="number" value={settings.minOrderAmount} onChange={(e) => updateSetting('minOrderAmount', parseInt(e.target.value))} className="w-full px-3 py-2 border rounded-lg" /></div>
                            <div><label className="block text-sm text-gray-500 mb-1">Delivery Fee (₹)</label><input type="number" value={settings.deliveryFee} onChange={(e) => updateSetting('deliveryFee', parseInt(e.target.value))} className="w-full px-3 py-2 border rounded-lg" /></div>
                            <div><label className="block text-sm text-gray-500 mb-1">Free Delivery Above (₹)</label><input type="number" value={settings.freeDeliveryThreshold} onChange={(e) => updateSetting('freeDeliveryThreshold', parseInt(e.target.value))} className="w-full px-3 py-2 border rounded-lg" /></div>
                            <div><label className="block text-sm text-gray-500 mb-1">Max Delivery Radius (km)</label><input type="number" value={settings.maxDeliveryRadius} onChange={(e) => updateSetting('maxDeliveryRadius', parseInt(e.target.value))} className="w-full px-3 py-2 border rounded-lg" /></div>
                            <div><label className="block text-sm text-gray-500 mb-1">Est. Delivery Time</label><input type="text" value={settings.estimatedDeliveryTime} onChange={(e) => updateSetting('estimatedDeliveryTime', e.target.value)} className="w-full px-3 py-2 border rounded-lg" /></div>
                            <div className="flex items-center gap-2 pt-6"><input type="checkbox" id="slots" checked={settings.enableDeliverySlots} onChange={(e) => updateSetting('enableDeliverySlots', e.target.checked)} /><label htmlFor="slots" className="text-sm">Enable Delivery Slots</label></div>
                        </div>
                    </div>
                )}

                {/* Orders Tab */}
                {activeTab === 'orders' && (
                    <div className="space-y-5">
                        <h3 className="font-bold text-lg mb-4">Order Settings</h3>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div><label className="block text-sm text-gray-500 mb-1">Order ID Prefix</label><input type="text" value={settings.orderIdPrefix} onChange={(e) => updateSetting('orderIdPrefix', e.target.value)} className="w-full px-3 py-2 border rounded-lg" /></div>
                        </div>
                        <div className="space-y-3 pt-2">
                            <label className="flex items-center gap-2"><input type="checkbox" checked={settings.enableCOD} onChange={(e) => updateSetting('enableCOD', e.target.checked)} /><span className="text-sm">Enable Cash on Delivery</span></label>
                            <label className="flex items-center gap-2"><input type="checkbox" checked={settings.enableOnlinePayment} onChange={(e) => updateSetting('enableOnlinePayment', e.target.checked)} /><span className="text-sm">Enable Online Payment</span></label>
                            <label className="flex items-center gap-2"><input type="checkbox" checked={settings.autoConfirmOrders} onChange={(e) => updateSetting('autoConfirmOrders', e.target.checked)} /><span className="text-sm">Auto-confirm Orders</span></label>
                        </div>
                    </div>
                )}

                {/* Notifications Tab */}
                {activeTab === 'notifications' && (
                    <div className="space-y-5">
                        <h3 className="font-bold text-lg mb-4">Notification Settings</h3>
                        <div className="space-y-3">
                            <label className="flex items-center gap-2"><input type="checkbox" checked={settings.enableEmailNotifications} onChange={(e) => updateSetting('enableEmailNotifications', e.target.checked)} /><span className="text-sm">📧 Email Notifications</span></label>
                            <label className="flex items-center gap-2"><input type="checkbox" checked={settings.enablePushNotifications} onChange={(e) => updateSetting('enablePushNotifications', e.target.checked)} /><span className="text-sm">🔔 Push Notifications</span></label>
                            <label className="flex items-center gap-2"><input type="checkbox" checked={settings.enableSMSNotifications} onChange={(e) => updateSetting('enableSMSNotifications', e.target.checked)} /><span className="text-sm">📱 SMS Notifications</span></label>
                        </div>
                    </div>
                )}

                {/* Maintenance Tab */}
                {activeTab === 'maintenance' && (
                    <div className="space-y-5">
                        <h3 className="font-bold text-lg mb-4">Maintenance Mode</h3>
                        <label className="flex items-center gap-2">
                            <input type="checkbox" checked={settings.maintenanceMode} onChange={(e) => updateSetting('maintenanceMode', e.target.checked)} />
                            <span className={`text-sm font-medium ${settings.maintenanceMode ? 'text-red-600' : ''}`}>
                                {settings.maintenanceMode ? '🔴 Maintenance Mode is ON' : 'Enable Maintenance Mode'}
                            </span>
                        </label>
                        {settings.maintenanceMode && (
                            <div>
                                <label className="block text-sm text-gray-500 mb-1">Maintenance Message</label>
                                <textarea value={settings.maintenanceMessage} onChange={(e) => updateSetting('maintenanceMessage', e.target.value)} className="w-full px-3 py-2 border rounded-lg" rows="3" />
                            </div>
                        )}
                    </div>
                )}
            </div>
        </div>
    );
};

export default Settings;
