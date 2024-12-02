import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class MyDesireOccuScreen extends ConsumerStatefulWidget {
  const MyDesireOccuScreen({super.key});

  @override
  ConsumerState<MyDesireOccuScreen> createState() =>
      _MyDesireOccuScreenState();
}

class _MyDesireOccuScreenState extends ConsumerState<MyDesireOccuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppbar(
        title: 'MyDesireOccuScreen',
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: 20,
                  (context, index) {
                return Container(
                  height: 50,
                  color: index % 2 == 0 ? Colors.blue : Colors.red,
                );
              },
            ),
          ),
          const BottomPadding(),
        ],
      ),
    );
  }
}
