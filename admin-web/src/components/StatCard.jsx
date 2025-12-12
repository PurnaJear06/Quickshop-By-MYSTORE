const StatCard = ({ title, value, icon, trend }) => {
    const isPositive = trend && trend > 0;

    return (
        <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center justify-between">
                <div>
                    <p className="text-gray-500 text-sm font-medium">{title}</p>
                    <h3 className="text-2xl font-bold mt-2">{value}</h3>
                    {trend && (
                        <p className={`text-sm mt-2 ${isPositive ? 'text-green-600' : 'text-red-600'}`}>
                            {isPositive ? '↑' : '↓'} {Math.abs(trend)}%
                        </p>
                    )}
                </div>
                <div className="text-4xl">{icon}</div>
            </div>
        </div>
    );
};

export default StatCard;
