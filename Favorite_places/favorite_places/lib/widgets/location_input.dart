import 'dart:convert';

import 'package:favorite_places/modals/place.dart';
import 'package:favorite_places/screens/map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});
  final void Function(PlaceLocation location) onSelectLocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;

  String get locationImage {
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longtitude;
    return "https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=13&size=600x300&maptype=roadmap&markers=color:blue%7Clabel:S%7C$lat,$lng&markers=color:green%7Clabel:G%7C$lat,$lng&markers=color:red%7Clabel:C%7C$lat,$lng&key=AIzaSyDMYITbD2vFP2AHsxJ8r1Gi-QGpKmRZq4w";
  }

  void _selectOnmap() async {
    final pickedlocation =
        await Navigator.of(context).push<LatLng>(MaterialPageRoute(
      builder: (context) => MapScreen(),
    ));
    if (pickedlocation == null) {
      return;
    }
    _savePlace(pickedlocation.latitude, pickedlocation.longitude);
  }

  void _savePlace(double latitude, double longtitude) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longtitude&key=AIzaSyDMYITbD2vFP2AHsxJ8r1Gi-QGpKmRZq4w');

    final response = await http.get(url);
    final responsedata = json.decode(response.body);
    final adress = responsedata['results'][0]['formatted_address'];

    setState(() {
      _pickedLocation = PlaceLocation(
          latitude: latitude, longtitude: longtitude, adress: adress);
      _isGettingLocation = false;
    });

    widget.onSelectLocation(_pickedLocation!);
  }

  void _getcurrentlocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lng = locationData.longitude;
    if (lat == null || lng == null) {
      return;
    }
    _savePlace(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    Widget Priviewcontent = const Text(
      'No location chosen ',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white),
    );
    if (_pickedLocation != null) {
      Priviewcontent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (_isGettingLocation) {
      Priviewcontent = const CircularProgressIndicator();
    }
    return Column(
      children: [
        Container(
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black)),
            height: 250,
            width: double.infinity,
            alignment: Alignment.center,
            child: Priviewcontent),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
                onPressed: _getcurrentlocation,
                icon: const Icon(Icons.location_on),
                label: const Text('Get Current Location')),
            TextButton.icon(
                onPressed: _selectOnmap,
                icon: const Icon(Icons.map),
                label: const Text('Select on map'))
          ],
        ),
      ],
    );
  }
}
