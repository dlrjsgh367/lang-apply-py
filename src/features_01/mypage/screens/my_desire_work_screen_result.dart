import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class MyDesireWorkScreen extends ConsumerStatefulWidget {
  const MyDesireWorkScreen({super.key});

  @override
  ConsumerState<MyDesireWorkScreen> createState() =>
      _MyDesireWorkScreenState();
}

class _MyDesireWorkScreenState extends ConsumerState<MyDesireWorkScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppbar(
        title: 'MyDesireWorkScreen',
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
