export default function DashboardPreview() {
    return (
        <div className="w-full max-w-2xl">
            {/* Header Card */}
            <div className="bg-white rounded-2xl shadow-lg p-6 mb-6">
                <div className="flex items-start justify-between mb-4">
                    <div>
                        <h3 className="text-lg font-bold text-gray-900 mb-1">Application Dashboard</h3>
                        <p className="text-sm text-gray-500">Manage your operations more professionally</p>
                    </div>
                    <div className="flex gap-2">
                        <div className="w-8 h-8 bg-purple-100 rounded-lg flex items-center justify-center">
                            <span className="text-purple-600 text-xs font-bold">M</span>
                        </div>
                    </div>
                </div>

                {/* Tabs */}
                <div className="flex gap-4 border-b border-gray-200 mb-4">
                    <button className="pb-2 px-1 text-sm font-medium text-purple-600 border-b-2 border-purple-600">Overview</button>
                    <button className="pb-2 px-1 text-sm font-medium text-gray-500 hover:text-gray-700">Analytics</button>
                    <button className="pb-2 px-1 text-sm font-medium text-gray-500 hover:text-gray-700">Reports</button>
                </div>

                {/* Stats */}
                <div className="grid grid-cols-3 gap-4">
                    <div className="bg-purple-50 rounded-lg p-4">
                        <div className="text-2xl font-bold text-gray-900">2.4k</div>
                        <div className="text-xs text-gray-600">Active Users</div>
                    </div>
                    <div className="bg-yellow-50 rounded-lg p-4">
                        <div className="text-2xl font-bold text-gray-900">$12.5k</div>
                        <div className="text-xs text-gray-600">Revenue</div>
                    </div>
                    <div className="bg-blue-50 rounded-lg p-4">
                        <div className="text-2xl font-bold text-gray-900">89%</div>
                        <div className="text-xs text-gray-600">Conversion</div>
                    </div>
                </div>
            </div>

            {/* Timeline View */}
            <div className="bg-white rounded-2xl shadow-lg p-6">
                <div className="flex items-center justify-between mb-4">
                    <h4 className="font-bold text-gray-900">Marketing Timeline</h4>
                    <span className="text-sm px-3 py-1 bg-purple-100 text-purple-700 rounded-lg font-medium">Today</span>
                </div>

                <div className="space-y-3">
                    <div className="flex gap-3">
                        <div className="w-1 bg-purple-200 rounded"></div>
                        <div className="flex-1 bg-purple-50 rounded-lg p-3">
                            <div className="text-xs font-semibold text-purple-700 mb-1">Campaign Launch</div>
                            <div className="text-xs text-gray-600">Email marketing campaign started</div>
                        </div>
                    </div>
                    <div className="flex gap-3">
                        <div className="w-1 bg-yellow-200 rounded"></div>
                        <div className="flex-1 bg-yellow-50 rounded-lg p-3">
                            <div className="text-xs font-semibold text-yellow-700 mb-1">New Leads</div>
                            <div className="text-xs text-gray-600">45 new leads captured from landing page</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}