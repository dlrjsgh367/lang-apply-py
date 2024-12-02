import 'package:chodan_flutter_app/core/service/branch_dynamiclink.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class BranchTestScreen extends StatefulWidget {
  const BranchTestScreen({super.key});

  @override
  State<BranchTestScreen> createState() => _BranchTestScreenState();
}

class _BranchTestScreenState extends State<BranchTestScreen> {

  BranchDynamicLink branchDynamicLink = BranchDynamicLink();

  @override
  void initState() {
    super.initState();

    // branchDynamicLink.listenDynamicLinks(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              const Text(
                'HomeScreen',
              ),
              ElevatedButton(
                  onPressed: () {
                    branchDynamicLink.generateLink(context, 'test');
                  },
                  child: const Text('Generate Link')),
              ElevatedButton(
                  onPressed: () {
                    context.push('/test');
                  },
                  child: const Text('test gogogogogo')),
            ],
          ),
        ),
      ),
    );
  }
}
