import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PostingCollapseBtn extends StatefulWidget {
  PostingCollapseBtn({
    super.key,
    required this.childArr,
    required this.title,
    this.backColor = const Color(0xffffffff),
    this.paddingLeft = 20,
  });

  final String title;
  final Color backColor;
  List<Widget> childArr;
  final int paddingLeft;

  @override
  State<PostingCollapseBtn> createState() => _PostingCollapseBtnState();
}

class _PostingCollapseBtnState extends State<PostingCollapseBtn>
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
      _controller.animateBack(0, duration: Duration(milliseconds: 200));
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
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
            child: Container(
              height: 48.w,
              decoration: BoxDecoration(
                color: widget.backColor,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
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
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
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
