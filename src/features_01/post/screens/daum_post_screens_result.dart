import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:daum_postcode_search/daum_postcode_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DaumPostScreens extends ConsumerStatefulWidget {
  const DaumPostScreens({
    super.key,
  });

  @override
  ConsumerState<DaumPostScreens> createState() => _DaumPostScreensState();
}

class _DaumPostScreensState extends ConsumerState<DaumPostScreens> {
  bool _isError = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    DaumPostcodeSearch daumPostcodeSearch = DaumPostcodeSearch(
      onConsoleMessage: (_, message) => print(message),
      onLoadError: (controller, uri, errorCode, message) => setState(() {
          _isError = true;
          errorMessage = message;
        },
      ),
      onLoadHttpError: (controller, uri, errorCode, message) => setState(() {
          _isError = true;
          errorMessage = message;
        },
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppbar(
        title: localization.selectAddress,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: daumPostcodeSearch,
          ),
          // Visibility(
          //   visible: _isError,
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.stretch,
          //     children: [
          //       Text(errorMessage ?? ""),
          //       ElevatedButton(
          //         child: const Text("Refresh"),
          //         onPressed: () {
          //           daumPostcodeSearch.controller?.reload();
          //         },
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
