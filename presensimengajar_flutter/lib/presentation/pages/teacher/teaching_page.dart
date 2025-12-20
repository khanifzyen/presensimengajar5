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
  final AttendanceModel? attendance;

  const TeachingPage({super.key, required this.schedule, this.attendance});

  @override
  State<TeachingPage> createState() => _TeachingPageState();
}

class _TeachingPageState extends State<TeachingPage> {
  // Map & Location
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {}; // Added Circles
  bool _isLoadingLocation = true;
  String _locationStatus = 'Mencari lokasi...';

  // Geofencing Settings
  double? _officeLat;
  double? _officeLng;
  double? _maxRadius; // in meters
  bool _isWithinRange = false;

  // Camera
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(AttendanceFetchSettings());
    _determinePosition();
  }

  void _validateLocation() {
    if (_officeLat == null || _officeLng == null || _maxRadius == null) {
      print('DEBUG: Settings belum dimuat sepenuhnya.');
      return;
    }

    if (_currentPosition == null) {
      print('DEBUG: Lokasi GPS belum ditemukan.');
      return;
    }

    // DEBUG LOGS
    print('--- DEBUG LOCATION ---');
    print('Settings Lat: $_officeLat');
    print('Settings Lng: $_officeLng');
    print('Settings Radius: $_maxRadius');
    print('GPS Lat: ${_currentPosition!.latitude}');
    print('GPS Lng: ${_currentPosition!.longitude}');

    final distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _officeLat!,
      _officeLng!,
    );
    print('Calculated Distance: $distance meters');
    print('----------------------');

    setState(() {
      _isWithinRange = distance <= _maxRadius!;

      // Update Circles
      _circles.clear();
      _circles.add(
        Circle(
          circleId: const CircleId('coverageRadius'),
          center: LatLng(_officeLat!, _officeLng!),
          radius: _maxRadius!,
          fillColor: Colors.green.withOpacity(0.2),
          strokeColor: Colors.green,
          strokeWidth: 2,
        ),
      );

      if (_isWithinRange) {
        _locationStatus =
            'Didalam Jangkauan (${distance.toStringAsFixed(0)}m / ${_maxRadius!.toStringAsFixed(0)}m)';
      } else {
        _locationStatus =
            'Diluar Jangkauan! (${distance.toStringAsFixed(0)}m / ${_maxRadius!.toStringAsFixed(0)}m)';
      }
    });

    if (!_isWithinRange) {
      _showErrorDialog(
        'Anda berada diluar jangkauan presensi (${distance.toStringAsFixed(0)}m). Maksimal ${_maxRadius!.toStringAsFixed(0)}m.',
      );
    }
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

          // Update Map
          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId('currentLocation'),
              position: LatLng(position.latitude, position.longitude),
              infoWindow: const InfoWindow(title: 'Lokasi Anda'),
            ),
          );

          if (_officeLat != null && _officeLng != null) {
            _markers.add(
              Marker(
                markerId: const MarkerId('officeLocation'),
                position: LatLng(_officeLat!, _officeLng!),
                infoWindow: const InfoWindow(title: 'Lokasi Kantor'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
              ),
            );
            // Add circle? Maybe later.
          }
        });

        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18,
            ),
          ),
        );

        _validateLocation();
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

  // ... (keep _pickImage)

  void _onSubmit(bool isCheckIn, String? attendanceId) {
    if (_currentPosition == null) {
      _showErrorDialog('Lokasi belum ditemukan. Mohon tunggu...');
      return;
    }

    // Add Range Check
    if (isCheckIn && !_isWithinRange && _maxRadius != null) {
      _showErrorDialog(
        'Anda berada diluar jangkauan presensi. Tidak dapat melakukan Check-In.',
      );
      return;
    }
    // Check-Out usually allowed anywhere? Or restricted too? User said "muncul pesan... tombol disabled".
    // Usually Check-Out implies leaving, so maybe range check not STRICTLY required, but helpful.
    // Let's enforce for Check-In mainly as requested "tombol kirim presensi disabled".

    if (isCheckIn) {
      // ... (keep CheckIn logic)
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

  // ... (keep _showErrorDialog)

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
        if (state is AttendanceSettingsLoaded) {
          setState(() {
            _officeLat = state.settings['office_latitude'];
            _officeLng = state.settings['office_longitude'];
            _maxRadius = state.settings['radius_meter'];
          });
          _validateLocation();
        } else if (state is AttendanceSuccess) {
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
          // Initialize with passed attendance (if any)
          AttendanceModel? attendance = widget.attendance;
          bool isCheckedIn =
              attendance?.checkIn != null && attendance?.checkOut == null;

          if (state is AttendanceScheduleMapLoaded) {
            final mapAttendance = state.attendanceMap[widget.schedule.id];
            if (mapAttendance != null) {
              attendance = mapAttendance;
              isCheckedIn =
                  attendance?.checkIn != null && attendance?.checkOut == null;
            }
          } else if (state is AttendanceSuccess) {
            if (state.attendance.scheduleId == widget.schedule.id) {
              attendance = state.attendance;
              // If success implies check-in success, then we are checked in.
              // If check-out success, isCheckedIn becomes false.
              // AttendanceSuccess usually returns the updated record.
              isCheckedIn = state.attendance.checkOut == null;
            }
          }
          // Preserve SettingsLoaded state? It might be cleared if bloc emits something else?
          // AttendanceBloc emits one state at a time.
          // Wait, if AttendanceBloc emits ScheduleMapLoaded, does it lose settings?
          // Yes. Since we dispatch FetchSettings, it emits SettingsLoaded, then UI updates local state vars.
          // That's why we store them in _TeachingPageState. Ideally Bloc should hold multi-state but we are using simple Bloc.
          // So local state persistence is fine for now.

          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              title: const Text('Konfirmasi Presensi'),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    // Update state to show loading immediately
                    setState(() {
                      _isLoadingLocation = true;
                      _locationStatus = 'Memperbarui lokasi...';
                    });
                    _determinePosition();
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Map Section
                  // ... (Use _markers which we updated)
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
                            ), // Default Jepara (or use office loc if available?)
                            zoom: 14,
                          ),
                          markers: _markers,
                          circles: _circles, // Add Circles
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          onMapCreated: (controller) =>
                              _mapController = controller,
                        ),
                        if (_isLoadingLocation)
                          Container(
                            color: Colors.black.withOpacity(0.3),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        // Add Overlay for Out of Range?
                        if (!_isWithinRange &&
                            _maxRadius != null &&
                            !_isLoadingLocation &&
                            _currentPosition != null)
                          Positioned(
                            top: 10,
                            left: 10,
                            right: 10,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "DILUAR JANGKAUAN PRESENSI!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
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
                              : (_isWithinRange ? Icons.verified : Icons.error),
                          color: _isLoadingLocation
                              ? Colors.grey
                              : (_isWithinRange ? Colors.green : Colors.red),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isLoadingLocation
                                    ? 'Mencari Lokasi...'
                                    : (_isWithinRange
                                          ? 'Lokasi Valid'
                                          : 'Lokasi Invalid'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _locationStatus,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: (_isWithinRange || _isLoadingLocation)
                                      ? Colors.grey[600]
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ... (Camera Logic for !isCheckedIn)
                  const SizedBox(height: 16),

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
                          (state is AttendanceLoading ||
                              _isLoadingLocation ||
                              (!isCheckedIn &&
                                  !_isWithinRange &&
                                  _maxRadius != null))
                          ? null
                          : () => _onSubmit(!isCheckedIn, attendance?.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCheckedIn
                            ? Colors.red
                            : Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey,
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
