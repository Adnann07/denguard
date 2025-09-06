import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EasyHospitalMap extends StatefulWidget {
  final String title;

  const EasyHospitalMap({Key? key, required this.title}) : super(key: key);

  @override
  EasyHospitalMapState createState() => EasyHospitalMapState();
}

class EasyHospitalMapState extends State<EasyHospitalMap> {
  final Location _locationService = Location();
  final MapController _mapController = MapController();
  LatLng? currentLocation;
  List<Marker> hospitalMarkers = [];
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLocationAndFetchHospitals();
    });
  }
//permission fetch
  Future<void> _initLocationAndFetchHospitals() async {
    try {
      setState(() => _isLoading = true);

      if (!await _locationService.serviceEnabled()) {
        await _locationService.requestService();
      }

      final status = await _locationService.requestPermission();
      if (status != PermissionStatus.granted &&
          status != PermissionStatus.grantedLimited) {
        setState(() {
          _error = 'Location permission required';
          _isLoading = false;
        });
        return;
      }

      final locationData = await _locationService.getLocation();
      final latLng = LatLng(locationData.latitude!, locationData.longitude!);

      setState(() => currentLocation = latLng);
      await _fetchNearbyHospitals(latLng);

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
//5 km range
  Future<void> _fetchNearbyHospitals(LatLng location) async {
    try {
      final query = """
        [out:json];
        (
          node["amenity"="hospital"](around:5000,${location.latitude},${location.longitude});
          way["amenity"="hospital"](around:5000,${location.latitude},${location.longitude});
          relation["amenity"="hospital"](around:5000,${location.latitude},${location.longitude});
        );
        out center;
      """;

      final response = await http
          .post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        body: {'data': query},
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final markers = _parseHospitalMarkers(data['elements']);
        setState(() => hospitalMarkers = markers);
      }
    } catch (e) {
      debugPrint('Hospital fetch error: $e');
    }
  }

  List<Marker> _parseHospitalMarkers(List<dynamic> elements) {
    return elements.map((element) {
      final lat = element['lat'] ?? element['center']?['lat'];
      final lon = element['lon'] ?? element['center']?['lon'];

      if (lat == null || lon == null) return null;

      final name = element['tags']?['name'] ?? 'Hospital';

      return Marker(
        point: LatLng(lat.toDouble(), lon.toDouble()),
        width: 40,
        height: 40,
        builder: (ctx) => Tooltip(
          message: name,
          child: const Icon(Icons.local_hospital, color: Colors.red, size: 40),
        ),
      );
    }).where((marker) => marker != null).cast<Marker>().toList();
  }
//main widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() => _error = null);
                _initLocationAndFetchHospitals();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: currentLocation,
          zoom: 14.0,
          minZoom: 3.0,
          maxZoom: 18.0,
          interactiveFlags: InteractiveFlag.all,
          onPositionChanged: (MapPosition position, bool hasGesture) {
            if (position.zoom != null && position.zoom! > 18.0) {
              _mapController.move(position.center!, 18.0);
            }
          },
          swPanBoundary: const LatLng(-85.0, -180.0),
          nePanBoundary: const LatLng(85.0, 180.0),
        ),
        children: [
          TileLayer(
            urlTemplate:
            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.easyhospitalmap',
            tileSize: 256,
            minZoom: 3,
            maxZoom: 18,
            errorTileCallback: (dynamic tile, error, stackTrace) {
              debugPrint('Tile error: $error');
            },
            backgroundColor: Colors.grey[200]!,
            additionalOptions: const {'id': 'openstreetmap'},
          ),
          MarkerLayer(
            markers: [
              if (currentLocation != null)
                Marker(
                  point: currentLocation!,
                  width: 40,
                  height: 40,
                  builder: (_) => Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ...hospitalMarkers,
            ],
          ),
        ],
      ),
      floatingActionButton: currentLocation != null
          ? FloatingActionButton(
        onPressed: () {
          _mapController.move(currentLocation!, 14.0);
        },
        child: const Icon(Icons.my_location),
      )
          : null,
    );
  }
}
