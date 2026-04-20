# Notification Inbox (Implemented)

This document describes the end-to-end notification inbox implementation currently in this repository, including storage, ingestion flow, deduplication, navigation behavior, and test steps.

## Scope

The inbox stores incoming push notification snapshots locally and renders them in a user-visible list screen.

- Screen: `lib/features/auth/presentation/screens/notification_inbox_screen.dart`
- Ingestion: `lib/core/notification/push/push_notification_service.dart`
- Payload-to-navigation mapping: `lib/core/notification/bloc/`
- Storage key: `PrefKeys.notificationInbox` in `lib/core/constants/pref_keys.dart`

## Feature Flags and Preconditions

- `ENABLE_FIREBASE` must be enabled for FCM runtime behavior.
- `ENABLE_PUSH_NOTIFICATIONS` gates listener registration in `main.dart`.
- In current code, both flags default to `true` in `lib/core/config/feature_flags.dart`.

## Startup Wiring

Notification initialization is triggered in `lib/main.dart`:

1. Firebase is initialized safely with `FirebaseInitializer.ensureInitialized()`.
2. `FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler)` is registered.
3. `NotificationService().init(navigationBloc)` is called (when push flag is enabled).

## Ingestion Sources

Inbox entries are added from multiple FCM entry points:

- Foreground message: `FirebaseMessaging.onMessage`
- App opened from background via notification: `FirebaseMessaging.onMessageOpenedApp`
- Terminated state message fetch: `FirebaseMessaging.instance.getInitialMessage()`
- Background isolate delivery: `firebaseMessagingBackgroundHandler`

All of these call `_storeNotificationInboxItem(...)`.

## Inbox Data Model (Stored JSON)

Each item is persisted as a map with:

- `messageId`
- `title`
- `body`
- `data` (full payload data map)
- `source` (`onMessage`, `onMessageOpenedApp`, `getInitialMessage`, `onBackgroundMessage`)
- `sentTime` (if available)
- `receivedAt`
- `signature` (dedupe fingerprint)

## Deduplication Strategy

The service computes `_notificationSignature(message)` from:

- message id
- title
- body
- data
- sentTime

If an existing item with the same signature exists, the new item is skipped.

## Retention Policy

Inbox length is capped to 100 items (`_maxInboxItems`).

- New items are inserted at index 0.
- If list exceeds 100, oldest items are trimmed.

## Local Notification Rendering

When receiving a message:

- If `data['code']` exists: title/body are resolved by `getNotificationData(code)`.
- Otherwise fallback uses `message.notification?.title/body`.

This is applied in both foreground and background message handlers.

## Navigation Behavior

`NotificationNavigationBloc` maps payload `data['type']` to nav states:

- `enquiry` -> `NavigateToEnquiryDetails`
- `paylater` -> `NavigateToPayLaterRequests`
- `maintenance` -> `NavigateToMaintenanceDetails`
- `payment-reminder` -> `NavigateToPayNow`

On local notification tap, payload is decoded and passed to bloc via `SetNavigationFromPayload(data)`.

## Inbox UI Behavior

`NotificationInboxScreen` provides:

- Pull refresh via app bar refresh icon
- Clear all via app bar delete icon
- Empty state (`No notifications yet`)
- Per-item card with:
  - title/body
  - received timestamp
  - source
  - pretty JSON payload block (if data exists)

## Clear-All Behavior

`_clearNotifications()` writes `'[]'` to `PrefKeys.notificationInbox` and updates UI state.

## Testing Checklist

1. Run app with push enabled.
2. Get FCM token from logs (`NotificationService.getFCMToken`).
3. Send test push (data payload recommended).
4. Verify local notification appears.
5. Open notification and verify navigation behavior.
6. Open Notification Inbox screen and confirm entry appears.
7. Send same payload twice and verify dedupe behavior.
8. Use Clear All and confirm list resets.

## Operational Notes

- Push sending is intentionally not implemented on client (`sendNotification` is no-op warning).
- Backend/FCM server should send pushes.
- Inbox is local snapshot storage for debugging/traceability, not a synced server inbox.

## Related Docs

- `lib/core/notification/push/README.md`
- `lib/core/notification/README.md`
