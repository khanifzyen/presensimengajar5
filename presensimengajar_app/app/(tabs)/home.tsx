import { View, Text, TouchableOpacity } from 'react-native';
import { Bell } from 'lucide-react-native';

export default function HomeScreen() {
    return (
        <View className="flex-1 bg-gray-50">
            {/* Header */}
            <View className="bg-primary px-6 pt-12 pb-6">
                <View className="flex-row justify-between items-start">
                    <View>
                        <Text className="text-white/80 text-sm">Halo, Selamat Pagi</Text>
                        <Text className="text-white text-xl font-semibold">Siti Nurhaliza, S.Pd</Text>
                    </View>
                    <TouchableOpacity className="relative">
                        <Bell size={24} color="#ffffff" />
                        <View className="absolute -top-1 -right-1 w-2 h-2 bg-red-500 rounded-full" />
                    </TouchableOpacity>
                </View>
            </View>

            {/* Content */}
            <View className="flex-1 px-6 py-6">
                {/* Time Card */}
                <View className="bg-white rounded-2xl p-6 mb-6 shadow-sm">
                    <Text className="text-3xl font-bold text-center text-primary">07:15:30</Text>
                    <Text className="text-center text-gray-600 mb-4">Senin, 10 Desember 2025</Text>
                    <View className="h-px bg-gray-200 mb-4" />
                    <View className="flex-row justify-between">
                        <View className="items-center">
                            <Text className="text-gray-600 text-sm">Jam Ajar</Text>
                            <Text className="font-semibold text-primary">05:30</Text>
                        </View>
                        <View className="items-center">
                            <Text className="text-gray-600 text-sm">Status</Text>
                            <Text className="font-semibold text-green-600">Tepat Waktu</Text>
                        </View>
                    </View>
                </View>

                {/* Current Class Status */}
                <View className="mb-6">
                    <Text className="text-lg font-semibold mb-4 text-gray-800">Kelas Saat Ini</Text>
                    <View className="bg-white rounded-2xl p-6 shadow-sm">
                        <View className="mb-4">
                            <Text className="text-lg font-semibold text-primary">Matematika Wajib</Text>
                            <Text className="text-gray-600">Kelas XII IPA 1 • 07:00 - 08:30</Text>
                        </View>
                        <TouchableOpacity className="bg-red-500 rounded-lg py-3 items-center">
                            <Text className="text-white font-semibold">CHECK-OUT KELAS</Text>
                        </TouchableOpacity>
                        <Text className="text-center text-gray-500 text-sm mt-2">Sedang berlangsung...</Text>
                    </View>
                </View>

                {/* Today's Schedule */}
                <View className="mb-6">
                    <Text className="text-lg font-semibold mb-4 text-gray-800">Jadwal Hari Ini</Text>
                    <View className="bg-white rounded-2xl p-4 shadow-sm space-y-3">
                        <View className="flex-row justify-between items-center py-3 border-b border-gray-100">
                            <View className="flex-1">
                                <Text className="font-medium text-gray-800">07:00 - 08:30</Text>
                                <Text className="text-sm text-gray-600">Matematika • XII IPA 1</Text>
                            </View>
                            <View className="bg-green-100 px-3 py-1 rounded-full">
                                <Text className="text-green-700 text-xs font-medium">Selesai</Text>
                            </View>
                        </View>
                        <View className="flex-row justify-between items-center py-3 border-b border-gray-100">
                            <View className="flex-1">
                                <Text className="font-medium text-gray-800">09:00 - 10:30</Text>
                                <Text className="text-sm text-gray-600">Matematika • XII IPA 2</Text>
                            </View>
                            <View className="bg-blue-100 px-3 py-1 rounded-full">
                                <Text className="text-blue-700 text-xs font-medium">Akan Datang</Text>
                            </View>
                        </View>
                        <View className="flex-row justify-between items-center py-3">
                            <View className="flex-1">
                                <Text className="font-medium text-gray-800">11:00 - 12:30</Text>
                                <Text className="text-sm text-gray-600">Matematika • X IPA 3</Text>
                            </View>
                            <View className="bg-gray-100 px-3 py-1 rounded-full">
                                <Text className="text-gray-700 text-xs font-medium">Terjadwal</Text>
                            </View>
                        </View>
                    </View>
                </View>

                {/* Quick Stats */}
                <View>
                    <Text className="text-lg font-semibold mb-4 text-gray-800">Statistik Minggu Ini</Text>
                    <View className="flex-row space-x-4">
                        <View className="flex-1 bg-green-50 rounded-xl p-4 items-center">
                            <Text className="text-2xl font-bold text-green-700">12</Text>
                            <Text className="text-green-600 text-sm">Kelas Diampu</Text>
                        </View>
                        <View className="flex-1 bg-yellow-50 rounded-xl p-4 items-center">
                            <Text className="text-2xl font-bold text-yellow-700">2</Text>
                            <Text className="text-yellow-600 text-sm">Terlambat</Text>
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
                </View>
            </View>
        </View>
    );
}