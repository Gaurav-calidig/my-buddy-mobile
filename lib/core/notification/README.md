# Notification Core

Notification-related infrastructure shared by the app.

## Contents

- `bloc/`: notification navigation event/state management.
- `push/`: push notification lifecycle and local notification rendering.
- `email/`: Firebase-backed email dispatch helper.

## Important

- Push sending must be backend-owned; client should only receive and display notifications.
- Keep navigation payload mapping centralized in `bloc/`.

## Detailed Docs

- Notification Inbox implementation: `lib/core/notification/README_notification_inbox.md`
