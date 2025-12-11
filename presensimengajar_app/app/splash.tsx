import { useEffect } from 'react';
import { View, Text } from 'react-native';
import { router } from 'expo-router';
import { StyleSheet } from 'react-native';

export default function SplashScreen() {
    useEffect(() => {
        // Auto-navigate to onboarding after 2 seconds
        const timer = setTimeout(() => {
            router.replace('/onboarding');
        }, 2000);

        return () => clearTimeout(timer);
    }, []);

    return (
        <View className="flex-1 bg-primary justify-center items-center">
            <View className="items-center">
                <View className="w-24 h-24 bg-white rounded-2xl justify-center items-center mb-8">
                    <Text className="text-primary text-4xl font-bold">EP</Text>
                </View>
                <Text className="text-white text-2xl font-semibold mb-2">EduPresence</Text>
                <Text className="text-white/80 text-sm">Aplikasi Presensi Guru</Text>
                <View className="mt-8">
                    <View className="w-8 h-8 border-2 border-white/30 rounded-full border-t-transparent animate-spin" />
                </View>
            </View>
        </View>
    );
}

const styles = StyleSheet.create({
    spinner: {
        borderTopColor: 'transparent',
        borderRightColor: 'rgba(255, 255, 255, 0.3)',
        borderBottomColor: 'rgba(255, 255, 255, 0.3)',
        borderLeftColor: 'rgba(255, 255, 255, 0.3)',
    },
});