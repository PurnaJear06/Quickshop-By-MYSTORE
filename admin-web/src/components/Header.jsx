const Header = () => {
    return (
        <header className="h-16 bg-white border-b border-gray-200 fixed top-0 right-0 left-64 z-10">
            <div className="h-full px-6 flex items-center justify-between">
                {/* Search Bar */}
                <div className="flex-1 max-w-2xl">
                    <input
                        type="text"
                        placeholder="Search..."
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                    />
                </div>

                {/* Right Section */}
                <div className="flex items-center space-x-4 ml-6">
                    {/* Notifications */}
                    <button className="relative p-2 text-gray-600 hover:text-primary">
                        <span className="text-2xl">🔔</span>
                        <span className="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full"></span>
                    </button>

                    {/* Profile */}
                    <div className="flex items-center">
                        <div className="w-8 h-8 rounded-full bg-primary flex items-center justify-center">
                            <span className="text-white font-bold text-sm">P</span>
                        </div>
                    </div>
                </div>
            </div>
        </header>
    );
};

export default Header;
