import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';

class JobpostingTitleColumnWidget extends StatelessWidget {
  const JobpostingTitleColumnWidget({
    required this.title,
    required this.isRequired,
    required this.widget,
    super.key});

  final String title;
  final bool isRequired;
  final Widget widget;


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Text(title),
            if(isRequired)
            Positioned(
                child: Text('*',
                  style: TextStyle(
                    color: CommonColors.red
                  ),
                ))
          ],
        ),
        widget,
      ],
    );
  }
}
