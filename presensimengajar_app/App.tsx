import './global.css';
import { StatusBar } from 'expo-status-bar';
import { Text, View } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';

export default function App() {
  return (
    <SafeAreaProvider>
      <View className="flex-1 bg-white">
        <StatusBar style="light" backgroundColor="#1e3a8a" />
        <Text className="text-center text-lg font-semibold mt-20">
          EduPresence - Aplikasi Presensi Guru
        </Text>
      </View>
    </SafeAreaProvider>
  );
}
