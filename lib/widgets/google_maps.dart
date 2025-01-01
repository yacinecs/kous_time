import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class GoogleMaps extends StatefulWidget {
  const GoogleMaps({super.key});

  @override
  State<GoogleMaps> createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMaps> {

  final LatLng _center = const LatLng(36.721322, 3.2059311);
  late GoogleMapController mapController;
  final DatabaseReference ref = FirebaseDatabase.instance.ref();
  final Set<Marker> _markers = {};

  @override
  void initState() {
    _initStops();




    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kous Time"),
        centerTitle: true,

      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
          markers: _markers,
        ),


      ),
    );
  }
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }


  Future<void> _initStops() async {
    try {
      // Fetch stop data from Firebase
      DatabaseEvent stopsEvent = await ref.child('Stop').once();

      if (stopsEvent.snapshot.exists) {
        final stopsData = stopsEvent.snapshot.value as List<dynamic>;
        final Set<Marker> newMarkers = {};

        for (int i = 0; i < stopsData.length; i++) {
          final stop = stopsData[i];
          if (stop is Map) {
            final latitude = double.tryParse(stop['latitude'].toString());
            final longitude = double.tryParse(stop['longitude'].toString());
            final name = stop['name'] as String?;

            if (latitude != null && longitude != null && name != null) {
              Marker marker = Marker(
                markerId: MarkerId('stop_$i'),
                position: LatLng(latitude, longitude),
                infoWindow: InfoWindow(title: name),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
              );
              newMarkers.add(marker);
            }
          }
        }

        setState(() {
          _markers.addAll(newMarkers);
        });

        //print("Markers added: $_markers");
      } else {
        //print("No stops found in the database.");
      }
    } catch (e) {
      //print("Error fetching stops: $e");
    }
  }




}
