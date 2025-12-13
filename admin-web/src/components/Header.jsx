import { useLocation } from 'react-router-dom';

const Header = () => {
    const location = useLocation();

    // Get page title based on current route
    const getPageTitle = () => {
        const titles = {
            '/': 'Welcome back, Purna',
            '/products': 'Products',
            '/stores': 'Dark Stores',
            '/orders': 'Orders',
            '/banners': 'Banners',
            '/categories': 'Categories',
            '/analytics': 'Analytics',
            '/settings': 'Settings',
        };
        return titles[location.pathname] || 'Dashboard';
    };

    return (
        <header
            className="h-16 bg-white border-b border-slate-200 fixed top-0 z-40 flex items-center justify-between px-8"
            style={{ left: '240px', right: '0' }}
        >
            {/* Page Title */}
            <h1 className="text-xl font-semibold text-slate-800">
                {getPageTitle()}
            </h1>

            {/* Right Section */}
            <div className="flex items-center gap-4">
                {/* Notification Bell */}
                <button className="relative p-2 text-slate-500 hover:text-slate-700 transition-colors">
                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                    </svg>
                    <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-red-500 rounded-full"></span>
                </button>

                {/* Profile */}
                <div className="relative">
                    <div className="w-9 h-9 rounded-full bg-slate-200 flex items-center justify-center">
                        <svg className="w-5 h-5 text-slate-500" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z" />
                        </svg>
                    </div>
                    <span className="absolute bottom-0 right-0 w-3 h-3 bg-emerald-500 rounded-full border-2 border-white"></span>
                </div>
            </div>
        </header>
    );
};

export default Header;
