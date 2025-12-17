import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../blocs/attendance/attendance_bloc.dart';
import '../../blocs/attendance/attendance_event.dart';
import '../../blocs/attendance/attendance_state.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_state.dart';
import '../../../data/models/schedule_model.dart';
import '../../../data/models/attendance_model.dart';

class TeachingPage extends StatefulWidget {
  final ScheduleModel schedule;

  const TeachingPage({super.key, required this.schedule});

  @override
  State<TeachingPage> createState() => _TeachingPageState();
}

class _TeachingPageState extends State<TeachingPage> {
  // Map & Location
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  bool _isLoadingLocation = true;
  String _locationStatus = 'Mencari lokasi...';

  // Camera
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          _locationStatus = 'Layanan lokasi tidak aktif';
          _isLoadingLocation = false;
        });
        _showErrorDialog('Layanan lokasi tidak aktif. Mohon aktifkan GPS.');
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _locationStatus = 'Izin lokasi ditolak';
            _isLoadingLocation = false;
          });
          _showErrorDialog('Izin lokasi ditolak.');
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _locationStatus = 'Izin lokasi ditolak permanen';
          _isLoadingLocation = false;
        });
        _showErrorDialog(
          'Izin lokasi ditolak permanen. Mohon ubah di pengaturan.',
        );
      }
      return;
    }

    // Get position
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
          _locationStatus = 'Lokasi ditemukan';

          // Update Map
          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId('currentLocation'),
              position: LatLng(position.latitude, position.longitude),
              infoWindow: const InfoWindow(title: 'Lokasi Anda'),
            ),
          );
        });

        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationStatus = 'Gagal mendapatkan lokasi: $e';
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? xFile = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );

      if (xFile != null) {
        setState(() {
          _imageFile = File(xFile.path);
        });
      }
    } catch (e) {
      _showErrorDialog('Gagal membuka kamera: $e');
    }
  }

  void _onSubmit(bool isCheckIn, String? attendanceId) {
    if (_currentPosition == null) {
      _showErrorDialog('Lokasi belum ditemukan. Mohon tunggu...');
      return;
    }

    if (isCheckIn) {
      if (_imageFile == null) {
        _showErrorDialog('Harap ambil foto selfie terlebih dahulu.');
        return;
      }

      final userState = context.read<UserBloc>().state;
      if (userState is UserLoaded) {
        context.read<AttendanceBloc>().add(
          AttendanceCheckIn(
            teacherId: userState.teacher.id,
            scheduleId: widget.schedule.id,
            lat: _currentPosition!.latitude,
            lng: _currentPosition!.longitude,
            file: _imageFile!,
          ),
        );
      }
    } else {
      // Check Out
      if (attendanceId == null) return;

      context.read<AttendanceBloc>().add(
        AttendanceCheckOut(
          attendanceId: attendanceId,
          lat: _currentPosition!.latitude,
          lng: _currentPosition!.longitude,
        ),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.attendance.checkOut == null
                    ? 'Check-In Berhasil!'
                    : 'Check-Out Berhasil!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          if (state.attendance.checkOut != null) {
            Navigator.pop(context); // Close page on checkout success
          }
        } else if (state is AttendanceError) {
          _showErrorDialog(state.message);
        }
      },
      child: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          AttendanceModel? attendance;
          bool isCheckedIn = false;

          // Check if we have map data for this schedule
          if (state is AttendanceScheduleMapLoaded) {
            attendance = state.attendanceMap[widget.schedule.id];
            if (attendance?.checkIn != null && attendance?.checkOut == null) {
              isCheckedIn = true;
            }
          } else if (state is AttendanceSuccess) {
            // Optimistic update logic if needed, but repo should handle reload
            if (state.attendance.scheduleId == widget.schedule.id) {
              attendance = state.attendance;
              isCheckedIn = attendance.checkOut == null;
            }
          }

          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              title: const Text('Konfirmasi Presensi'),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Map Section
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(
                              -6.5976236,
                              110.6698662,
                            ), // Default Jepara
                            zoom: 14,
                          ),
                          markers: _markers,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          onMapCreated: (controller) =>
                              _mapController = controller,
                        ),
                        if (_isLoadingLocation)
                          Container(
                            color: Colors.black.withValues(alpha: 0.3),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Status Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Icon(
                          _isLoadingLocation
                              ? Icons.location_searching
                              : Icons.location_on,
                          color: _isLoadingLocation
                              ? Colors.grey
                              : Colors.green,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isLoadingLocation
                                    ? 'Mencari Lokasi...'
                                    : 'Lokasi Terkunci',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _locationStatus,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Camera Section (Only for Check-In)
                  if (!isCheckedIn) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: _imageFile == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.camera_alt,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Ketuk untuk ambil foto wajah',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    _imageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    // Already Checked In Info
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Status: MENGAJAR',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                if (attendance?.checkIn != null)
                                  Text(
                                    'Masuk: ${DateFormat('HH:mm').format(DateTime.parse(attendance!.checkIn!))}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Action Button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          (state is AttendanceLoading || _isLoadingLocation)
                          ? null
                          : () => _onSubmit(!isCheckedIn, attendance?.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCheckedIn
                            ? Colors.red
                            : Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state is AttendanceLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isCheckedIn
                                  ? 'CHECK-OUT KELAS'
                                  : 'KIRIM PRESENSI',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
