# Chat Feature

Firebase-backed real-time chat using Firestore.

## Enable

Use the following flags when running the app:

- `--dart-define=ENABLE_FIREBASE=true`
- `--dart-define=ENABLE_CHAT=true`

If you do not use the auth feature, the chat module signs in anonymously. Make sure Anonymous auth is enabled in your Firebase project.

## WebSocket Backend

Set the chat backend in `.env`:

- `CHAT_BACKEND=websocket`
- `CHAT_WS_URL=wss://your-server.example.com/chat`

The WebSocket client uses a simple JSON protocol. These are the minimum event
types expected by the app:

Client → Server:

- `{"type":"identify","user":{"id":"uid","name":"Name","photoUrl":"https://..."}}`
- `{"type":"subscribe","topic":"rooms"}`
- `{"type":"subscribe","topic":"room_states"}`
- `{"type":"subscribe","topic":"messages","roomId":"roomId"}`
- `{"type":"subscribe","topic":"presence","roomId":"roomId"}`
- `{"type":"subscribe","topic":"typing","roomId":"roomId"}`
- `{"type":"create_room","name":"Room name","requestId":"1"}`
- `{"type":"send_message","roomId":"roomId","text":"Hi","attachments":[]}`
- `{"type":"edit_message","roomId":"roomId","messageId":"id","text":"Updated"}`
- `{"type":"delete_message_everyone","roomId":"roomId","messageId":"id"}`
- `{"type":"delete_message_me","roomId":"roomId","messageId":"id"}`
- `{"type":"clear_room","roomId":"roomId"}`
- `{"type":"set_presence","roomId":"roomId","isOnline":true,"user":{"id":"uid"}}`
- `{"type":"set_typing","roomId":"roomId","isTyping":true,"user":{"id":"uid"}}`

Server → Client:

- `{"type":"rooms","rooms":[...]}`
- `{"type":"room","room":{...}}`
- `{"type":"room_states","states":[...]}`
- `{"type":"room_state","state":{...}}`
- `{"type":"messages","roomId":"roomId","messages":[...]}`
- `{"type":"message","roomId":"roomId","message":{...}}`
- `{"type":"presence","roomId":"roomId","presence":[...]}`
- `{"type":"presence_update","roomId":"roomId","presence":{...}}`
- `{"type":"typing","roomId":"roomId","typing":[...]}`
- `{"type":"typing_update","roomId":"roomId","typing":{...}}`
- `{"type":"created_room","requestId":"1","roomId":"roomId","room":{...}}`
- `{"type":"error","requestId":"1","message":"reason"}`

## Local Mock Server

You can run a local mock WebSocket server for testing:

```
dart run tool/chat_ws_mock.dart
```

For iOS Simulator, use:

- `CHAT_WS_URL=ws://localhost:8080/chat`

## Firestore Structure

- `chat_rooms/{roomId}`
  - `name` (string)
  - `createdAt` (timestamp)
  - `updatedAt` (timestamp)
  - `lastMessage` (string)
  - `lastSenderId` (string)
  - `lastSenderName` (string)
  - `lastMessageId` (string)
- `chat_rooms/{roomId}/messages/{messageId}`
  - `text` (string)
  - `attachments` (array of objects)
    - `url` (string)
    - `name` (string)
    - `sizeBytes` (number)
    - `mimeType` (string)
    - `type` (string: image|video|audio|document|other)
    - `thumbnailUrl` (string, optional)
  - `senderId` (string)
  - `senderName` (string)
  - `createdAt` (timestamp)
  - `editedAt` (timestamp, nullable)
  - `isDeleted` (bool)
  - `deletedFor` (array of uid strings)
  - `deletedAt` (timestamp, nullable)
  - `deletedBy` (string, optional)
- `chat_rooms/{roomId}/presence/{uid}`
  - `name` (string)
  - `photoUrl` (string, optional)
  - `isOnline` (bool)
  - `lastSeen` (timestamp)
- `chat_rooms/{roomId}/typing/{uid}`
  - `name` (string)
  - `photoUrl` (string, optional)
  - `isTyping` (bool)
  - `updatedAt` (timestamp)
- `chat_users/{uid}/room_states/{roomId}`
  - `clearedAt` (timestamp)

## Example Security Rules

Tighten these for production:

```
match /chat_rooms/{roomId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null;
  allow update: if request.auth != null;
  allow delete: if false;

  match /messages/{messageId} {
    allow read: if request.auth != null;
    allow create: if request.auth != null;

    // Allow owner to edit/delete for everyone or allow users to add themselves
    // to deletedFor (delete for me).
    allow update: if request.auth != null
      && (
        request.auth.uid == resource.data.senderId
        || (
          request.resource.data.deletedFor.size() == resource.data.deletedFor.size() + 1
          && request.resource.data.deletedFor.hasAll(resource.data.deletedFor)
          && request.resource.data.deletedFor.hasAny([request.auth.uid])
        )
      );

    // Disallow hard deletes; use soft delete flags.
    allow delete: if false;
  }

  match /presence/{uid} {
    allow read: if request.auth != null;
    allow create, update: if request.auth != null && request.auth.uid == uid;
    allow delete: if false;
  }

  match /typing/{uid} {
    allow read: if request.auth != null;
    allow create, update: if request.auth != null && request.auth.uid == uid;
    allow delete: if false;
  }
}

match /chat_users/{uid}/room_states/{roomId} {
  allow read: if request.auth != null && request.auth.uid == uid;
  allow create, update: if request.auth != null && request.auth.uid == uid;
  allow delete: if false;
}
```

## Storage Rules (Firebase Storage)

```
match /chat_attachments/{roomId}/{fileName} {
  allow read: if request.auth != null;
  allow write: if request.auth != null;
}
```
