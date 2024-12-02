import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BranchOpenScreen extends ConsumerStatefulWidget {
  const BranchOpenScreen({
    Key? key,
    required this.route,
  }) : super(key: key);

  final String route;

  @override
  ConsumerState createState() => _BranchOpenScreenState();
}

class _BranchOpenScreenState extends ConsumerState<BranchOpenScreen> {
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
    } else if (widget.route == '' || widget.route == '/') {
      context.replace('/');
    } else {
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
