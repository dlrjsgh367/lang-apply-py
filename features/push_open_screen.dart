import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'alarm/controller/alarm_controller.dart';
import 'auth/controller/auth_controller.dart';

class PushOpenScreen extends ConsumerStatefulWidget {
  const PushOpenScreen({
    Key? key,
    required this.route,
  }) : super(key: key);

  final String route;

  @override
  ConsumerState createState() => _PushOpenScreenState();
}

class _PushOpenScreenState extends ConsumerState<PushOpenScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await movePage();
    });
    super.initState();
  }

  movePage() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      context.replace('/');
    } else {
      // await ref.read(alarmControllerProvider.notifier).readAllAlarm();
      // ApiResultModel result =
      //     await ref.read(authControllerProvider.notifier).getUserData();
      // if (result.type == 1) {
      //   setState(() {
      //     ref.read(userProvider.notifier).update((state) => result.data);
      //   });
      // }
      context.push(widget.route).then((_) {
        context.replace('/');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
    );
  }
}
