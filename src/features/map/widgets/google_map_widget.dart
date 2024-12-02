import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget(
      {required this.mapWidth,
      required this.mapHeight,
      required this.data,
      required this.targetLat,
      required this.targetLong,
      super.key});

  final double mapWidth;
  final double mapHeight;
  final List<Map<String, dynamic>> data;
  final double targetLat;
  final double targetLong;

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final _markers = <Marker>{};

  late CameraPosition target;

  @override
  void initState() {
    super.initState();
    target = CameraPosition(
      target: LatLng(widget.targetLat, widget.targetLong),
      zoom: 16,
    );
    _markers.addAll(
      widget.data.map(
        (e) => Marker(
            markerId: MarkerId(e['name'] as String),
            infoWindow: InfoWindow(title: e['name'] as String),
            consumeTapEvents: true,
            position: LatLng(
              e['latitude'] as double,
              e['longitude'] as double,
            ),
            onTap: () {
              return;
            }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.mapWidth,
      height: widget.mapHeight,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: target,
        myLocationButtonEnabled: false,
        myLocationEnabled: false,
        zoomControlsEnabled: false,
        zoomGesturesEnabled: false,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        compassEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _markers,
      ),
    );
  }
}
