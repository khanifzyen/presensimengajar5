import { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, Alert } from 'react-native';
import { router } from 'expo-router';
import { Eye, EyeOff, User, Lock } from 'lucide-react-native';

export default function LoginScreen() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [showPassword, setShowPassword] = useState(false);
    const [isLoading, setIsLoading] = useState(false);

    const handleLogin = async () => {
        if (!email || !password) {
            Alert.alert('Error', 'Silakan isi email dan password');
            return;
        }

        setIsLoading(true);

        try {
            // TODO: Implement PocketBase authentication
            // For now, simulate login
            setTimeout(() => {
                setIsLoading(false);
                // Navigate to tabs (main app)
                router.replace('/(tabs)');
            }, 1500);
        } catch (error) {
            setIsLoading(false);
            Alert.alert('Error', 'Login gagal. Silakan coba lagi.');
        }
    };

    return (
        <View className="flex-1 bg-primary justify-center px-6">
            <View className="w-full max-w-sm">
                {/* Logo and Title */}
                <View className="items-center mb-8">
                    <View className="w-20 h-20 bg-white rounded-2xl justify-center items-center mb-4">
                        <Text className="text-primary text-2xl font-bold">EP</Text>
                    </View>
                    <Text className="text-white text-2xl font-semibold mb-2">Selamat Datang</Text>
                    <Text className="text-white/80 text-sm">Silakan masuk dengan akun guru Anda</Text>
                </View>

                {/* Login Form */}
                <View className="space-y-4">
                    {/* Email Input */}
                    <View className="relative">
                        <User size={20} color="#9ca3af" className="absolute left-4 top-4 z-10" />
                        <TextInput
                            className="flex-1 bg-white/10 border border-white/20 rounded-lg px-12 py-4 pl-12 text-white placeholder:text-white/50"
                            placeholder="NIP atau Email"
                            placeholderTextColor="#9ca3af"
                            value={email}
                            onChangeText={setEmail}
                            keyboardType="email-address"
                            autoCapitalize="none"
                            autoCorrect={false}
                        />
                    </View>

                    {/* Password Input */}
                    <View className="relative">
                        <Lock size={20} color="#9ca3af" className="absolute left-4 top-4 z-10" />
                        <TextInput
                            className="flex-1 bg-white/10 border border-white/20 rounded-lg px-12 py-4 pl-12 pr-12 text-white placeholder:text-white/50"
                            placeholder="Kata Sandi"
                            placeholderTextColor="#9ca3af"
                            value={password}
                            onChangeText={setPassword}
                            secureTextEntry={!showPassword}
                        />
                        <TouchableOpacity
                            className="absolute right-4 top-4 z-10"
                            onPress={() => setShowPassword(!showPassword)}
                        >
                            {showPassword ? (
                                <EyeOff size={20} color="#9ca3af" />
                            ) : (
                                <Eye size={20} color="#9ca3af" />
                            )}
                        </TouchableOpacity>
                    </View>

                    {/* Forgot Password */}
                    <View className="items-end">
                        <TouchableOpacity>
                            <Text className="text-white/80 text-sm">Lupa Kata Sandi?</Text>
                        </TouchableOpacity>
                    </View>

                    {/* Login Button */}
                    <TouchableOpacity
                        onPress={handleLogin}
                        disabled={isLoading}
                        className={`bg-white rounded-lg py-4 items-center ${isLoading ? 'opacity-70' : ''
                            }`}
                    >
                        {isLoading ? (
                            <Text className="text-primary font-semibold">Memuat...</Text>
                        ) : (
                            <Text className="text-primary font-semibold">MASUK</Text>
                        )}
                    </TouchableOpacity>
                </View>

                {/* Footer */}
                <View className="items-center mt-8">
                    <Text className="text-white/60 text-xs">v1.0.0 © EduPresence</Text>
                </View>
            </View>
        </View>
    );
}