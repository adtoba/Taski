import 'package:flutter/material.dart';
import 'package:taski/main.dart';

class XMargin extends StatelessWidget {
  const XMargin(this.size, {super.key});

  final double size;
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: config.sw(size),
    );
  }
}


class YMargin extends StatelessWidget {
  const YMargin(this.size, {super.key});

  final double size;
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: config.sh(size),
    );
  }
}