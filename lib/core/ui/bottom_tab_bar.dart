import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class BottomTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const BottomTabBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64 + MediaQuery.of(context).padding.bottom,
      decoration: const BoxDecoration(
        color: AppColors.slatePanel,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TabItem(
            icon: PhosphorIconsRegular.house,
            label: 'Home',
            isSelected: currentIndex == 0,
            onTap: () => onTabSelected(0),
          ),
          _TabItem(
            icon: PhosphorIconsRegular.squaresFour,
            label: 'Zones',
            isSelected: currentIndex == 1,
            onTap: () => onTabSelected(1),
          ),
          _TabItem(
            icon: PhosphorIconsRegular.mapPin,
            label: 'Map',
            isSelected: currentIndex == 2,
            onTap: () => onTabSelected(2),
          ),
          _TabItem(
            icon: PhosphorIconsRegular.user, // user-round fallback
            label: 'Profile',
            isSelected: currentIndex == 3,
            onTap: () => onTabSelected(3),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.electricLime : AppColors.fogSecondary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isSelected)
              Positioned(
                top: 0,
                child: Container(
                  width: 40,
                  height: 2,
                  color: AppColors.electricLime,
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24, color: color),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTypography.label.copyWith(color: color, fontSize: 10), // slight adjustment for tab label
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
