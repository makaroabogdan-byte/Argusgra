import 'package:flutter/material.dart';
import '../../core/widgets/responsive_scaffold.dart';

class HomeShell extends StatelessWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) => ResponsiveScaffold(child: child);
}
