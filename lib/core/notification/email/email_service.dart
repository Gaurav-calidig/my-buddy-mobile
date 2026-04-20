import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core/constants/firestore_constants.dart';

class EmailService {
  EmailService._internal();

  static final EmailService _instance = EmailService._internal();

  factory EmailService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Send simple text email
  Future<void> sendTextEmail({
    required List<String> to,
    required String subject,
    required String message,
  }) async {
    await _firestore.collection(FirestoreCollections.mail).add({
      FirestoreMailFields.to: to,
      FirestoreMailFields.message: {
        FirestoreMailMessageFields.subject: subject,
        FirestoreMailMessageFields.text: message,
      },
      FirestoreMailFields.createdAt: FieldValue.serverTimestamp(),
    });
  }

  /// Send HTML email
  Future<void> sendHtmlEmail({
    required List<String> to,
    required String subject,
    required String html,
  }) async {
    await _firestore.collection(FirestoreCollections.mail).add({
      FirestoreMailFields.to: to,
      FirestoreMailFields.message: {
        FirestoreMailMessageFields.subject: subject,
        FirestoreMailMessageFields.html: html,
      },
      FirestoreMailFields.createdAt: FieldValue.serverTimestamp(),
    });
  }

  /// Send Template-based email
  Future<void> sendTemplateEmail({
    required List<String> to,
    required String templateName,
    required Map<String, dynamic> templateData,
  }) async {
    await _firestore.collection(FirestoreCollections.mail).add({
      FirestoreMailFields.to: to,
      FirestoreMailFields.template: {
        FirestoreMailTemplateFields.name: templateName,
        FirestoreMailTemplateFields.data: templateData,
      },
      FirestoreMailFields.createdAt: FieldValue.serverTimestamp(),
    });
  }
}
