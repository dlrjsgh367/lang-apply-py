import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/checkbox/circle_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ApplyCheck extends StatefulWidget {
  ApplyCheck({
    super.key,
    required this.text,
    required this.title,
    required this.onChanged,
    required this.groupValue,
    required this.value,
  });

  final String text;
  final String title;
  final Function onChanged;
  final dynamic value;
  final dynamic groupValue;

  @override
  State<ApplyCheck> createState() => _ApplyCheckState();
}

class _ApplyCheckState extends State<ApplyCheck> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () {
          widget.onChanged(widget.value);
        },
        child: Container(
          color: Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleCheck(
                onChanged: (value) {},
                readOnly: true,
                value: widget.groupValue == widget.value,
              ),
              SizedBox(
                width: 8.w,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: CommonColors.black2b,
                      ),
                    ),
                    SizedBox(
                      height: 4.w,
                    ),
                    Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: CommonColors.grayB2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class ApplyCheck extends StatelessWidget {
//   const ApplyCheck({
//     super.key,
//     required this.text,
//     required this.title,
//     required this.onChanged,
//     required this.groupValue,
//     required this.value,
//   });
//
//   final String text;
//   final String title;
//   final Function onChanged;
//   final dynamic value;
//   final dynamic groupValue;
//
//   @override
//   Widget build(BuildContext context) {
//     return SliverToBoxAdapter(
//       child: GestureDetector(
//         onTap: () {
//           onChanged(value);
//         },
//         child: Container(
//           color: Colors.transparent,
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               CircleCheck(
//                 onChanged: (value) {},
//                 readOnly: true,
//                 value: groupValue == value,
//               ),
//               SizedBox(
//                 width: 8.w,
//               ),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.w500,
//                         color: CommonColors.black2b,
//                       ),
//                     ),
//                     SizedBox(
//                       height: 4.w,
//                     ),
//                     Text(
//                       text,
//                       style: TextStyle(
//                         fontSize: 13.sp,
//                         fontWeight: FontWeight.w500,
//                         color: CommonColors.grayB2,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
