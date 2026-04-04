# WhisperLog Runtime Audit - GitHub Issues

## Issue 2: Overlay mic lifecycle throws NotInitializedError
- Type: bug
- Labels: bug, overlay, speech-to-text, runtime, blocker
- Severity: critical
- Status: open (runtime reproduction persists)
- Affected folders/files:
	- `lib/features/capture/overlay/overlay_capture_app.dart`
	- `lib/features/home/presentation/screens/home_screen.dart`
- Symptoms:
	- Overlay capture occasionally fails and error widget appears.
	- Follow-up errors cascade through layout/paint phases.
- Evidence from logs:
	- `Another exception was thrown: Instance of 'NotInitializedError'`
	- Immediate subsequent rendering failures.
- Suspected wiring issue:
	- Speech plugin start/stop race still exists under some device timing paths (hardware long-press + overlay window startup timing).
	- `stop()` may still execute after plugin deinit or before full init completion in a callback chain.
- Repro steps:
	1. Trigger overlay using hardware long-press.
	2. Press and release mic quickly.
	3. Observe intermittent initialization exception.
- Expected:
	- Overlay mic starts/stops without initialization exceptions.
- Actual:
	- Intermittent `NotInitializedError` and unstable UI state.
- Acceptance criteria:
	- No speech initialization exceptions during rapid press/release.
	- No red error widget from overlay capture flow.

## Issue 4: Duplicate Firebase Messaging background isolate warning
- Type: bug
- Labels: bug, fcm, background, android
- Severity: medium
- Status: open
- Affected folders/files:
	- `lib/features/sync/data/fcm_sync_service.dart`
	- `lib/main.dart`
- Evidence from logs:
	- `Attempted to start a duplicate background isolate. Returning...`
- Suspected wiring issue:
	- Background message handler registration/init order may run multiple times per process lifecycle.
	- Not always fatal, but can produce noisy runtime state and side effects.
- Expected:
	- Background isolate registration happens once per app process.
- Actual:
	- Duplicate-isolate warning appears during app runtime.
- Acceptance criteria:
	- Warning no longer appears during normal startup/use.

## Issue 5: Null-check assertion risk in settings profile image path
- Type: bug
- Labels: bug, null-safety, settings
- Severity: medium
- Status: open
- Affected folders/files:
	- `lib/features/settings/presentation/screens/settings_screen.dart`
- Risk points:
	- `authUser!.photoURL!`
	- `_lastSyncedAt!`
- Suspected wiring issue:
	- Force unwraps rely on transient UI conditions and can fail on async auth/profile changes.
- Expected:
	- No force unwrap crashes on user/profile transitions.
- Actual:
	- Runtime reports include repeated null-check exceptions in UI flows.
- Acceptance criteria:
	- No null-check operator runtime exceptions across settings flow.

## Issue 6: Overlay startup race with hardware long-press and zero-size renderer transitions
- Type: bug
- Labels: bug, overlay, android, lifecycle
- Severity: medium
- Status: open
- Affected folders/files:
	- `lib/main.dart`
	- `lib/features/capture/overlay/overlay_window_controller.dart`
	- `lib/features/capture/overlay/overlay_capture_app.dart`
- Evidence from logs:
	- `FlutterRenderer: Width is zero. 0,0` during overlay/service startup.
	- Immediate long-press event sequences (`start` then `end`) under overlay activation.
- Suspected wiring issue:
	- Hardware event can reach speech flow before overlay surface/session is fully stabilized.
- Expected:
	- Overlay becomes interactive only after stable render surface is ready.
- Actual:
	- Race window can trigger unstable mic lifecycle.
- Acceptance criteria:
	- No runtime exceptions when repeatedly triggering hardware long-press from cold app state.

## Issue 7: Android back-dispatcher warning remains unresolved
- Type: chore
- Labels: android, manifest, warning
- Severity: low
- Status: open
- Affected folders/files:
	- `android/app/src/main/AndroidManifest.xml`
- Evidence from logs:
	- `OnBackInvokedCallback is not enabled for the application.`
- Suspected wiring issue:
	- Manifest missing `android:enableOnBackInvokedCallback="true"`.
- Expected:
	- No back-dispatcher warnings on Android 13+.
- Actual:
	- Warning persists in runtime logs.
- Acceptance criteria:
	- Warning absent in startup and navigation logs.

---

## Audit Coverage Notes
- Folders audited:
	- `lib/app`
	- `lib/core`
	- `lib/shared`
	- `lib/features/ai`
	- `lib/features/auth`
	- `lib/features/capture`
	- `lib/features/home`
	- `lib/features/notes`
	- `lib/features/onboarding`
	- `lib/features/settings`
	- `lib/features/sync`
- Primary log stack correlations were mapped against the rendering paths (`Row`/`ListView`/`GlassContainer`) and speech lifecycle entry points.
