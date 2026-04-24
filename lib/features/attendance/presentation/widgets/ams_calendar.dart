import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/attendance/domain/entities/attendance_entities.dart';
import 'package:flutter/material.dart';

class AmsCalendar extends StatelessWidget {
  const AmsCalendar({
    required this.month,
    required this.days,
    required this.legend,
    required this.onPrev,
    required this.onNext,
    super.key,
  });

  final DateTime month;
  final List<AmsCalendarDayEntity> days;
  final List<String> legend;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  String _monthLabel(DateTime date) {
    const List<String> names = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${names[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    const List<String> weekdays = <String>['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const Map<String, Color> legendColors = <String, Color>{
      'Approved': Color(0xFF3F7BE0),
      'Pending': Color(0xFFC49C2B),
      'Holiday': Color(0xFFB36A1E),
      'Birthday': Color(0xFFCD4C8D),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.kcDarkCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.kcDarkBorderStrong),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              _NavBtn(icon: Icons.chevron_left, onTap: onPrev),
              const Spacer(),
              Text(_monthLabel(month), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              const Spacer(),
              _NavBtn(icon: Icons.chevron_right, onTap: onNext),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              const Text('Today', style: TextStyle(color: AppColors.kcDarkTextSecondary, fontSize: 12)),
              const SizedBox(width: 10),
              ...legend.map((String item) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: legendColors[item] ?? const Color(0xFF3F7BE0), shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text(item, style: const TextStyle(color: AppColors.kcDarkTextSecondary, fontSize: 11)),
                      ],
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: weekdays
                .map((String day) => Expanded(
                      child: Text(day, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.kcDarkTextSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                    ))
                .toList(growable: false),
          ),
          const SizedBox(height: 8),
          ...List<Widget>.generate((days.length / 7).ceil(), (int week) {
            final int start = week * 7;
            final List<AmsCalendarDayEntity> row = days.skip(start).take(7).toList(growable: false);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: row.map((AmsCalendarDayEntity cell) {
                  final bool showCellContent = cell.isInCurrentMonth;
                  return Expanded(
                    child: Container(
                      height: 74,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      padding: const EdgeInsets.fromLTRB(3, 2, 3, 2),
                      decoration: BoxDecoration(
                        color: cell.isInCurrentMonth ? const Color(0xFF101B35) : const Color(0xFF0D172F),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (showCellContent) ...<Widget>[
                            Text(
                              '${cell.date.day}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            ...cell.events.take(2).map((AmsLeaveEventEntity e) => InkWell(
                                  onTap: () => _showEventDetails(context, e),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 2),
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(color: Color(e.colorHex), borderRadius: BorderRadius.circular(10)),
                                    child: Row(
                                      children: <Widget>[
                                        if (e.type == 'birthday') ...<Widget>[
                                          const Icon(Icons.cake, size: 9, color: Colors.white),
                                          const SizedBox(width: 2),
                                        ],
                                        Expanded(
                                          child: Text(
                                            e.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        if (e.halfLabel != null && e.halfLabel!.isNotEmpty)
                                          Container(
                                            margin: const EdgeInsets.only(left: 3),
                                            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                                            child: Text(e.halfLabel!, style: const TextStyle(color: Colors.white, fontSize: 6.8, fontWeight: FontWeight.w700)),
                                          ),
                                      ],
                                    ),
                                  ),
                                )),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(growable: false),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _showEventDetails(BuildContext context, AmsLeaveEventEntity event) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.kcBackgroundColorDark,
          title: const Text('Event Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Name: ${event.name}', style: const TextStyle(color: AppColors.kcDarkTextPrimary)),
              const SizedBox(height: 8),
              Text('Status: ${event.status.toUpperCase()}', style: const TextStyle(color: AppColors.kcDarkTextPrimary)),
              if (event.halfLabel != null && event.halfLabel!.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text('Leave Half: ${event.halfLabel}', style: const TextStyle(color: AppColors.kcDarkTextPrimary)),
              ],
              const SizedBox(height: 8),
              Text('Reason: ${event.reason}', style: const TextStyle(color: AppColors.kcDarkTextPrimary)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.kcDarkBorderStrong),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}
