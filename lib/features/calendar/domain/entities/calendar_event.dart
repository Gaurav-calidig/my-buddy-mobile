import 'package:flutter/material.dart';

/// Represents a calendar event rendered inside a day cell.
@immutable
class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.startAt,
    this.endAt,
    this.subtitle,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.payload,
  });

  final String id;
  final String title;
  final DateTime startAt;
  final DateTime? endAt;
  final String? subtitle;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Object? payload;
}
