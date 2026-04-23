import 'package:flutter/material.dart';
import 'package:core/core/theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showDrawer;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showDrawer = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.kcBackgroundColorDark,
      foregroundColor: AppColors.kcSecondaryColorLight,
      leading: showDrawer
          ? Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                );
              },
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Outfit',
        ),
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Theme.of(context).dividerTheme.color ??
              Colors.grey.withValues(alpha: 0.2),
          height: 1.0,
        ),
      ),
      actions: actions ??
          [
            // IconButton(
            //   icon: const Icon(Icons.notifications_none_rounded),
            //   onPressed: () {
            //     // Notification action
            //   },
            // ),
            // const SizedBox(width: 8),
            // CircleAvatar(
            //   radius: 15,
            //   backgroundColor:
            //       Theme.of(context).primaryColor.withValues(alpha: 0.15),
            //   child: Text(
            //     'G', // Placeholder initials
            //     style: TextStyle(
            //       color: Theme.of(context).primaryColor,
            //       fontSize: 13,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            // const SizedBox(width: 16),
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1.0);
}
