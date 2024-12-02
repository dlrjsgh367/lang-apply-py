// import 'dart:async';
// import 'dart:ui';
// import 'package:chodan_flutter_app/features/map/cluster_item.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
//
// class GoogleClusteredMapScreen extends StatefulWidget {
//   const GoogleClusteredMapScreen({super.key});
//
//   @override
//   State<GoogleClusteredMapScreen> createState() =>
//       _GoogleClusteredMapScreenState();
// }
//
// class _GoogleClusteredMapScreenState extends State<GoogleClusteredMapScreen> {
//   final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
//   final _markers = <Marker>{};
//   final _restaurants = [
//     {
//       'name': '후라토식당 아브뉴프랑 판교점',
//       'latitude': 37.397231,
//       'longitude': 127.113562,
//     },
//     {
//       'name': '고반식당 판교아브뉴프랑점',
//       'latitude': 37.397502,
//       'longitude': 127.113748,
//     },
//     {
//       'name': '더플레이스 판교점',
//       'latitude': 37.397328,
//       'longitude': 127.113427,
//     },
//     {
//       'name': '돼지맨숀',
//       'latitude': 37.397565,
//       'longitude': 127.113209,
//     },
//     {
//       'name': '감성타코 판교점',
//       'latitude': 37.397490,
//       'longitude': 127.113337,
//     },
//     {
//       'name': '정희',
//       'latitude': 37.397858,
//       'longitude': 127.113355,
//     },
//     {
//       'name': '생어거스틴아브뉴프랑판교점',
//       'latitude': 37.397565,
//       'longitude': 127.113379,
//     },
//   ];
//   late final List<Place> places;
//   ClusterManager? _manager;
//
//   late Uint8List markerImage;
//
//   // 첫 위치 설정
//   static const CameraPosition _pangyo = CameraPosition(
//     target: LatLng(37.397295, 127.113555),
//     zoom: 18,
//   );
//
//   @override
//   void initState() {
//     super.initState();
//     setCustomMapPin().then((_) {
//       places = _restaurants.map((restaurant) {
//         return Place(
//           name: restaurant['name'] as String,
//           latLng: LatLng(
//             restaurant['latitude'] as double,
//             restaurant['longitude'] as double,
//           ),
//         );
//       }).toList();
//       _initClusterManager();
//     });
//   }
//
//
//   void _initClusterManager() {
//     _manager = _initClusterManagerInstance();
//     setState(() {});
//   }
//
//   ClusterManager _initClusterManagerInstance() {
//     return ClusterManager<Place>(
//       places,
//       _updateMarkers,
//       markerBuilder: markerBuilder,
//     );
//   }
//
//
//
//   setCustomMapPin() async {
//     markerImage = await getBytesFromAsset('assets/images/icon/icon_locationColor.png', 100);
//   }
//
//   Future<Uint8List> getBytesFromAsset(String path, int width) async {
//     ByteData data = await rootBundle.load(path);
//     ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
//     ui.FrameInfo fi = await codec.getNextFrame();
//     return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
//   }
//
//   void _updateMarkers(Set<Marker> markers) {
//     setState(() {
//       _markers.clear();
//       _markers.addAll(markers);
//     });
//   }
//
//   Future<Marker> Function(dynamic) get markerBuilder => (cluster) async {
//     return Marker(
//       markerId: MarkerId(cluster.getId()),
//       position: cluster.location,
//       infoWindow: InfoWindow(
//         title: cluster.items.first is Place ? (cluster.items.first as Place).name : '',
//         // title: cluster.items.first is Place ? (cluster.items.first as Place).name : '',
//         snippet: '진희가 가본 곳',
//       ),
//       onTap: () {
//       },
//       icon: cluster.isMultiple
//           ? await getClusterBitmap(125, text: cluster.count.toString())
//           : BitmapDescriptor.fromBytes(markerImage),
//       // : BitmapDescriptor.defaultMarker,
//     );
//   };
//
//   Future<BitmapDescriptor> getClusterBitmap(int size, {String? text}) async {
//     final PictureRecorder pictureRecorder = PictureRecorder();
//     final Canvas canvas = Canvas(pictureRecorder);
//     final Paint paint1 = Paint()..color = Colors.red;
//
//     canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
//
//     if (text != null) {
//       TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
//       painter.text = TextSpan(
//         text: text,
//         style: TextStyle(
//             fontSize: size / 3,
//             color: Colors.white,
//             fontWeight: FontWeight.normal),
//       );
//       painter.layout();
//       painter.paint(
//         canvas,
//         Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
//       );
//     }
//
//     final img = await pictureRecorder.endRecording().toImage(size, size);
//     final data = await img.toByteData(format: ImageByteFormat.png);
//
//     return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_manager == null) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     } else {
//       return Scaffold(
//         body: GoogleMap(
//           mapType: MapType.normal,
//           initialCameraPosition: _pangyo,
//           markers: _markers,
//           onMapCreated: (GoogleMapController controller) {
//             _controller.complete(controller);
//             _manager!.setMapId(controller.mapId);
//           },
//           onCameraMove: _manager!.onCameraMove,
//           onCameraIdle: _manager!.updateMap,
//           tiltGesturesEnabled: false,
//           rotateGesturesEnabled: false,
//         ),
//       );
//     }
//   }
//
// }