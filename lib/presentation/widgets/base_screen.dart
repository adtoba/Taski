import 'package:flutter/material.dart';
import 'package:taski/main.dart';
import 'package:taski/presentation/widgets/dual_input_widget.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key, required this.child});

  final Widget child;

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: widget.child),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.all(config.sw(20)),
                child: DualInputWidget(),
              ),
            ),
          ),
        ],
      )
    );
  }
}