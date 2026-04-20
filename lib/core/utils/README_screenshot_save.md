# Screenshot Save / Share

This project includes a utility to capture the current Flutter UI into an image and then save/share it.

## What to use

- Service: `lib/core/utils/screenshot_service.dart`

Key APIs:

- `ScreenshotService.capture()` → `Uint8List?`
- `ScreenshotService.captureAndSave()` → `File?` (temporary directory)
- `ScreenshotService.captureAndShare(...)` → shares via platform dialog
- `ScreenshotService.saveToGallery()` → saves via `gal` and shows a toast

## Setup

1. Ensure the top-level widget tree is wrapped so `ScreenshotService.rootKey` is attached to a `RepaintBoundary`.
2. Call the service method you need.

## Notes

- This captures what Flutter renders inside the app, not arbitrary native views.
- If you also enable screenshot protection (`FLAG_SECURE`), the OS screenshot is blocked on Android, but in-app capture via `RepaintBoundary` still works (use with care).
