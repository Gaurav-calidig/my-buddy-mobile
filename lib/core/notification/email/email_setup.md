# Email Notification Setup (Flutter + Firebase Extension)

This document explains:

1. Email flow architecture
2. Flutter EmailService implementation
3. GetIt registration
4. Firebase setup steps
5. Important note about Firebase Blaze plan requirement

---

# 1️⃣ Email Flow Architecture

Since we are using the **Firebase Trigger Email Extension**, the flow works like this:

```
Flutter App → Firestore (mail collection) → Firebase Extension → SMTP Provider → Email Delivered
```

The Flutter app does NOT send emails directly.
It only creates a Firestore document.

The Firebase extension listens to that collection and sends the email securely.

---

# 2️⃣ Flutter Email Service (Singleton)

Create file:

```
common/services/email_service.dart
```

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailService {
  EmailService._internal();

  static final EmailService _instance = EmailService._internal();

  factory EmailService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendTextEmail({
    required List<String> to,
    required String subject,
    required String message,
  }) async {
    if (to.isEmpty) {
      throw Exception("Recipient list cannot be empty");
    }

    await _firestore.collection('mail').add({
      "to": to,
      "message": {
        "subject": subject,
        "text": message,
      },
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendHtmlEmail({
    required List<String> to,
    required String subject,
    required String html,
  }) async {
    await _firestore.collection('mail').add({
      "to": to,
      "message": {
        "subject": subject,
        "html": html,
      },
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendTemplateEmail({
    required List<String> to,
    required String templateName,
    required Map<String, dynamic> templateData,
  }) async {
    await _firestore.collection('mail').add({
      "to": to,
      "template": {
        "name": templateName,
        "data": templateData,
      },
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}
```

---

# 3️⃣ Register In GetIt

Create file:

```
common/di/service_locator.dart
```

```dart
import 'package:get_it/get_it.dart';
import '../services/email_service.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<EmailService>(() => EmailService());
}
```

Initialize in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  setupLocator();

  runApp(MyApp());
}
```

Usage anywhere:

```dart
await getIt<EmailService>().sendTextEmail(
  to: ["user@email.com"],
  subject: "Welcome",
  message: "Thanks for joining!",
);
```

---

# 4️⃣ Firebase Setup

## Step 1: Enable Firestore

Firebase Console → Build → Firestore Database → Create Database

Choose:
- Production mode
- Closest region to users

---

## Step 2: Install Trigger Email Extension

Firebase Console → Extensions → Browse → Install "Trigger Email"

Extension ID:

```
firestore-send-email
```

During setup you must configure:

- SMTP Host
- SMTP Port (usually 587)
- SMTP Username
- SMTP Password or API Key
- Default From Address

The default collection should be:

```
mail
```

Keep this unchanged because Flutter writes to `mail`.

---

## Step 3: Firestore Security Rules

Open Firestore → Rules and set:

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /mail/{document} {
      allow create: if request.auth != null;
      allow read, update, delete: if false;
    }
  }
}
```

Publish rules.

---

# 5️⃣ Important: Blaze Plan Requirement ⚠️

Firebase Extensions require the **Blaze (Pay-as-you-go) plan**.

If you are currently on the Spark (free) plan:

- You CANNOT install the Trigger Email extension
- You CANNOT use SMTP-based email sending through extensions

Why?
Because extensions run Cloud Functions, and Cloud Functions require Blaze plan.

---

# 6️⃣ What To Do If You Cannot Upgrade To Blaze

If you cannot upgrade, you have these options:

### Option A (Recommended): Small Backend

Create a small Node.js backend that sends email using:
- SendGrid
- Mailgun
- Amazon SES

Flutter will call your backend API instead of writing to Firestore.

---

### Option B: Use External Email API Directly (NOT Recommended)

Calling email APIs directly from Flutter exposes API keys.
This is unsafe for production.

---

# 7️⃣ Final Recommendation

For production apps:

✔ Use Blaze plan
✔ Use Trigger Email extension
✔ Restrict Firestore rules properly
✔ Do NOT expose SMTP credentials in Flutter

If Blaze plan is not possible, build a lightweight backend email endpoint instead.

---

End of docu