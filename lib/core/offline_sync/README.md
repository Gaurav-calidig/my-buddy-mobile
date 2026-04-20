# Offline Sync Helpers

This folder contains the shared helpers that keep API calls live even when the device temporarily loses connectivity:

- `offline_api_request.dart` defines the serializable payload that we persist when a request fails (it captures method, endpoint, body, headers, etc.).
- `offline_api_sync_service.dart` stores those requests in secure storage, listens to `Connectivity` changes, and replays the queue once the device regains a network connection. It also exposes `pendingCount`, `queueRequest`, and `flushPendingRequests` so other parts of the app can observe or drive the queue.

**How it fits together**
1. `ApiService` attaches its `_replayRequest` executor to `OfflineApiSyncService` so all HTTP failures can be persisted and retried later (`_performRequest` uses `queueRequest`).
2. The queue only replays when Connectivity reports at least one network interface, and each replayed request is removed from storage unless it throws again.
3. The `OfflineApiSyncTestScreen` and any future offline-first UIs CRUD the queue via the service helpers for diagnostics and manual retries.

Feel free to add more helpers (e.g., deduping payloads or limiting retries) inside this folder when the offline sync story evolves.
