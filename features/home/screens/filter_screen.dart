import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class FilterScreen extends ConsumerStatefulWidget {
  const FilterScreen({super.key});

  @override
  ConsumerState<FilterScreen> createState() =>
      _FilterScreenState();
}

class _FilterScreenState extends ConsumerState<FilterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar(
        title: 'FilterScreen',
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(),
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
          BottomPadding(),
        ],
      ),
    );
  }
}
