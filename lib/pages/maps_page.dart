import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:payment_app/components/my_button.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> with WidgetsBindingObserver {
  GoogleMapController? mapController;
  LatLng? _currentPosition;
  final loc.Location _location = loc.Location();
  Marker? _currentLocationMarker;
  CameraPosition? _cameraPosition;
  late bool _locationServiceEnabled;
  late loc.PermissionStatus _permissionGranted;
  Stream<loc.LocationData>? _locationStream;
  late Future<void> _locationFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _locationFuture = _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    _locationServiceEnabled = await _location.serviceEnabled();
    if (!_locationServiceEnabled) {
      _locationServiceEnabled = await _location.requestService();
      if (!_locationServiceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    loc.LocationData locationData = await _location.getLocation();
    if (!mounted) return;
    setState(() {
      _currentPosition =
          LatLng(locationData.latitude!, locationData.longitude!);
      _updateMarker(_currentPosition!);
      _cameraPosition = CameraPosition(
        target: _currentPosition!,
        zoom: 13.0,
      );
    });

    _locationStream = _location.onLocationChanged;
    _locationStream?.listen((loc.LocationData currentLocation) {
      if (!mounted) return;
      setState(() {
        _currentPosition =
            LatLng(currentLocation.latitude!, currentLocation.longitude!);
        _updateMarker(_currentPosition!);
      });
    });
  }

  void _updateMarker(LatLng position) {
    _currentLocationMarker = Marker(
      markerId: const MarkerId('current_location'),
      position: position,
      draggable: true,
      onDragEnd: (newPosition) {
        setState(() {
          _currentPosition = newPosition;
        });
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_cameraPosition != null) {
      mapController!.moveCamera(
        CameraUpdate.newCameraPosition(_cameraPosition!),
      );
    } else if (_currentPosition != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition!,
            zoom: 13.0,
          ),
        ),
      );
    }
  }

  Future<String> _getCityCountryAndAreaFromLatLng(LatLng position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      final Placemark place = placemarks.first;
      return "${place.locality}, ${place.subLocality}, ${place.country}";
    }
    return "Unknown location";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps Demo'),
      ),
      body: FutureBuilder<void>(
        future: _locationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error fetching location"));
          } else {
            return Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition!,
                      zoom: 13.0,
                    ),
                    markers: {
                      if (_currentLocationMarker != null)
                        _currentLocationMarker!,
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    onTap: (position) {
                      setState(() {
                        _currentPosition = position;
                        _updateMarker(_currentPosition!);
                      });
                    },
                    onCameraMove: (CameraPosition position) {
                      _cameraPosition = position;
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    myButton(
                      "Select Location",
                      Colors.indigo,
                      () async {
                        if (_currentPosition != null) {
                          final address =
                              await _getCityCountryAndAreaFromLatLng(
                                  _currentPosition!);
                          Navigator.pop(context, address);
                        } else {}
                      },
                      Colors.white,
                      false,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
