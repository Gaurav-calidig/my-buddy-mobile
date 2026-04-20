# Splash Feature

Initial app entry flow and first-route decision logic.

## Responsibilities

- Startup loading UI.
- Emit initial navigation intent.
- Integrate push-driven navigation state when available.

## Notes

- Keep splash logic minimal and deterministic.
- Avoid business-heavy decisions here; delegate to feature/domain services when needed.

## Detailed Docs

- Force update implementation: `lib/features/splash/README_force_update.md`
