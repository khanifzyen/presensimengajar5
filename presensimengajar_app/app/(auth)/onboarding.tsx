import { useState } from 'react';
import { View, Text, TouchableOpacity, ScrollView } from 'react-native';
import { router } from 'expo-router';
import { ChevronRight, SkipForward } from 'lucide-react-native';

export default function OnboardingScreen() {
    const [currentSlide, setCurrentSlide] = useState(0);

    const slides = [
        {
            id: 1,
            title: 'Presensi Fleksibel',
            description: 'Satu aplikasi untuk presensi mengajar dan kehadiran kerja harian Anda.',
            icon: '📍'
        },
        {
            id: 2,
            title: 'Validasi Akurat',
            description: 'Check-in hanya bisa dilakukan dalam radius sekolah dengan verifikasi foto wajah.',
            icon: '📸'
        },
        {
            id: 3,
            title: 'Pantau Izin',
            description: 'Ajukan izin sakit atau cuti langsung kepada Admin dan pantau performa Anda.',
            icon: '📊'
        }
    ];

    const nextSlide = () => {
        if (currentSlide < slides.length - 1) {
            setCurrentSlide(currentSlide + 1);
        } else {
            router.replace('/login');
        }
    };

    const skipOnboarding = () => {
        router.replace('/login');
    };

    const goToSlide = (index: number) => {
        setCurrentSlide(index);
    };

    return (
        <ScrollView className="flex-1 bg-primary">
            <View className="flex-1 justify-center items-center px-6 py-12">
                {/* Skip Button */}
                <View className="absolute top-12 right-6">
                    <TouchableOpacity
                        onPress={skipOnboarding}
                        className="px-4 py-2 rounded-full bg-white/20"
                    >
                        <Text className="text-white text-sm">Lewati</Text>
                    </TouchableOpacity>
                </View>

                {/* Content */}
                <View className="w-full max-w-sm">
                    {/* Icon */}
                    <View className="items-center mb-8">
                        <Text className="text-6xl mb-4">{slides[currentSlide].icon}</Text>
                    </View>

                    {/* Title and Description */}
                    <View className="mb-12">
                        <Text className="text-white text-3xl font-bold text-center mb-4">
                            {slides[currentSlide].title}
                        </Text>
                        <Text className="text-white/80 text-center text-base leading-relaxed">
                            {slides[currentSlide].description}
                        </Text>
                    </View>

                    {/* Dots Indicator */}
                    <View className="flex-row justify-center mb-8 space-x-2">
                        {slides.map((_, index) => (
                            <View
                                key={index}
                                className={`h-2 w-2 rounded-full ${index === currentSlide ? 'bg-white' : 'bg-white/30'
                                    }`}
                            />
                        ))}
                    </View>

                    {/* Next Button */}
                    <TouchableOpacity
                        onPress={nextSlide}
                        className="flex-row items-center justify-center bg-white rounded-full px-6 py-4"
                    >
                        <Text className="text-primary font-semibold text-base mr-2">
                            {currentSlide === slides.length - 1 ? 'Mulai' : 'Lanjut'}
                        </Text>
                        <ChevronRight size={20} color="#1e3a8a" />
                    </TouchableOpacity>
                </View>
            </View>
        </ScrollView>
    );
}