import { useState } from 'react';
import { View, Text, TouchableOpacity, ScrollView } from 'react-native';
import { FileText, Plus } from 'lucide-react-native';

export default function IzinScreen() {
    const [activeTab, setActiveTab] = useState('form');

    return (
        <ScrollView className="flex-1 bg-gray-50">
            <View className="px-6 py-6">
                <Text className="text-2xl font-bold text-gray-800 mb-6">Izin & Cuti</Text>

                {/* Tab Switcher */}
                <View className="flex-row bg-white rounded-lg p-1 mb-6">
                    <TouchableOpacity
                        onPress={() => setActiveTab('form')}
                        className={`flex-1 py-3 items-center ${activeTab === 'form' ? 'bg-primary' : ''
                            }`}
                    >
                        <Text className={`font-medium ${activeTab === 'form' ? 'text-white' : 'text-gray-600'
                            }`}>Buat Pengajuan</Text>
                    </TouchableOpacity>
                    <TouchableOpacity
                        onPress={() => setActiveTab('history')}
                        className={`flex-1 py-3 items-center ${activeTab === 'history' ? 'bg-primary' : ''
                            }`}
                    >
                        <Text className={`font-medium ${activeTab === 'history' ? 'text-white' : 'text-gray-600'
                            }`}>Riwayat</Text>
                    </TouchableOpacity>
                </View>

                {/* Form Tab */}
                {activeTab === 'form' && (
                    <View className="space-y-4">
                        {/* Jenis Izin */}
                        <View>
                            <Text className="text-gray-700 font-medium mb-2">Jenis Izin</Text>
                            <View className="bg-white rounded-lg border border-gray-200 px-4 py-3">
                                <Text className="text-gray-500">Pilih Kategori</Text>
                            </View>
                        </View>

                        {/* Date Range */}
                        <View className="flex-row space-x-4">
                            <View className="flex-1">
                                <Text className="text-gray-700 font-medium mb-2">Mulai Tanggal</Text>
                                <View className="bg-white rounded-lg border border-gray-200 px-4 py-3">
                                    <Text className="text-gray-500">Pilih tanggal</Text>
                                </View>
                            </View>
                            <View className="flex-1">
                                <Text className="text-gray-700 font-medium mb-2">Sampai Tanggal</Text>
                                <View className="bg-white rounded-lg border border-gray-200 px-4 py-3">
                                    <Text className="text-gray-500">Pilih tanggal</Text>
                                </View>
                            </View>
                        </View>

                        {/* Alasan */}
                        <View>
                            <Text className="text-gray-700 font-medium mb-2">Keterangan / Alasan</Text>
                            <View className="bg-white rounded-lg border border-gray-200 px-4 py-3">
                                <Text className="text-gray-500" numberOfLines={4}>Tulis alasan lengkap...</Text>
                            </View>
                        </View>

                        {/* Lampiran */}
                        <View>
                            <Text className="text-gray-700 font-medium mb-2">Lampiran (Surat Dokter/Dokumen)</Text>
                            <TouchableOpacity className="bg-white rounded-lg border-2 border-dashed border-gray-300 px-4 py-8 items-center">
                                <Plus size={24} color="#9ca3af" />
                                <Text className="text-gray-600 ml-2">Ketuk untuk upload file (JPG/PDF)</Text>
                            </TouchableOpacity>
                        </View>

                        {/* Submit Button */}
                        <TouchableOpacity className="bg-primary rounded-lg py-4 items-center">
                            <Text className="text-white font-semibold text-lg">AJUKAN SEKARANG</Text>
                        </TouchableOpacity>
                    </View>
                )}

                {/* History Tab */}
                {activeTab === 'history' && (
                    <View className="space-y-4">
                        {/* Pending Request */}
                        <View className="bg-white rounded-2xl p-6 shadow-sm">
                            <View className="flex-row justify-between items-start mb-4">
                                <View>
                                    <Text className="text-lg font-semibold text-gray-800">Cuti Pribadi</Text>
                                    <Text className="text-sm text-gray-600">12 Des - 13 Des 2025</Text>
                                </View>
                                <View className="bg-yellow-100 px-3 py-1 rounded-full">
                                    <Text className="text-yellow-700 text-xs font-medium">Menunggu</Text>
                                </View>
                            </View>
                            <Text className="text-gray-700 mb-2">Acara keluarga di luar kota</Text>
                        </View>

                        {/* Approved Request */}
                        <View className="bg-white rounded-2xl p-6 shadow-sm">
                            <View className="flex-row justify-between items-start mb-4">
                                <View>
                                    <Text className="text-lg font-semibold text-gray-800">Sakit</Text>
                                    <Text className="text-sm text-gray-600">01 Nov 2025</Text>
                                </View>
                                <View className="bg-green-100 px-3 py-1 rounded-full">
                                    <Text className="text-green-700 text-xs font-medium">Disetujui</Text>
                                </View>
                            </View>
                            <Text className="text-gray-700 mb-2">Demam tinggi, surat dokter terlampir</Text>
                        </View>

                        {/* Rejected Request */}
                        <View className="bg-white rounded-2xl p-6 shadow-sm">
                            <View className="flex-row justify-between items-start mb-4">
                                <View>
                                    <Text className="text-lg font-semibold text-gray-800">Cuti Pribadi</Text>
                                    <Text className="text-sm text-gray-600">10 Okt - 11 Okt 2025</Text>
                                </View>
                                <View className="bg-red-100 px-3 py-1 rounded-full">
                                    <Text className="text-red-700 text-xs font-medium">Ditolak</Text>
                                </View>
                            </View>
                            <Text className="text-gray-700 mb-2">Jadwal mengajar padat, mohon dijadwalkan ulang</Text>
                        </View>
                    </View>
                )}
            </View>
        </ScrollView>
    );
}