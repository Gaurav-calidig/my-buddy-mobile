import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/attendance/domain/entities/attendance_entities.dart';
import 'package:core/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:flutter/material.dart';

class AmsCalendar extends StatefulWidget {
  const AmsCalendar({
    required this.month,
    required this.days,
    required this.legend,
    required this.isLoading,
    required this.viewMode,
    required this.onPrev,
    required this.onNext,
    required this.onViewModeChanged,
    required this.onToday,
    super.key,
  });

  final DateTime month;
  final List<AmsCalendarDayEntity> days;
  final List<String> legend;
  final bool isLoading;
  final AmsCalendarViewMode viewMode;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<AmsCalendarViewMode> onViewModeChanged;
  final VoidCallback onToday;

  @override
  State<AmsCalendar> createState() => _AmsCalendarState();
}

class _AmsCalendarState extends State<AmsCalendar> {
  String _monthLabel(DateTime date) {
    const List<String> names = <String>[
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${names[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.kcDarkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.kcDarkBorderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildHeader(),
          const SizedBox(height: 12),
          _buildLegend(),
          const SizedBox(height: 16),
          if (widget.isLoading)
            const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            )
          else
          if (widget.viewMode == AmsCalendarViewMode.monthly)
            _buildMonthlyView()
          else
            _buildGridView(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _NavBtn(icon: Icons.chevron_left, onTap: widget.onPrev),
          const SizedBox(width: 8),
          Text(
            _monthLabel(widget.month),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(width: 8),
          _NavBtn(icon: Icons.chevron_right, onTap: widget.onNext),
          const SizedBox(width: 12),
          InkWell(
            onTap: widget.onToday,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.kcDarkBorderStrong),
              ),
              child: const Text('Today', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          _ViewToggle(
            currentMode: widget.viewMode,
            onChanged: widget.onViewModeChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    const Map<String, Color> legendColors = <String, Color>{
      'Approved': Color(0xFF3F7BE0),
      'Pending': Color(0xFFC49C2B),
      'Holiday': Color(0xFFB36A1E),
      'Birthday': Color(0xFFCD4C8D),
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          const Text('Today', style: TextStyle(color: AppColors.kcDarkTextSecondary, fontSize: 12)),
          const SizedBox(width: 12),
          ...widget.legend.map((String item) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: legendColors[item] ?? const Color(0xFF3F7BE0),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(item, style: const TextStyle(color: AppColors.kcDarkTextSecondary, fontSize: 11)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMonthlyView() {
    const List<String> weekdays = <String>['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Column(
      children: <Widget>[
        Row(
          children: weekdays
              .map((String day) => Expanded(
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.kcDarkTextSecondary, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ))
              .toList(growable: false),
        ),
        const SizedBox(height: 8),
        ...List<Widget>.generate((widget.days.length / 7).ceil(), (int week) {
          final int start = week * 7;
          final List<AmsCalendarDayEntity> row = widget.days.skip(start).take(7).toList(growable: false);
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: row.map((AmsCalendarDayEntity cell) => Expanded(child: _buildMonthlyCell(cell))).toList(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMonthlyCell(AmsCalendarDayEntity cell) {
    final bool isCurrentMonth = cell.isInCurrentMonth;
    return Container(
      margin: const EdgeInsets.all(1),
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 6), // Increased bottom padding
      constraints: const BoxConstraints(minHeight: 65), // Added minHeight for better structure
      decoration: BoxDecoration(
        color: isCurrentMonth ? const Color(0xFF101B35) : const Color(0xFF0D172F),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _isToday(cell.date) ? AppColors.kcPrimaryColor.withValues(alpha: 0.5) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '${cell.date.day}',
            style: TextStyle(
              color: isCurrentMonth ? Colors.white : Colors.white24,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          if (isCurrentMonth)
            ...cell.events.map((AmsLeaveEventEntity e) => _buildEventPill(e)),
        ],
      ),
    );
  }

  Widget _buildEventPill(AmsLeaveEventEntity e) {
    return InkWell(
      onTap: () => _showEventDetails(context, e),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        decoration: BoxDecoration(
          color: Color(e.colorHex),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Added to prevent pushing out
          children: <Widget>[
            if (e.type == 'birthday') ...<Widget>[
              const Icon(Icons.cake, size: 9, color: Colors.white),
              const SizedBox(width: 2),
            ],
            Flexible( // Changed from Expanded to Flexible
              child: Text(
                e.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600),
              ),
            ),
            if (e.halfLabel != null && e.halfLabel!.isNotEmpty)
              Flexible( // Added Flexible for label too
                flex: 0,
                child: Container(
                  margin: const EdgeInsets.only(left: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0.5),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    e.halfLabel!,
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                    style: const TextStyle(color: Colors.white, fontSize: 6, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    // Group events by member name
    final Map<String, Map<int, AmsLeaveEventEntity>> memberEvents = {};
    for (final day in widget.days) {
      if (!day.isInCurrentMonth) continue;
      for (final event in day.events) {
        if (event.type != 'leave') continue;
        final name = event.name;
        memberEvents[name] ??= {};
        memberEvents[name]![day.date.day] = event;
      }
    }

    final List<String> members = memberEvents.keys.toList()..sort();
    final int daysInMonth = widget.days.where((d) => d.isInCurrentMonth).length;
    final List<int> dayNumbers = List.generate(daysInMonth, (i) => i + 1);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed Column (Member names)
        Column(
          children: [
            // Header Corner
            Container(
              width: 100,
              height: 35,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.kcDarkBorderStrong)),
              ),
              child: const Text('Member', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            // Member list
            ...members.map((member) => Container(
              width: 100,
              height: 35,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF1B253D))),
              ),
              child: Text(
                member,
                style: const TextStyle(color: Colors.white, fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            )),
          ],
        ),
        // Scrollable Grid Part (Day headers + Cells)
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day Numbers Header Row
                Row(
                  children: dayNumbers.map((d) {
                    final date = DateTime(widget.month.year, widget.month.month, d);
                    final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
                    return Container(
                      width: 30,
                      height: 35,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: const Border(bottom: BorderSide(color: AppColors.kcDarkBorderStrong)),
                        color: isWeekend ? Colors.white.withValues(alpha: 0.05) : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_weekdayInitial(date.weekday), style: const TextStyle(color: AppColors.kcDarkTextSecondary, fontSize: 9)),
                          Text('$d', style: TextStyle(color: _isToday(date) ? AppColors.kcPrimaryColor : Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                // Data Rows
                ...members.map((member) => Row(
                  children: dayNumbers.map((d) {
                    final event = memberEvents[member]?[d];
                    final date = DateTime(widget.month.year, widget.month.month, d);
                    final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
                    
                    return Container(
                      width: 30,
                      height: 35,
                      decoration: BoxDecoration(
                        border: const Border(
                          bottom: BorderSide(color: Color(0xFF1B253D)),
                          right: BorderSide(color: Color(0xFF1B253D)),
                        ),
                        color: isWeekend ? Colors.white.withValues(alpha: 0.05) : null,
                      ),
                      child: event != null
                          ? Center(
                              child: InkWell(
                                onTap: () => _showEventDetails(context, event),
                                child: Container(
                                  width: 24,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: Color(event.colorHex),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: event.halfLabel != null
                                      ? const Center(child: Text('1/2', style: TextStyle(color: Colors.white, fontSize: 8)))
                                      : null,
                                ),
                              ),
                            )
                          : null,
                    );
                  }).toList(),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _weekdayInitial(int weekday) {
    return ['M', 'T', 'W', 'T', 'F', 'S', 'S'][weekday - 1];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Future<void> _showEventDetails(BuildContext context, AmsLeaveEventEntity event) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.kcBackgroundColorDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(color: Color(event.colorHex), borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 12),
              const Text('Event Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _detailRow('Member', event.name),
              _detailRow('Status', event.status.toUpperCase()),
              if (event.halfLabel != null && event.halfLabel!.isNotEmpty)
                _detailRow('Leave Half', event.halfLabel!),
              _detailRow('Reason', event.reason),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close', style: TextStyle(color: AppColors.kcPrimaryColor)),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.kcDarkTextSecondary, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.kcDarkBorderStrong),
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.currentMode, required this.onChanged});
  final AmsCalendarViewMode currentMode;
  final ValueChanged<AmsCalendarViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFF0D172F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.kcDarkBorderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleBtn(Icons.grid_view_rounded, 'Monthly', AmsCalendarViewMode.monthly),
          _toggleBtn(Icons.view_module_rounded, 'Grid', AmsCalendarViewMode.grid),
        ],
      ),
    );
  }

  Widget _toggleBtn(IconData icon, String label, AmsCalendarViewMode mode) {
    final bool active = currentMode == mode;
    return GestureDetector(
      onTap: () => onChanged(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.kcPrimaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: active ? Colors.white : AppColors.kcDarkTextSecondary),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: active ? Colors.white : AppColors.kcDarkTextSecondary, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
