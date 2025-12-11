import { View, Text, TouchableOpacity, ScrollView } from 'react-native';
import { User, Edit, Lock, HelpCircle, Info, LogOut, ChevronRight } from 'lucide-react-native';

export default function ProfilScreen() {
    return (
        <ScrollView className="flex-1 bg-gray-50">
            <View className="px-6 py-6">
                {/* Profile Header */}
                <View className="items-center mb-8">
                    <View className="w-24 h-24 bg-white rounded-full justify-center items-center mb-4">
                        <Text className="text-primary text-3xl font-bold">BS</Text>
                    </View>
                    <Text className="text-xl font-semibold text-gray-800">Budi Santoso, S.Pd</Text>
                    <Text className="text-gray-600">NIP. 19850101 201001 1 001</Text>
                    <View className="bg-blue-100 px-3 py-1 rounded-full mt-2">
                        <Text className="text-blue-700 text-xs font-medium">Guru Pengajar</Text>
                    </View>
                </View>

                {/* Menu List */}
                <View className="space-y-4">
                    <TouchableOpacity className="bg-white rounded-2xl p-4 shadow-sm flex-row justify-between items-center">
                        <View className="flex-row items-center">
                            <View className="w-10 h-10 bg-primary rounded-lg justify-center items-center mr-3">
                                <Edit size={20} color="white" />
                            </View>
                            <Text className="text-gray-800 font-medium">Edit Profil</Text>
                        </View>
                        <ChevronRight size={20} color="#9ca3af" />
                    </TouchableOpacity>

                    <TouchableOpacity className="bg-white rounded-2xl p-4 shadow-sm flex-row justify-between items-center">
                        <View className="flex-row items-center">
                            <View className="w-10 h-10 bg-primary rounded-lg justify-center items-center mr-3">
                                <Lock size={20} color="white" />
                            </View>
                            <Text className="text-gray-800 font-medium">Ubah Kata Sandi</Text>
                        </View>
                        <ChevronRight size={20} color="#9ca3af" />
                    </TouchableOpacity>

                    <TouchableOpacity className="bg-white rounded-2xl p-4 shadow-sm flex-row justify-between items-center">
                        <View className="flex-row items-center">
                            <View className="w-10 h-10 bg-primary rounded-lg justify-center items-center mr-3">
                                <HelpCircle size={20} color="white" />
                            </View>
                            <Text className="text-gray-800 font-medium">Bantuan</Text>
                        </View>
                        <ChevronRight size={20} color="#9ca3af" />
                    </TouchableOpacity>

                    <TouchableOpacity className="bg-white rounded-2xl p-4 shadow-sm flex-row justify-between items-center">
                        <View className="flex-row items-center">
                            <View className="w-10 h-10 bg-primary rounded-lg justify-center items-center mr-3">
                                <Info size={20} color="white" />
                            </View>
                            <Text className="text-gray-800 font-medium">Tentang Aplikasi</Text>
                        </View>
                        <ChevronRight size={20} color="#9ca3af" />
                    </TouchableOpacity>
                </View>

                {/* Logout Button */}
                <View className="mt-8">
                    <TouchableOpacity className="bg-red-500 rounded-lg py-4 items-center">
                        <LogOut size={20} color="white" />
                        <Text className="text-white font-semibold ml-2">Keluar</Text>
                    </TouchableOpacity>
                </View>

                {/* Footer */}
                <View className="items-center mt-8">
                    <Text className="text-gray-500 text-xs">EduPresence v1.0.0</Text>
                </View>
            </View>
        </ScrollView>
    );
}