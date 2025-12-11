import { Tabs } from 'expo-router';
import { Home, Calendar, Camera, FileText, User } from 'lucide-react-native';

export default function TabLayout() {
    return (
        <Tabs
            screenOptions={{
                tabBarActiveTintColor: '#1e3a8a',
                tabBarInactiveTintColor: '#9ca3af',
                tabBarStyle: {
                    backgroundColor: '#ffffff',
                    borderTopWidth: 1,
                    borderTopColor: '#e5e7eb',
                },
                headerShown: false,
            }}
        >
            <Tabs.Screen
                name="home"
                options={{
                    title: 'Home',
                    tabBarIcon: ({ color, size }: { color: string; size: number }) => (
                        <Home size={size} color={color} />
                    ),
                }}
            />
            <Tabs.Screen
                name="jadwal"
                options={{
                    title: 'Jadwal',
                    tabBarIcon: ({ color, size }: { color: string; size: number }) => (
                        <Calendar size={size} color={color} />
                    ),
                }}
            />
            <Tabs.Screen
                name="riwayat"
                options={{
                    title: 'Riwayat',
                    tabBarIcon: ({ color, size }: { color: string; size: number }) => (
                        <Calendar size={size} color={color} />
                    ),
                }}
            />
            <Tabs.Screen
                name="presensi"
                options={{
                    title: 'Presensi',
                    tabBarIcon: ({ color, size }: { color: string; size: number }) => (
                        <Camera size={size} color={color} />
                    ),
                }}
            />
            <Tabs.Screen
                name="izin"
                options={{
                    title: 'Izin',
                    tabBarIcon: ({ color, size }: { color: string; size: number }) => (
                        <FileText size={size} color={color} />
                    ),
                }}
            />
            <Tabs.Screen
                name="profil"
                options={{
                    title: 'Profil',
                    tabBarIcon: ({ color, size }: { color: string; size: number }) => (
                        <User size={size} color={color} />
                    ),
                }}
            />
        </Tabs>
    );
}