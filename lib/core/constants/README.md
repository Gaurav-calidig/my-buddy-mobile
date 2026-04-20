# Core Constants

Shared constants used across the app (strings, numbers, default values, etc.).

## Responsibilities

- Store app-wide constant values in one place.
- Avoid feature-specific constants here (keep them inside their feature).
- Keep Firestore schema constants grouped by collection (for example `FirestoreUserFields`, `FirestoreWebRtcRoomFields`) instead of a flat field list.
