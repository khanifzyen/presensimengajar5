import { View, Text } from 'react-native';

export default function JadwalScreen() {
    return (
        <View className="flex-1 bg-gray-50 justify-center items-center px-6">
            <View className="w-full max-w-sm">
                <Text className="text-2xl font-bold text-gray-800 mb-4">Jadwal Mengajar</Text>
                <View className="bg-white rounded-2xl p-6 shadow-sm">
                    <Text className="text-center text-gray-600">Belum ada jadwal untuk hari ini</Text>
                </View>
            </View>
        </View>
    );
}