const StatCard = ({ title, value, icon, isRevenue = false, trend }) => {
    return (
        <div className="bg-white rounded-xl p-6 shadow-sm">
            <div className="flex items-center justify-between">
                <div>
                    {/* Value - Green for revenue */}
                    <div className="flex items-center gap-2">
                        <span className={`text-2xl font-bold ${isRevenue ? 'text-emerald-600' : 'text-slate-900'}`}>
                            {value}
                        </span>
                        {trend && (
                            <span className="text-emerald-500 text-sm">↗₹</span>
                        )}
                    </div>
                    {/* Label */}
                    <p className="text-slate-500 text-sm mt-1">{title}</p>
                </div>

                {/* Simple icon - matching prototype */}
                <div className="text-slate-400">
                    {icon}
                </div>
            </div>
        </div>
    );
};

export default StatCard;
