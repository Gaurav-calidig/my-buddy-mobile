import 'package:flutter/material.dart';

class BottomNavBarItem {
	final IconData icon;
	final String label;

	BottomNavBarItem({required this.icon, required this.label});
}

class BottomNavBar extends StatelessWidget {
	final List<BottomNavBarItem> items;
	final int currentIndex;
	final ValueChanged<int> onTap;
	final Color? selectedColor;
	final Color? unselectedColor;
	final Color? backgroundColor;

	const BottomNavBar({
		super.key,
		required this.items,
		required this.currentIndex,
		required this.onTap,
		this.selectedColor,
		this.unselectedColor,
		this.backgroundColor,
	});

	@override
	Widget build(BuildContext context) {
			return Container(
				color: backgroundColor ?? Theme.of(context).colorScheme.surface,
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceAround,
				children: List.generate(items.length, (index) {
					final item = items[index];
					final isSelected = index == currentIndex;
					return Expanded(
						child: InkWell(
							onTap: () => onTap(index),
							child: Padding(
								padding: const EdgeInsets.symmetric(vertical: 8.0),
								child: Column(
									mainAxisSize: MainAxisSize.min,
									children: [
										Icon(
											item.icon,
											color: isSelected
													? (selectedColor ?? Theme.of(context).primaryColor)
													: (unselectedColor ?? Colors.grey),
										),
										Text(
											item.label,
											style: TextStyle(
												color: isSelected
														? (selectedColor ?? Theme.of(context).primaryColor)
														: (unselectedColor ?? Colors.grey),
												fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
											),
										),
									],
								),
							),
						),
					);
				}),
			),
		);
	}
}
