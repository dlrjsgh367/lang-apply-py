import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SelectJobOfferWidget extends StatefulWidget {
  const SelectJobOfferWidget({
    super.key,
    required this.profileData,
  });

  final Map<String, dynamic> profileData;

  @override
  State<SelectJobOfferWidget> createState() =>
      _SelectJobOfferWidgetState();
}

class _SelectJobOfferWidgetState extends State<SelectJobOfferWidget> {
  int selectedOption = 1;

  @override
  void initState() {
    super.initState();

    if (widget.profileData['mpGetOffer'] == 0) {
      selectedOption = 0;
    } else {
      if (widget.profileData['mpOfferScope'] == 1) {
        selectedOption = 1;
      } else {
        selectedOption = 2;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 200,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              selectedOption = 1;
              context.pop(selectedOption);
            },
            child: Text(
              localization.acceptAllProposals,
            style: TextStyle(color: selectedOption == 1 ? CommonColors.red : CommonColors.black),
            ),
          ),
          GestureDetector(
            onTap: () {
              selectedOption = 2;
              context.pop(selectedOption);
            },
            child: Text(
              localization.acceptOnlyPreferredProposals,
              style: TextStyle(color: selectedOption == 2 ? CommonColors.red : CommonColors.black),
            ),
          ),
          GestureDetector(
            onTap: () {
              selectedOption = 0;
              context.pop(selectedOption);
            },
            child: Text(
              localization.declineAllProposals,
              style: TextStyle(color: selectedOption == 0 ? CommonColors.red : CommonColors.black),
            ),
          ),
        ],
      ),
    );
  }
}
