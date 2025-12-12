import { Link, useLocation } from 'react-router-dom';

const Sidebar = () => {
    const location = useLocation();

    const menuItems = [
        { name: 'Dashboard', path: '/', icon: '📊' },
        { name: 'Products', path: '/products', icon: '📦' },
        { name: 'Dark Stores', path: '/stores', icon: '🏪' },
        { name: 'Orders', path: '/orders', icon: '📝' },
        { name: 'Banners', path: '/banners', icon: '🖼️' },
        { name: 'Categories', path: '/categories', icon: '🏷️' },
        { name: 'Analytics', path: '/analytics', icon: '📈' },
        { name: 'Settings', path: '/settings', icon: '⚙️' },
    ];

    return (
        <div className="h-screen w-64 bg-sidebar text-white fixed left-0 top-0 flex flex-col">
            {/* Logo */}
            <div className="p-6 border-b border-sidebar-light">
                <h1 className="text-2xl font-bold text-primary">QuickShop</h1>
                <p className="text-sm text-gray-400 mt-1">Admin Dashboard</p>
            </div>

            {/* Menu Items */}
            <nav className="flex-1 p-4 space-y-2">
                {menuItems.map((item) => {
                    const isActive = location.pathname === item.path;
                    return (
                        <Link
                            key={item.path}
                            to={item.path}
                            className={`flex items-center px-4 py-3 rounded-lg transition-colors ${isActive
                                    ? 'bg-primary text-white'
                                    : 'text-gray-300 hover:bg-sidebar-light'
                                }`}
                        >
                            <span className="text-xl mr-3">{item.icon}</span>
                            <span className="font-medium">{item.name}</span>
                        </Link>
                    );
                })}
            </nav>

            {/* User Info */}
            <div className="p-4 border-t border-sidebar-light">
                <div className="flex items-center">
                    <div className="w-10 h-10 rounded-full bg-primary flex items-center justify-center">
                        <span className="text-white font-bold">P</span>
                    </div>
                    <div className="ml-3">
                        <p className="font-medium">Purna</p>
                        <p className="text-sm text-gray-400">Admin</p>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Sidebar;
