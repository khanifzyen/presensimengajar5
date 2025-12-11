import { useState } from 'react';
import { View, Text, TouchableOpacity, Image } from 'react-native';
import { router } from 'expo-router';
import { Camera, MapPin, CheckCircle } from 'lucide-react-native';

export default function PresensiScreen() {
    const [locationStatus, setLocationStatus] = useState('loading');
    const [canCheckIn, setCanCheckIn] = useState(false);

    return (
        <View className="flex-1 bg-gray-50">
            {/* Header */}
            <View className="bg-primary px-6 pt-12 pb-6">
                <View className="flex-row items-center justify-between">
                    <TouchableOpacity onPress={() => router.back()} className="p-2">
                        <Text className="text-white text-lg">←</Text>
                    </TouchableOpacity>
                    <Text className="text-white text-xl font-semibold">Konfirmasi Presensi</Text>
                    <View style={{ width: 24 }} />
                </View>
            </View>

            {/* Map */}
            <View className="relative h-64 bg-gray-200">
                <Image
                    source={{ uri: 'https://placehold.co/400x300/e0e7ff/1e3a8a?text=Peta+Lokasi' }}
                    className="w-full h-full"
                    resizeMode="cover"
                />
                <View className="absolute inset-0 flex items-center justify-center">
                    <View className="w-32 h-32 bg-white/90 rounded-full border-4 border-white flex items-center justify-center">
                        <MapPin size={24} color="#1e3a8a" />
                    </View>
                </View>
            </View>

            {/* Location Status */}
            <View className="px-6 py-4">
                <View className="bg-white rounded-2xl p-6 shadow-sm flex-row items-center">
                    <View className={`w-12 h-12 rounded-full mr-4 flex items-center justify-center ${locationStatus === 'success' ? 'bg-green-500' :
                            locationStatus === 'loading' ? 'bg-yellow-500' : 'bg-red-500'
                        }`}>
                        {locationStatus === 'loading' ? (
                            <Text className="text-white">...</Text>
                        ) : locationStatus === 'success' ? (
                            <CheckCircle size={24} color="white" />
                        ) : (
                            <Text className="text-white">✕</Text>
                        )}
                    </View>
                    <View className="flex-1">
                        <Text className="text-lg font-semibold text-gray-800">
                            {locationStatus === 'loading' ? 'Mencari Lokasi...' :
                                locationStatus === 'success' ? 'Lokasi Valid' : 'Lokasi Tidak Valid'}
                        </Text>
                        <Text className="text-sm text-gray-600 mt-1">
                            {locationStatus === 'success' ? 'Anda berada dalam radius sekolah' :
                                locationStatus === 'loading' ? 'Sedang memindai GPS...' : 'Anda di luar radius sekolah'}
                        </Text>
                    </View>
                </View>
            </View>

            {/* Camera */}
            <View className="px-6 py-4">
                <View className="bg-white rounded-2xl p-6 shadow-sm">
                    <Text className="text-center text-gray-800 mb-4">Wajah harus terlihat jelas</Text>
                    <View className="w-48 h-48 bg-gray-200 rounded-2xl mx-auto flex items-center justify-center mb-4">
                        <Camera size={32} color="#9ca3af" />
                    </View>
                </View>
            </View>

            {/* Submit Button */}
            <View className="px-6 py-4">
                <TouchableOpacity
                    onPress={() => {
                        // TODO: Implement attendance submission
                        console.log('Submit attendance');
                    }}
                    disabled={!canCheckIn}
                    className={`bg-primary rounded-lg py-4 items-center ${canCheckIn ? '' : 'opacity-50'
                        }`}
                >
                    <Text className="text-white font-semibold text-lg">KIRIM PRESENSI</Text>
                </TouchableOpacity>
            </View>
        </View>
    );
}