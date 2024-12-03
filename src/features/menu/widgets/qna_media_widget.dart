import 'dart:io';

import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

class QnaMediaWidget extends ConsumerStatefulWidget {
  const QnaMediaWidget({
    super.key,
    required this.mediaUrl,
  });

  final String mediaUrl;

  @override
  ConsumerState<QnaMediaWidget> createState() => _QnaMediaWidgetState();
}

class _QnaMediaWidgetState extends ConsumerState<QnaMediaWidget> with Files {
  bool isLoading = false;

  setIsLoading(value) {
    setState(() {
      isLoading = value;
    });
  }

  getDownloadFile(String imgUrl, String fileName,
      {isSaveInGallery = false}) async {
    if (isSaveInGallery) {
      saveNetworkImage(imgUrl, fileName);
    } else {
      fileDownload(imgUrl, fileName);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppbar(
        title: localization.200,
      ),
      body: Stack(
        children: [
          ColoredBox(
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  height: CommonSize.vh - 200.0,
                  color: Colors.white,
                  child: Image.network(widget.mediaUrl),
                )
              ],
            ),
          ),
          if (isLoading) const Positioned(child: Loader())
        ],
      ),
    );
  }
}
