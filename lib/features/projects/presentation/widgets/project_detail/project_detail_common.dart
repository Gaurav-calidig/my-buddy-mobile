import 'package:core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'project_detail_constants.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;

  const StatusBadge({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class TypeBadge extends StatelessWidget {
  final String type;
  const TypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final resolvedType = (type.toLowerCase() == 'file' || type.toLowerCase() == 'document') ? 'Document' : type;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = ProjectTheme.getAccent(context);

    Color badgeColor;
    Color badgeBg;

    switch (resolvedType.toLowerCase()) {
      case 'url':
        badgeColor = accentColor;
        badgeBg = isDark ? const Color(0xFF0D2340) : accentColor.withValues(alpha: 0.1);
        break;
      case 'credential/secret':
        badgeColor = isDark ? const Color(0xFFAB8BF5) : Colors.deepPurple;
        badgeBg = isDark ? const Color(0xFF1A1040) : const Color(0xFFAB8BF5).withValues(alpha: 0.1);
        break;
      case 'document':
        badgeColor = isDark ? Colors.tealAccent : Colors.teal;
        badgeBg = isDark ? const Color(0xFF0D2D2A) : Colors.teal.withValues(alpha: 0.1);
        break;
      default: // e.g. Note
        badgeColor = isDark ? Colors.orangeAccent : Colors.orange;
        badgeBg = isDark ? const Color(0xFF2D1F0D) : Colors.orange.withValues(alpha: 0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        resolvedType == 'url' ? 'URL' : resolvedType,
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class EnvBadge extends StatelessWidget {
  final String env;
  const EnvBadge({super.key, required this.env});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = ProjectTheme.getAccent(context);
    
    switch (env.toLowerCase()) {
      case 'production':
        color = isDark ? ProjectTheme.kSuccess : const Color(0xFF059669);
        bg = isDark ? ProjectTheme.kSuccessBg : const Color(0xFFD1FAE5);
        break;
      case 'staging':
        color = isDark ? ProjectTheme.kWarning : const Color(0xFFD97706);
        bg = isDark ? ProjectTheme.kWarningBg : const Color(0xFFFEF3C7);
        break;
      case 'dev':
      case 'development':
        color = accentColor;
        bg = isDark ? const Color(0xFF0A1E42) : accentColor.withValues(alpha: 0.1);
        break;
      default:
        color = ProjectTheme.getTextSecondary(context);
        bg = ProjectTheme.getPanelLight(context);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        env,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class IconAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  const IconAction({super.key, required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(icon, color: color ?? ProjectTheme.getTextMuted(context), size: 20),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  final String message;
  const EmptyView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, color: ProjectTheme.getTextMuted(context), size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: ProjectTheme.getTextMuted(context), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  const ErrorView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: kDanger, size: 48),
            const SizedBox(height: 12),
            Text(
              'Something went wrong',
              style: TextStyle(
                color: ProjectTheme.getTextPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: TextStyle(color: ProjectTheme.getTextMuted(context), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const SearchField({super.key, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final textMuted = ProjectTheme.getTextMuted(context);
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: ProjectTheme.getPanelLight(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ProjectTheme.getBorder(context)),
      ),
      child: TextField(
      onChanged: onChanged,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(
        color: ProjectTheme.getTextPrimary(context),
        fontSize: 13,
        height: 1.2,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        isDense: true,

        prefixIcon: Icon(
          Icons.search,
          color: textMuted,
          size: 16,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),

        hintText: hint,
        hintStyle: TextStyle(
          color: textMuted,
          fontSize: 13,
          height: 1.2,
        ),

        // Remove vertical padding
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
      ),
    ),
    );
  }
}

class EnvDropdown extends StatelessWidget {
  final String selected;
  final List<String> options;
  final ValueChanged<String> onChanged;
  const EnvDropdown({
    super.key,
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: ProjectTheme.getPanelLight(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ProjectTheme.getBorder(context)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          dropdownColor: isDark ? const Color(0xFF172340) : AppColors.kcLightCard,
          style: TextStyle(color: ProjectTheme.getTextPrimary(context), fontSize: 12),
          icon: Icon(Icons.keyboard_arrow_down, color: ProjectTheme.getTextMuted(context), size: 16),
          items: options
              .map(
                (o) => DropdownMenuItem(
                  value: o,
                  child: Text(o),
                ),
              )
              .toList(),
          onChanged: (v) => v != null ? onChanged(v) : null,
        ),
      ),
    );
  }
}

class AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const AddButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: ProjectTheme.getAccent(context),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
