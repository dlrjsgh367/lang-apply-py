import 'dart:io';

import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

class ChatMediaDetailWidget extends ConsumerStatefulWidget {
  const ChatMediaDetailWidget({
    super.key,
    required this.type,
    required this.mediaUrl,
    required this.deleteChatFile,
    required this.msgKey,
    required this.chatUsers,
    required this.uuid,
    required this.isVideo,
    required this.created,
  });

  final String type;
  final String mediaUrl;
  final Function deleteChatFile;
  final String msgKey;
  final dynamic chatUsers;
  final String uuid;
  final bool isVideo;
  final String created;

  @override
  ConsumerState<ChatMediaDetailWidget> createState() =>
      _ChatMediaDetailWidgetState();
}

class _ChatMediaDetailWidgetState extends ConsumerState<ChatMediaDetailWidget>
    with Files {
  VideoPlayerController controller =
      VideoPlayerController.networkUrl(Uri.parse(''));
  bool isPlay = false;

  bool isLoading = false;

  final double minTwoDigitValue = 10;
  int currentDurationInSecond = 0;
  int currentDurationInMinutes = 0;
  int currentDurationInHours = 0;

  int totalDurationInSecond = 0;
  int totalDurationInMinutes = 0;
  int totalDurationInHours = 0;

  void playService() {
    // 재생 이벤트
    if (controller.value.isPlaying) {
      controller.pause();
      setState(() {
        isPlay = false;
      });
    } else if (!controller.value.isPlaying) {
      controller.play();
      setState(() {
        isPlay = true;
      });
    }
  }

  void updateVideoRunningTime() {
    // 재생할 비디오의 러닝타임 구하기
    controller.addListener(() {
      if (mounted) {
        // 비디오가 dispose()가 되는 순간 mounted는 false가 되므로 에러 방지로 mounted가 true일 때 작동하도록 유도
        setState(() {
          // 비디오 진행 시간
          currentDurationInSecond = controller.value.position.inSeconds;

          currentDurationInMinutes = controller.value.position.inMinutes;

          currentDurationInHours = controller.value.position.inHours;

          // 총 러닝타임
          totalDurationInSecond =
              (controller.value.duration.inMilliseconds / 1000).ceil().toInt() -
                  currentDurationInSecond;

          totalDurationInMinutes =
              controller.value.duration.inMinutes - currentDurationInMinutes;

          totalDurationInHours =
              controller.value.duration.inHours - currentDurationInHours;
        });
      }
    });
  }

  // 현재 재생 시간
  String formatCurrentPositionInSec() {
    if (currentDurationInSecond <= 0) {
      return '00';
    } else {
      return ((currentDurationInSecond % 3600) % 60) < minTwoDigitValue
          ? '0${((currentDurationInSecond % 3600) % 60).floor()}'
          : '${((currentDurationInSecond % 3600) % 60).floor()}';
    }
  }

  String formatCurrentPositionInMin() {
    if (currentDurationInMinutes <= 0) {
      return '00';
    } else {
      return (currentDurationInMinutes % 60) < minTwoDigitValue
          ? '0${(currentDurationInMinutes % 60).floor()}'
          : '${(currentDurationInMinutes % 60).floor()}';
    }
  }

  String formatCurrentPositionInHour() {
    if (currentDurationInHours <= 0) {
      return '00';
    } else {
      return currentDurationInHours < minTwoDigitValue
          ? '0${currentDurationInHours.floor()}'
          : '${currentDurationInHours.floor()}';
    }
  }

  // 총 재생 시간
  String totalDurationInSec() {
    if (totalDurationInSecond <= 0) {
      return '00';
    } else {
      return ((totalDurationInSecond % 3600) % 60) < minTwoDigitValue
          ? "0${((totalDurationInSecond % 3600) % 60).floor()}"
          : "${((totalDurationInSecond % 3600) % 60).floor()}";
    }
  }

  String totalDurationInMin() {
    if (totalDurationInMinutes <= 0) {
      return '00';
    } else {
      return (totalDurationInMinutes % 60) < minTwoDigitValue
          ? "0${(totalDurationInMinutes % 60).floor()}"
          : "${(totalDurationInMinutes % 60).floor()}";
    }
  }

  setIsLoading(value) {
    setState(() {
      isLoading = value;
    });
  }

  String totalDurationInHour() {
    if (totalDurationInHours <= 0) {
      return '00';
    } else {
      return totalDurationInHours < minTwoDigitValue
          ? "0${totalDurationInHours.floor()}"
          : "${totalDurationInHours.floor()}";
    }
  }

  getDownloadFile(String imgUrl, String fileName,
      {isSaveInGallery = false}) async {
    if (isSaveInGallery) {
      if (widget.isVideo) {
        saveNetworkVideoFile(imgUrl, fileName, setIsLoading);
      } else {
        saveNetworkImage(imgUrl, fileName);
      }
    } else {
      fileDownload(imgUrl, fileName);
    }
  }

  void openShare(String url) async {
    showDefaultToast("공유를 진행합니다.");

    // 파일 다운로드
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // 애플리케이션의 임시 디렉터리 가져오기
      final Directory directory = await getTemporaryDirectory();
      // 파일 생성 및 저장
      final String fileName = url.split('/').last; // 파일 이름 추출
      final File file = File('${directory.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);

      final result = await Share.shareXFiles([XFile(file.path)],
          text: Uri.parse(url).pathSegments.last);

      if (result.status == ShareResultStatus.success) {
        showDefaultToast("공유가 완료되었습니다.");
      }
    }
  }

  bool isOneMonthPassed() {
    DateTime now = DateTime.now();

    DateTime createDate = DateTime.parse(widget.created);
    DateTime oneMonthLater = DateTime(createDate.year, createDate.month + 1,
        createDate.day, createDate.hour, createDate.minute);
    return now.isAfter(oneMonthLater);
  }

  @override
  void initState() {
    if (widget.type == 'video') {
      setState(() {
        controller =
            VideoPlayerController.networkUrl(Uri.parse(widget.mediaUrl));
        // 비디오 정지
        controller.pause();
        // 비디오 초기화
        controller.initialize().then((_) => setState(() {
              // 비디오가 초기화되면 리스너 추가
              controller.addListener(() {
                if (controller.value.position == controller.value.duration) {
                  setState(() {
                    controller.value.position ==
                        const Duration(seconds: 0, minutes: 0, hours: 0);
                  });
                }
              });
            }));

        // video 러닝타임 업데이트
        updateVideoRunningTime();

        playService();
      });
    }
    isOneMonthPassed();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppbar(
        title: '사진 및 동영상',
      ),
      body: Stack(
        children: [
          ColoredBox(
            color: Colors.white,
            child: Column(
              children: [
                widget.type == 'video'
                    ? Stack(
                        children: [
                          Container(
                            height: CommonSize.vh - 200.0,
                            color: Colors.grey,
                            child: AspectRatio(
                              aspectRatio: controller.value.aspectRatio,
                              child: VideoPlayer(controller),
                            ),
                          ),
                          Positioned(
                              bottom: 0.0,
                              child: SizedBox(
                                width: CommonSize.vw,
                                child: Row(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          playService();
                                        });
                                      },
                                      style: TextButton.styleFrom(
                                        minimumSize: Size.zero,
                                        fixedSize: const Size(70, 70),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        padding: EdgeInsets.zero,
                                        backgroundColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(0.0),
                                        ),
                                      ).copyWith(
                                        overlayColor: ButtonStyles.overlayNone,
                                      ),
                                      child: Icon(
                                        isPlay ? Icons.pause : Icons.play_arrow,
                                        size: 30.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Expanded(
                                      child: Slider(
                                        activeColor: Colors.white,
                                        inactiveColor: Colors.grey,
                                        value: controller
                                                .value.position.inMilliseconds /
                                            1000,
                                        min: 0.0,
                                        max: controller.value.duration
                                                        .inMilliseconds /
                                                    1000 <
                                                controller.value.position
                                                        .inMilliseconds /
                                                    1000
                                            ? controller.value.position
                                                    .inMilliseconds /
                                                1000
                                            : controller.value.duration
                                                    .inMilliseconds /
                                                1000,
                                        onChanged: (value) {
                                          setState(() {
                                            controller.seekTo(Duration(
                                                seconds: value.toInt()));
                                          });
                                        },
                                      ),
                                    ),
                                    Text(
                                      totalDurationInHour() == '00'
                                          ? '${totalDurationInMin()} : ${totalDurationInSec()}'
                                          : '${totalDurationInHour()} : ${totalDurationInMin()} : ${totalDurationInSec()}',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      )
                    : Container(
                        height: CommonSize.vh - 200.0,
                        color: Colors.white,
                        child: Image.network(widget.mediaUrl),
                      ),
                Row(
                  children: [
                    if (!isOneMonthPassed())
                      TextButton(
                          onPressed: () {
                            getDownloadFile(widget.mediaUrl,
                                Uri.parse(widget.mediaUrl).pathSegments.last,
                                isSaveInGallery: true);
                          },
                          child: const Text('저장')),
                    if (!isOneMonthPassed())
                      TextButton(
                          onPressed: () {
                            openShare(widget.mediaUrl);
                          },
                          child: const Text('공유')),
                    TextButton(
                        onPressed: () {
                          widget.deleteChatFile(widget.msgKey);
                        },
                        child: const Text('삭제')),
                  ],
                ),
              ],
            ),
          ),
          if (isLoading) const Positioned(child: Loader())
        ],
      ),
    );
  }
}
