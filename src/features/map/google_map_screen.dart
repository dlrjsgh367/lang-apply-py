import 'dart:async';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/enum/salary_type_enum.dart';
import 'package:chodan_flutter_app/features/home/widgets/alba_map_swiper.dart';
import 'package:chodan_flutter_app/features/map/widgets/alba_marker.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({
    required this.currentPosition,
    required this.jobpostList,
    required this.moveCurrentLocation,
    required this.userProfileList,
    required this.getProfileList,
    required this.controller,
    super.key,
    required this.moveSwiper,
    required this.setShowList,
    required this.moveLocation,
  });

  final Function getProfileList;

  final Map<String, dynamic> currentPosition;
  final Function moveCurrentLocation;
  final List<ProfileModel> userProfileList;
  final List jobpostList;
  final Completer<GoogleMapController> controller;
  final Function moveSwiper;
  final Function setShowList;
  final Function moveLocation;

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  late ClusterManager<Place> _manager;
  List<Place> places = [];
  MarkerId selectedMk = MarkerId('map-maker--1');
  List selectedJob = [];
  final formatCurrency = NumberFormat('#,###');
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCluster();
  }

  @override
  void didUpdateWidget(covariant GoogleMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.jobpostList != widget.jobpostList) {
      _initializeCluster();
    }
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  void _initializeCluster() {
    setState(() {
      isLoading = true;
    });
    places = widget.jobpostList.map((data) {
      return Place(
        key: data.key,
        salary: returnSalary(data.salary),
        type: data.jobOneDepth,
        salayType: returnSalaryTypeNameFromParam(data.salaryType.param),
        latLng: LatLng(
          data.lat,
          data.long,
        ),
      );
    }).toList();

    _manager = ClusterManager<Place>(
      places,
      _updateMarkers,
      markerBuilder: markerBuilder,
    );

    if (_controller != null) {
      _manager.setMapId(_controller!.mapId);
      _manager.updateMap();
    }
    setState(() {
      isLoading = false;
    });
  }

  String returnSalary(int data) {
    String salary;
    if (data >= 100000000) {
      int billions = (data / 100000000).floor();
      if (data % 100000000 == 0) {
        salary = '$billions억';
      } else {
        salary = '$billions억+';
      }
    } else if (data >= 1000000) {
      int millions = (data / 10000).floor();
      if (data % 10000 == 0) {
        salary = '$millions만';
      } else {
        salary = '$millions만+';
      }
    } else {
      salary = '${formatCurrency.format(data)}원'; // 100만 미만
    }
    return salary;
  }

  String returnIcon(int data) {
    switch (data) {
      case 1:
        return 'assets/images/default/iconFoodWhite.png';
      case 2:
        return 'assets/images/default/iconDriveWhite.png';
      case 3:
        return 'assets/images/default/iconProWhite.png';
      case 4:
        return 'assets/images/default/iconWorkWhite.png';
      case 5:
        return 'assets/images/default/iconSellWhite.png';
      case 6:
        return 'assets/images/default/iconResWhite.png';
      case 7:
        return 'assets/images/default/iconServiceWhite.png';
      case 8:
        return 'assets/images/default/iconItWhite.png';
      case 9:
        return 'assets/images/default/iconConsultWhite.png';
      case 10:
        return 'assets/images/default/iconMediWhite.png';
      case 11:
        return 'assets/images/default/iconEduWhite.png';
      default:
        return 'assets/images/default/iconFoodWhite.png';
    }
  }

  Future<Marker> Function(Cluster<Place>) get markerBuilder => (cluster) async {
        var dataArr = cluster.items as List<Place>;
        Place data = dataArr[0];
        ui.Image iconImage = await loadImage(returnIcon(data.type));

        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          consumeTapEvents: true,
          icon: await getClusterBitmap(
            count: cluster.items.length,
            width: 136.w.toInt() * 3,
            height: 73.w.toInt() * 3,
            selected: selectedMk == MarkerId(cluster.getId()),
            salaryTypeName: data.salayType,
            salary: data.salary,
            iconInfo: iconImage,
          ),
          onTap: () {
            setState(() {
              if (selectedMk == MarkerId(cluster.getId())) {
                selectedMk = MarkerId('map-maker--1');
                selectedJob = [];
              } else {
                selectedMk = MarkerId(cluster.getId());
                selectedJob = [];
                for (Place item in cluster.items as List<Place>) {
                  for (var j = 0; j < widget.jobpostList.length; j++) {
                    if (item.key == widget.jobpostList[j].key) {
                      selectedJob.add(widget.jobpostList[j]);
                    }
                  }
                }
              }
            });
            _manager.updateMap();
          },
        );
      };

  void _updateMarkers(Set<Marker> markers) {
    setState(() {
      _markers.clear();
      _markers.addAll(markers);
    });
  }

  Future<BitmapDescriptor> getClusterBitmap({
    required int width,
    required int height,
    required bool selected,
    required int count,
    required String salaryTypeName,
    required String salary,
    required ui.Image iconInfo,
    String? text,
  }) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    MyClusterPainter(
      count: count,
      selected: selected,
      salaryTypeName: salaryTypeName,
      salary: salary,
      iconInfo: iconInfo,
    ).paint(canvas, Size(136.w * 3, 73.w * 3));

    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  Future<ui.Image> loadImage(String path) async {
    ByteData data = await rootBundle.load(path);
    Uint8List bytes = data.buffer.asUint8List();
    ui.Codec codec = await ui.instantiateImageCodec(bytes);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  Future<void> _onCameraIdle() async {
    if (_controller == null) return;
    final LatLngBounds visibleRegion = await _controller!.getVisibleRegion();
    final double latCenter =
        (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) /
            2;
    final double lngCenter = (visibleRegion.northeast.longitude +
            visibleRegion.southwest.longitude) /
        2;
    final LatLng centerPosition = LatLng(latCenter, lngCenter);

    widget.moveLocation(centerPosition);

    _manager.updateMap();
  }

  resetSwiper() {
    setState(() {
      selectedMk = MarkerId('map-maker--1');
      selectedJob = [];
      _manager.updateMap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                  widget.currentPosition['lat'], widget.currentPosition['lng']),
              zoom: 18,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              if (!widget.controller.isCompleted) {
                widget.controller.complete(controller);
              }
              _manager.setMapId(controller.mapId);
            },
            onCameraMove: (CameraPosition position) {
              _manager.onCameraMove(position);
              resetSwiper();
            },
            onCameraIdle: () {
              _onCameraIdle();
            },
            onTap: (LatLng position) {
              resetSwiper();
            },
            markers: _markers,
            zoomControlsEnabled: false,
            zoomGesturesEnabled: true,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
            compassEnabled: false,
          ),
          if (selectedJob.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 58.w,
              child: AlbaMapSwiper(
                data: selectedJob,
                currentPosition: widget.currentPosition,
                userProfileList: widget.userProfileList,
                getProfile: widget.getProfileList,
              ),
            ),
          Positioned(
            right: 20.w,
            bottom: 8.w,
            child: GestureDetector(
              onTap: () {
                widget.moveCurrentLocation();
              },
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CommonColors.white,
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 8,
                      color: Color.fromRGBO(0, 0, 0, 0.15),
                    )
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/icon/iconCurrent.png',
                    width: 24.w,
                    height: 24.w,
                  ),
                ),
              ),
            ),
          ),
          if (isLoading) const Loader(),
        ],
      ),
    );
  }
}
