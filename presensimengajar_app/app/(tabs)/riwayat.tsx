import { View, Text, ScrollView } from 'react-native';

export default function RiwayatScreen() {
    return (
        <ScrollView className="flex-1 bg-gray-50">
            <View className="px-6 py-6">
                <Text className="text-2xl font-bold text-gray-800 mb-6">Riwayat Presensi</Text>

                {/* Stats Grid */}
                <View className="flex-row space-x-4 mb-6">
                    <View className="flex-1 bg-green-50 rounded-xl p-4 items-center">
                        <Text className="text-2xl font-bold text-green-700">20</Text>
                        <Text className="text-green-600 text-sm">Hadir</Text>
                    </View>
                    <View className="flex-1 bg-yellow-50 rounded-xl p-4 items-center">
                        <Text className="text-2xl font-bold text-yellow-700">2</Text>
                        <Text className="text-yellow-600 text-sm">Telat</Text>
                    </View>
                    <View className="flex-1 bg-blue-50 rounded-xl p-4 items-center">
                        <Text className="text-2xl font-bold text-blue-700">1</Text>
                        <Text className="text-blue-600 text-sm">Izin</Text>
                    </View>
                    <View className="flex-1 bg-red-50 rounded-xl p-4 items-center">
                        <Text className="text-2xl font-bold text-red-700">0</Text>
                        <Text className="text-red-600 text-sm">Alpha</Text>
                    </View>
                </View>

                {/* History List */}
                <View className="space-y-4">
                    <View className="bg-white rounded-2xl p-4 shadow-sm flex-row justify-between items-center">
                        <View className="flex-1">
                            <Text className="text-lg font-semibold text-gray-800">10</Text>
                            <Text className="text-sm text-gray-600">SEN</Text>
                        </View>
                        <View className="flex-1">
                            <Text className="text-gray-800">07:00 - 14:00</Text>
                            <Text className="text-sm text-green-600">Hadir Tepat Waktu</Text>
                        </View>
                        <View className="w-6 h-6" />
                    </View>

                    <View className="bg-white rounded-2xl p-4 shadow-sm flex-row justify-between items-center">
                        <View className="flex-1">
                            <Text className="text-lg font-semibold text-gray-800">09</Text>
                            <Text className="text-sm text-gray-600">MIN</Text>
                        </View>
                        <View className="flex-1">
                            <Text className="text-gray-800">07:15 - 14:00</Text>
                            <Text className="text-sm text-yellow-600">Terlambat 15 menit</Text>
                        </View>
                        <View className="w-6 h-6" />
                    </View>

                    <View className="bg-white rounded-2xl p-4 shadow-sm flex-row justify-between items-center">
                        <View className="flex-1">
                            <Text className="text-lg font-semibold text-gray-800">08</Text>
                            <Text className="text-sm text-gray-600">SAB</Text>
                        </View>
                        <View className="flex-1">
                            <Text className="text-gray-800">Izin Sakit</Text>
                            <Text className="text-sm text-blue-600">Surat Dokter.pdf</Text>
                        </View>
                        <View className="w-6 h-6" />
                    </View>
                </View>
            </View>
        </ScrollView>
    );
}