# WhisperLog Overlay Integration Plan

Status: In Progress (Phase 1 complete, Phase 2 partial complete)
Date: 2026-04-05

## Goal

Unify overlay and main-app services with a coordinator-based architecture that supports robust lifecycle handling, synchronized preferences, and event-driven communication.

## Phase 1: Foundation (Implemented)

### Objectives
- Establish communication infrastructure.
- Create proxy-friendly service contracts.
- Add lifecycle coordinator and overlay orchestrator.

### Delivered
- Added `OverlayCommunicationService` with MethodChannel/EventChannel support and in-process fallback handlers.
- Added overlay event protocol (`OverlayEvent`, `OverlayEventType`).
- Added persistent overlay config model and store (`OverlayConfig`, `OverlayV1Preferences`).
- Added `OverlayCommandRouter` for command registration and note-capture bridge (`overlay.capture.ingest`).
- Added `OverlayCoordinator` for:
  - permission flow
  - show/hide and restore behavior
  - position persistence and reset
  - theme/config event broadcasts
- Added `AppLifecycleCoordinator` and startup wiring.
- Added settings controls for overlay enable/disable and position reset.

### Verification Checklist
- [x] MethodChannel + EventChannel abstraction exists
- [x] Command routing exists with local fallback
- [x] Overlay preferences persisted (position/size/opacity/snap/visible/mode)
- [x] Lifecycle observer connected
- [x] Overlay controls exposed in settings

## Phase 2: State Synchronization (Next)

### Objectives
- Real-time sync of theme and config between main app and overlay isolate.
- Debounced preference updates.
- Note-capture confirmation roundtrip.

### Planned Tasks
- Add event acknowledgements for `NoteCaptured`.
- Add bidirectional config sync with conflict policy (last-write-wins).
- Add theme hydration in overlay entrypoint.

### Implemented Now
- Added coordinator subscription to overlay communication events.
- Added bidirectional config sync handling for `configUpdated` and `positionChanged` events.
- Added debounced persistence for rapid position updates (SharedPreferences + user doc mirror).
- Added richer overlay settings controls: mode, size, opacity, snap-to-edge.
- Added `noteCaptureAck` event handling so overlay-side `noteCaptured` events receive save acknowledgements from main app.

## Phase 3: Performance Optimization (Next)

### Objectives
- Reduce communication overhead and battery impact.

### Planned Tasks
- Batch high-frequency drag events at frame boundaries (~16ms).
- Introduce compact payload encoding for high-volume events.
- Add communication latency metrics and memory tracking.

## Phase 4: Advanced UX (In Progress)

### Objectives
- Rich interactions and accessibility.

### Planned Tasks
- Quick actions menu.
- Gesture controls (double-tap/swipe/pinch).
- Accessibility pass (TalkBack labels, contrast, keyboard flow).
- UI Redesigns (mesh gradient, colour leak accents).

### Implemented Now
- Added double-tap gesture to in-app bubble to open quick note bottom sheet editor (`QuickNoteEditor.dart`).
- Added system UI redesigns for home screen, folder screen, search screen, and thought canvas.

## Phase 4A: Native Android Service Overlay (Implemented)

### Objectives
- Provide system-level overlay bubble visible over other apps and home screen.

### Implemented Now
- Added `OverlayForegroundService.kt` to draw a `WindowManager` bubble.
- Added `MethodChannel` bridge in `MainActivity.kt` and `OverlayNotifier.dart` to support commands.
- Tying Settings switch to the native `ForegroundService`.
- Supporting system double-tap `openEditor` callback to Flutter.

## Phase 5: Testing and Hardening (Next)

### Objectives
- Reliability and release readiness.

### Planned Tasks
- Unit tests for coordinator, router, proxies.
- Integration tests for settings -> coordinator -> overlay behavior.
- Performance and battery regression checks.
- Documentation hardening and troubleshooting updates.

## Rollback Strategy

Immediate rollback trigger:
- crash spikes
- major battery regression
- severe overlay usability regressions

Rollback action:
1. Disable overlay integration switch in settings defaults.
2. Keep capture paths operational in main app.
3. Re-enable after fix validation.
