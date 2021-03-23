import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProgressLoaderWidget extends StatelessWidget {
  final double width;
  final double height;

  ProgressLoaderWidget({this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 33,
      height: height ?? 33,
      child: CircularProgressIndicator(
        strokeWidth: 1.5,
      ),
    );
  }
}