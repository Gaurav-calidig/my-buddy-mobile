

import '../../utils/shared_pref.dart';

/// Retrieves localized notification data based on notification code.
/// 
/// Maps notification codes to appropriate titles and messages in the user's
/// preferred language (English or Arabic). Handles various notification types
/// including inquiries, maintenance requests, pay later requests, and reminders.
Future<NotificationData> getNotificationData(String code,{String? reminderMsg}) async {
  final prefs = SharedPref();
  final localeCode = await prefs.read("en") ?? 'en';

  final isArabic = localeCode == 'ar';

  switch (code) {
    case 'inquiry-create':
      return NotificationData(
        title: isArabic ? 'استفسار جديد' : 'New Inquiry',
        body: isArabic
            ? 'تم إنشاء استفسار جديد.'
            : 'A new inquiry has been created.',
        locale: isArabic? 'ar' : 'en',
      );


    default:
      return NotificationData(
        title: isArabic ? 'إشعار' : 'Notification',
        body: isArabic ? 'لديك إشعار جديد.' : 'You have a new notification.',
        locale: isArabic? 'ar' : 'en',
      );
  }
}

/// Data class for notification content in multiple languages.
/// 
/// Contains the notification title, body message, and locale information
/// for proper display in the user's preferred language.
class NotificationData {
  NotificationData({required this.title, required this.body, required this.locale});
  
  /// The notification title text
  String title;
  
  /// The notification body message
  String body;
  
  /// The locale code for the notification ('en' or 'ar')
  String locale;
}
