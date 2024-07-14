import 'package:favorite_places/modals/place.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  MapScreen(
      {super.key,
      this.isSelecting = true,
      this.Location = const PlaceLocation(
          latitude: 37.422, longtitude: -122.084, adress: 'adress')});
  final PlaceLocation Location;

  final bool isSelecting;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSelecting ? 'pick yor location' : 'Your Location'),
        actions: [
          if (widget.isSelecting)
            IconButton(
                onPressed: () {
                  Navigator.of(context).pop(_pickedLocation);
                },
                icon: const Icon(Icons.save))
        ],
      ),
      body: GoogleMap(
        onTap: !widget.isSelecting == false
            ? null
            : (position) {
                setState(() {
                  _pickedLocation = position;
                });
              },
        markers: (_pickedLocation == null && widget.isSelecting)
            ? {}
            : {
                Marker(
                    markerId: const MarkerId('m1'),
                    position: LatLng(
                        widget.Location.latitude, widget.Location.longtitude))
              },
        initialCameraPosition: CameraPosition(
          target: _pickedLocation != null
              ? _pickedLocation!
              : LatLng(widget.Location.latitude, widget.Location.longtitude),
        ),
      ),
    );
  }
}
