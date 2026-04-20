import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final List<Widget> menuItems;
  final Widget? header;
  final Color? backgroundColor;

  const AppDrawer({
    super.key,
    required this.menuItems,
    this.header,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: backgroundColor ?? Colors.white,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ...?(header == null ? null : [header!]),
            ...menuItems,
          ],
        ),
      ),
    );
  }
}
