import Header from '../components/Header';
import Sidebar from '../components/Sidebar';

const MainLayout = ({ children }) => {
    return (
        <div className="min-h-screen bg-slate-100">
            <Sidebar />
            <Header />
            <main
                className="min-h-screen"
                style={{ marginLeft: '240px', paddingTop: '64px' }}
            >
                <div className="p-6">
                    {children}
                </div>
            </main>
        </div>
    );
};

export default MainLayout;
