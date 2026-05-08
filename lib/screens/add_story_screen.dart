import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class AddStoryScreen extends StatefulWidget {
  const AddStoryScreen({super.key});

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  final TextEditingController desc = TextEditingController();

  File? image;

  bool isPicking = false;
  bool isUploading = false;

  LatLng? selectedLocation;

  GoogleMapController? mapController;

  static const LatLng initialLocation = LatLng(-6.200000, 106.816666);

  @override
  void dispose() {
    desc.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    if (isPicking) return;

    setState(() {
      isPicking = true;
    });

    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (picked != null && mounted) {
        setState(() {
          image = File(picked.path);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isPicking = false;
        });
      }
    }
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();

    final location = LatLng(position.latitude, position.longitude);

    setState(() {
      selectedLocation = location;
    });

    mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 15));
  }

  Future<void> upload(String token) async {
    if (image == null) return;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://story-api.dicoding.dev/v1/stories'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(await http.MultipartFile.fromPath('photo', image!.path));

    request.fields['description'] = desc.text;

    if (selectedLocation != null) {
      request.fields['lat'] = selectedLocation!.latitude.toString();

      request.fields['lon'] = selectedLocation!.longitude.toString();
    }

    await request.send();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Story',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Your Story',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Bagikan cerita terbaikmu hari ini.',
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 28),

            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.file(image!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_a_photo_rounded,
                              size: 40,
                              color: Colors.deepPurple.shade400,
                            ),
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            'Tap untuk memilih gambar',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: desc,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Tulis cerita kamu di sini...',
              ),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pick Location',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),

                ElevatedButton.icon(
                  onPressed: getCurrentLocation,
                  icon: const Icon(Icons.my_location_rounded),
                  label: const Text('My Location'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              height: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: initialLocation,
                    zoom: 10,
                  ),
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                  onTap: (position) {
                    setState(() {
                      selectedLocation = position;
                    });
                  },
                  markers: selectedLocation == null
                      ? {}
                      : {
                          Marker(
                            markerId: const MarkerId('selected'),
                            position: selectedLocation!,
                            infoWindow: const InfoWindow(
                              title: 'Selected Location',
                            ),
                          ),
                        },
                ),
              ),
            ),
            Container(
              height: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: initialLocation,
                    zoom: 10,
                  ),
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                  onTap: (position) {
                    setState(() {
                      selectedLocation = position;
                    });
                  },
                  markers: selectedLocation == null
                      ? {}
                      : {
                          Marker(
                            markerId: const MarkerId('selected'),
                            position: selectedLocation!,
                            infoWindow: const InfoWindow(
                              title: 'Selected Location',
                            ),
                          ),
                        },
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (selectedLocation != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: Colors.deepPurple.shade400,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        '${selectedLocation!.latitude}, ${selectedLocation!.longitude}',
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 36),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: isUploading
                    ? null
                    : () async {
                        if (image == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pilih gambar dulu')),
                          );
                          return;
                        }

                        if (desc.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Deskripsi wajib diisi'),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          isUploading = true;
                        });

                        await upload(auth.token!);

                        if (!mounted) return;

                        setState(() {
                          isUploading = false;
                        });

                        context.pop(true);
                      },
                child: isUploading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Upload Story',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
