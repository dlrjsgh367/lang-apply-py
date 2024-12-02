import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FaqCollapseBtn extends StatefulWidget {
  const FaqCollapseBtn({
    super.key,
    required this.childArr,
    required this.title,
    this.backColor = const Color(0xffffffff),
    this.paddingLeft = 20,
    this.openColor,
  });

  final String title;
  final Color backColor;
  final List<Widget> childArr;
  final int paddingLeft;
  final Color? openColor;

  @override
  State<FaqCollapseBtn> createState() => _FaqCollapseBtnState();
}

class _FaqCollapseBtnState extends State<FaqCollapseBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isOpen = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );
  }

  void setOpen() {
    if (_animation.status != AnimationStatus.completed) {
      _controller.forward();
    } else {
      _controller.animateBack(0, duration: const Duration(milliseconds: 200));
    }
    setState(() {
      isOpen = !isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () {
            setOpen();
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.w), // 적절한 패딩 적용
            decoration: BoxDecoration(
              color: widget.openColor != null && isOpen
                  ? widget.openColor!
                  : widget.backColor,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    overflow: isOpen ? TextOverflow.visible : TextOverflow.ellipsis,
                    maxLines: isOpen ? null : 1,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: CommonColors.gray66,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isOpen ? 1 / 2 : 0,
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  child: Image.asset(
                    'assets/images/icon/iconArrowDown.png',
                    width: 20.w,
                    height: 20.w,
                  ),
                ),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1.w,
                color: CommonColors.grayF2,
              ),
            ),
          ),
          child: SizeTransition(
            sizeFactor: _animation,
            axis: Axis.vertical,
            axisAlignment: -1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: widget.childArr,
            ),
          ),
        ),
      ],
    );
  }
}
