import 'dart:io';

import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaSelectDialogWidget extends StatefulWidget {
  MediaSelectDialogWidget(
      {super.key,
        required this.getImages,
        required this.getVideos,
        required this.uuid});

  Function getImages;
  Function getVideos;
  String uuid;

  @override
  State<MediaSelectDialogWidget> createState() => _MediaSelectDialogWidgetState();
}

class _MediaSelectDialogWidgetState extends State<MediaSelectDialogWidget> {

  void requestCameraPermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
      }
      widget.getImages('multiple');
    }else{
      widget.getImages('multiple');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentBottomSheet(
      contents: [
        BottomSheetButton(onTap: () {
          // getImages('gallery');
          requestCameraPermission();
          Navigator.pop(context);
        }, text: '이미지 전송'),
        BottomSheetButton(onTap: () {
          widget.getImages('camera');
          Navigator.pop(context);
        }, text: '촬영 이미지 전송'),
        BottomSheetButton(onTap: () {
          widget.getVideos();
          Navigator.pop(context);
        }, text: '비디오 전송'),

      ],
    );
  }
}