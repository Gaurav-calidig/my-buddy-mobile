# Notification Inbox Module

This module shows important app messages inside the app.

It is a reusable pattern for client projects that need a place for:

- Billing updates
- Feature announcements
- Support replies
- System warnings
- Product or maintenance messages

## What Lives Here

- `data/notification_inbox_store.dart`
- `domain/entities/notification_inbox_item.dart`
- `presentation/bloc/notification_inbox_cubit.dart`
- `presentation/bloc/notification_inbox_state.dart`
- `presentation/screens/notification_inbox_screen.dart`

## What It Does

The inbox:

- Stores messages locally
- Shows unread and important counts
- Supports filters for all, unread, and important
- Lets the user mark messages as read
- Lets the user delete or clear messages
- Can open a related app route when the message has an action route

## How It Fits In The Template

This module is connected to the existing push notification stack.

When a notification is shown or tapped, the app can save it into the inbox so the user can review it later.

## How To Use It In A Client Project

Use it when you want a second place for important communication besides push notifications.

Great for:

- SaaS apps
- Booking apps
- Maintenance and property apps
- Payment-heavy apps
- Apps with support messages or announcements

## How To Turn It On Or Off

### Turn it on

- Keep the route in `lib/core/navigation/app_router.dart`
- Keep the drawer item in `lib/core/widgets/template_feature_drawer.dart`
- Keep the push notification integration if you want notifications to land in the inbox automatically

### Turn it off

- Remove the route
- Remove the drawer item
- Remove the push notification inbox save calls if you do not want persistence
- Delete the module folder if the project does not need an inbox at all

## Important Behaviors

- Messages are stored locally in secure storage
- The screen seeds demo items when the inbox is empty
- Action routes let a message open another app screen
- The module is UI-first, so you can replace local storage with an API later

## Common Client Customizations

- Sync inbox messages from a backend API
- Add server-side read/unread status
- Add message categories for billing, support, and marketing
- Add search and date filters
- Add swipe actions
- Add push notification deep links into the inbox

## Testing Checklist

- Inbox screen opens from the drawer
- Demo seed messages appear on first run
- Mark as read updates the unread count
- Mark all as read works
- Clear inbox removes all messages
- Action routes open the right screen

## Files To Open First

- `lib/features/notification_inbox/presentation/screens/notification_inbox_screen.dart`
- `lib/features/notification_inbox/presentation/bloc/notification_inbox_cubit.dart`
- `lib/features/notification_inbox/data/notification_inbox_store.dart`
- `lib/features/notification_inbox/domain/entities/notification_inbox_item.dart`
