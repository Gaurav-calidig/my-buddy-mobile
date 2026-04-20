# Push Notifications

This folder contains the client-side plumbing for receiving Firebase Cloud Messaging (FCM) pushes and showing them as local notifications.

## Files

- `push_notification_service.dart`
  - `NotificationService`: singleton used to initialize permissions, set up listeners, and show local notifications.
  - Handles the main FCM entry points:
    - Foreground: `FirebaseMessaging.onMessage`
    - Background tap: `notificationTapBackground()`
    - Background/terminated delivery: `firebaseMessagingBackgroundHandler()`
    - Open-from-notification: `FirebaseMessaging.onMessageOpenedApp` + local notification tap callback
  - Expects an optional `NotificationNavigationBloc` to be passed to `init()` so that navigation is driven from a single place.

- `notification_codes_data.dart`
  - `getNotificationData(code, {reminderMsg})`: maps an incoming `code` to a localized `NotificationData` (title/body/locale).
  - Add new notification types by adding new `case` entries to the `switch (code)`.

## Expected FCM payload

This implementation supports two common payload styles:

1) **Data-driven (recommended)**

- Send a `data` payload that includes a `code` key:
  - `code`: string identifier used by `getNotificationData()`
  - Any other keys are preserved and passed as the local notification `payload`

2) **Firebase Console test (fallback)**

- If no `data["code"]` is provided, the service falls back to `message.notification.title/body`.

## Adding a new notification type

1. Choose a new `code` string (example: `maintenance-approved`).
2. Add a new `case` in `lib/core/notification/push/notification_codes_data.dart`.
3. Ensure the backend sends that `code` under the `data` payload key `code`.
4. If the notification should deep-link somewhere, handle the payload in `NotificationNavigationBloc` (see `lib/core/notification/bloc/`).

## Notes / guardrails

- Sending push notifications must be backend-owned (Firebase Admin SDK / server), not the Flutter client.
- Local notification channel id/name are defined in `NotificationService` (`default_channel` / `Notifications`).

## Testing (send a push manually)

You can test end-to-end delivery by sending an FCM HTTP v1 message to a real device token.

# Firebase Push Notification Test (Postman)

This guide explains how to send a **test push notification** to a device using **Firebase Cloud Messaging (FCM) HTTP v1 API** and **Postman**.

---

## 1. Prerequisites

Make sure you have:

* A Firebase project
* Firebase Cloud Messaging enabled
* A Flutter / Android / iOS app connected to Firebase
* Device **FCM token**
* **Google Cloud SDK** installed
* A **Service Account JSON key**

---

## 2. Download Service Account Key

1. Open Firebase Console
2. Go to **Project Settings**
3. Open **Service Accounts** tab
4. Click **Generate New Private Key**
5. Download the JSON file

Example:

```
firebase-adminsdk-xxxxx.json
```

---

## 3. Generate Access Token

Open terminal and run:

```
gcloud auth activate-service-account --key-file="PATH_TO_JSON_FILE"
```

Example:

```
gcloud auth activate-service-account --key-file="C:\Users\Asus\Downloads\firebase-adminsdk.json"
```
t
Generate the access token:

```
gcloud auth print-access-token
```

Example output:

```
ya29.a0AfH6SMBxxxxxxxxxxxxxxxx
```

⚠️ Access tokens expire in about **1 hour**.

---

## 4. Get Device FCM Token

In Flutter:

```dart
FirebaseMessaging.instance.getToken().then((token) {
  print("FCM TOKEN: $token");
});
```

Copy the token from the console.

---

## 5. Send Notification from Postman

### Method

```
POST
```

### URL

```
https://fcm.googleapis.com/v1/projects/PROJECT_ID/messages:send
```

Example:

```
https://fcm.googleapis.com/v1/projects/my-app/messages:send
```

---

### Headers

```
Authorization: Bearer ACCESS_TOKEN
Content-Type: application/json
```

Example:

```
Authorization: Bearer ya29.a0AfH6SMBxxxxxxxx
```

---

### Body (JSON)

```
{
  "message": {
    "token": "DEVICE_FCM_TOKEN",
    "notification": {
      "title": "Test Notification",
      "body": "Hello from Postman"
    },
    "data": {
      "type": "test"
    }
  }
}
```

Replace:

* `PROJECT_ID`
* `ACCESS_TOKEN`
* `DEVICE_FCM_TOKEN`

---

## 6. Expected Response

Successful response:

```
{
  "name": "projects/my-app/messages/0:1700000000000000%abcdef"
}
```

Your device should receive the notification.

---

## 7. Troubleshooting

### 401 UNAUTHENTICATED

Access token expired.

Generate again:

```
gcloud auth print-access-token
```

---

### 404 Project Not Found

Incorrect **Project ID** in the request URL.

---

### Notification Not Showing

Check:

* App installed on device
* Correct device token
* Notification permission granted
* App in background or notification handled manually in foreground

---

## Security Note

⚠️ Never commit the **Service Account JSON** file to GitHub because it contains **private Firebase credentials**.

Add it to `.gitignore`.

Example:

```
service-account.json
firebase-adminsdk*.json
```

---

## Reference

* Firebase Cloud Messaging HTTP v1 API documentation
* Firebase Console
* Google Cloud SDK
