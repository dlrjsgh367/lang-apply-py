import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class JobpostingManageListWidget extends ConsumerStatefulWidget {
  const JobpostingManageListWidget({
    required this.index,
    super.key});

  final int index;
  @override
  ConsumerState<JobpostingManageListWidget> createState() => _JobpostingManageListWidgetState();
}

class _JobpostingManageListWidgetState extends ConsumerState<JobpostingManageListWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
