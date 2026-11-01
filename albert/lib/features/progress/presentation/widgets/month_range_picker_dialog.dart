import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:flutter/material.dart';

/// Shows a single-month calendar range picker with left/right month navigation.
Future<DateTimeRange?> showMonthRangePicker({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTimeRange? initialDateRange,
}) {
  return showDialog<DateTimeRange>(
    context: context,
    builder: (_) => _MonthRangePickerDialog(
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: initialDateRange,
    ),
  );
}

class _MonthRangePickerDialog extends StatefulWidget {
  const _MonthRangePickerDialog({
    required this.firstDate,
    required this.lastDate,
    this.initialDateRange,
  });

  final DateTime firstDate;
  final DateTime lastDate;
  final DateTimeRange? initialDateRange;

  @override
  State<_MonthRangePickerDialog> createState() =>
      _MonthRangePickerDialogState();
}

class _MonthRangePickerDialogState extends State<_MonthRangePickerDialog> {
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const _weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  late DateTime _visibleMonth;
  DateTime? _start;
  DateTime? _end;

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    _start = widget.initialDateRange != null
        ? _dateOnly(widget.initialDateRange!.start)
        : null;
    _end = widget.initialDateRange != null
        ? _dateOnly(widget.initialDateRange!.end)
        : null;
    final anchor = _end ?? widget.lastDate;
    _visibleMonth = DateTime(anchor.year, anchor.month);
  }

  bool get _canGoPrev => _visibleMonth
      .isAfter(DateTime(widget.firstDate.year, widget.firstDate.month));
  bool get _canGoNext => _visibleMonth
      .isBefore(DateTime(widget.lastDate.year, widget.lastDate.month));

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth =
          DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  void _onDayTap(DateTime day) {
    setState(() {
      if (_start == null || _end != null) {
        _start = day;
        _end = null;
      } else if (day.isBefore(_start!)) {
        _start = day;
      } else {
        _end = day;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leading = DateTime(_visibleMonth.year, _visibleMonth.month, 1)
            .weekday %
        7; // Sunday-first
    final first = _dateOnly(widget.firstDate);
    final last = _dateOnly(widget.lastDate);

    final cells = <Widget>[
      for (int i = 0; i < leading; i++) const SizedBox.shrink(),
      for (int d = 1; d <= daysInMonth; d++)
        _buildDay(DateTime(_visibleMonth.year, _visibleMonth.month, d), first,
            last, textColor),
    ];

    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: arrows + centered year/month
            Row(
              children: [
                IconButton(
                  onPressed: _canGoPrev ? () => _changeMonth(-1) : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                  color: AppColors.primary100,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${_visibleMonth.year}',
                        style: const TextStyle(
                          color: AppColors.neutral60,
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _months[_visibleMonth.month - 1],
                        style: TextStyle(
                          color: textColor,
                          fontFamily: 'Montserrat',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _canGoNext ? () => _changeMonth(1) : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                  color: AppColors.primary100,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: _weekdays
                  .map((w) => Expanded(
                        child: Center(
                          child: Text(w,
                              style: const TextStyle(
                                color: AppColors.neutral60,
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 4,
              children: cells,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.neutral60),
                  child: Text(
                      MaterialLocalizations.of(context).cancelButtonLabel),
                ),
                TextButton(
                  onPressed: _start == null
                      ? null
                      : () => Navigator.of(context).pop(
                            DateTimeRange(start: _start!, end: _end ?? _start!),
                          ),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary100),
                  child: Text(MaterialLocalizations.of(context).okButtonLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDay(
      DateTime day, DateTime first, DateTime last, Color textColor) {
    final enabled = !day.isBefore(first) && !day.isAfter(last);
    final isStart = _start != null && day == _start;
    final isEnd = _end != null && day == _end;
    final isEdge = isStart || isEnd;
    final inRange = _start != null &&
        _end != null &&
        day.isAfter(_start!) &&
        day.isBefore(_end!);
    final hasRange = _start != null && _end != null && _start != _end;
    final rangeColor = AppColors.primary100.withValues(alpha: 0.2);

    // Band behind the day connecting the range.
    BoxDecoration? band;
    if (inRange) {
      band = BoxDecoration(color: rangeColor);
    } else if (hasRange && isStart) {
      band = BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, rangeColor],
          stops: const [0.5, 0.5],
        ),
      );
    } else if (hasRange && isEnd) {
      band = BoxDecoration(
        gradient: LinearGradient(
          colors: [rangeColor, Colors.transparent],
          stops: const [0.5, 0.5],
        ),
      );
    }

    return GestureDetector(
      onTap: enabled ? () => _onDayTap(day) : null,
      child: Container(
        decoration: band,
        alignment: Alignment.center,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: isEdge
              ? const BoxDecoration(
                  color: AppColors.primary100, shape: BoxShape.circle)
              : null,
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: isEdge
                  ? Colors.black
                  : enabled
                      ? textColor
                      : AppColors.neutral60.withValues(alpha: 0.4),
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: isEdge || inRange ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
