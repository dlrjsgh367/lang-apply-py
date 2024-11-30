import 'dart:async';
import 'dart:io';

import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/widgets/appbar/modal_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class SeekerViewerWidget extends ConsumerStatefulWidget {
  const SeekerViewerWidget({
    super.key,
    required this.pdfUrl,
    required this.fileName,
  });

  final String pdfUrl;
  final String fileName;

  @override
  ConsumerState<SeekerViewerWidget> createState() => _SeekerViewerWidgetState();
}

class _SeekerViewerWidgetState extends ConsumerState<SeekerViewerWidget>
    with Files {

  final Completer<PDFViewController> _controller =
  Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  bool isLoading = false;
  File? savePdfFile;

  String pdfUrl = '';
  String fileName = '';

  Future<Uint8List> getFileData(String fileUrl) async {
    final response = await http.get(Uri.parse(fileUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load file');
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    Future(() {
      setState(() {
        pdfUrl = widget.pdfUrl;
        fileName = widget.fileName;
        isLoading = false;
      });
      getFileFromUrl(pdfUrl);
    });
  }

  getFileFromUrl(String url) async {
    try {
      var data = await http.get(Uri.parse(url));
      var bytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/" + fileName + ".pdf");
      File urlFile = await file.writeAsBytes(bytes);
      setState(() {
        savePdfFile = urlFile;
      });
    } catch (e) {
      throw Exception("Error opening url file");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ModalAppbar(
        title: localization.pdfPreview,
      ),
      body: isLoading
          ? const Loader()
          : Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                        20.w, 8.w, 20.w, CommonSize.commonBottom),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            AspectRatio(
                              aspectRatio: 320 / 480,
                              child: PDFView(
                                filePath: savePdfFile!.path,
                                enableSwipe: true,
                                swipeHorizontal: true,
                                autoSpacing: false,
                                pageFling: true,
                                pageSnap: true,
                                defaultPage: currentPage!,
                                fitPolicy: FitPolicy.BOTH,
                                preventLinkNavigation: false,
                                // if set to true the link is handled in flutter
                                onRender: (_pages) {
                                  setState(() {
                                    pages = _pages;
                                    isReady = true;
                                  });
                                },
                                onViewCreated:
                                    (PDFViewController pdfViewController) {
                                  _controller.complete(pdfViewController);
                                },
                                onPageChanged: (int? page, int? total) {
                                  setState(() {
                                    currentPage = page;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FutureBuilder<PDFViewController>(
                                future: _controller.future,
                                builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
                                  if (snapshot.hasData) {
                                    return
                                      IconButton(
                                        icon: const Icon(Icons.navigate_before),
                                        onPressed: () async {
                                          setState(() {
                                            if (currentPage! > 0) {
                                              currentPage = currentPage! - 1;
                                            }
                                          });
                                          await snapshot.data!.setPage(currentPage!);
                                        },
                                      );
                                  }

                                  return Container();
                                },
                              ),
                              Center(
                                child: Text(
                                  '${(currentPage! + 1)}/${pages ?? 0}',
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                              FutureBuilder<PDFViewController>(
                                future: _controller.future,
                                builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
                                  if (snapshot.hasData) {
                                    return
                                      IconButton(
                                        icon: const Icon(Icons.navigate_next),
                                        onPressed: () async {
                                          setState(() {
                                            if (currentPage! < pages! - 1) {
                                              currentPage = currentPage! + 1;
                                            }
                                          });
                                          await snapshot.data!.setPage(currentPage!);
                                        },
                                      );
                                  }

                                  return Container();
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.w,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: BorderButton(
                                onPressed: () {
                                  fileDownload(pdfUrl, fileName);
                                },
                                text: localization.pdfDownload,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
