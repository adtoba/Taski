import 'package:flutter/material.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';

class FirstTaskPage extends StatefulWidget {
  const FirstTaskPage({super.key});

  @override
  State<FirstTaskPage> createState() => _FirstTaskPageState();
}

class _FirstTaskPageState extends State<FirstTaskPage> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: Column(
        children: [
          YMargin(10),
          Text(
            "Your First Task",
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: config.sp(25),
            ),
          ),
          YMargin(30),
        ],
      ),
    );
  }
}