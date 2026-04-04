# Overlay Rebuild Plan (v2)

This document defines how to rebuild the floating overlay button cleanly.
Current overlay code has been removed so implementation can restart from a stable baseline.

## 1. Product Goals

- Start capture from any screen without breaking app stability.
- Keep interactions simple and predictable.
- Never block note saving on AI/external sync.
- Degrade gracefully if permissions are missing.

## 2. Scope

In scope:
- Floating bubble UI.
- Expand/collapse behavior.
- Voice capture trigger.
- Quick text capture trigger.
- Save path into local notes (immediate), AI processing async.

Out of scope for v2 first cut:
- Global hardware key trigger via accessibility service.
- Complex gesture combos.
- Cloud position sync.

## 3. UX Behavior

### 3.1 Bubble states
- Hidden: no overlay shown.(or else always show ultra transparent overlay on screen as it makes things quick)
- Idle bubble: small draggable button.
- Listening: visual active pulse.
- Text input panel: compact multiline input + save.
- Processing: temporary busy indicator only after save.

### 3.2 Gestures
- Single tap: open quick actions sheet (Voice, Text, Close).
- Long press: start voice capture while pressed; release saves.
- Drag: move bubble position; snap to nearest edge on release.
- Close action: hide overlay and persist hidden state.

### 3.3 Save feedback
- Save must return in under 200ms locally.
- Show toast/snackbar: "Saved" or "Saved, AI processing".
- Folder counts should update immediately from local DB.

## 4. Technical Architecture

- Keep overlay logic isolated in one feature module:
  - lib/features/overlay_v1/
- Use one service boundary:
  - OverlayCoordinator (state + commands)
- Use existing CaptureService for persistence.
- Persist only minimal overlay prefs:
  - visibility
  - x/y position

No direct coupling with home screen widgets.

## 5. Data Flow

1. Overlay event (tap/long press/text save)
2. OverlayCoordinator validates state + permissions
3. CaptureService.ingestRawCapture()
4. CaptureService writes pending note immediately
5. Background AI promotion updates category/priority/status
6. UI streams refresh counts and folder lists

## 6. Permission Strategy

- Phase A: on device(over any app or even home scrren) overlay button .
- Ask SYSTEM_ALERT_WINDOW only when user explicitly enables overlay.
- If denied: show inline help and continue app without overlay.

## 7. Reliability Rules

- No uncaught exceptions from overlay isolate.
- All plugin calls wrapped in try/catch with fallback state.
- If overlay crashes, auto-disable overlay feature flag and continue app.

## 8. Observability

Add structured logs (debug only):
- overlay_open
- overlay_close
- overlay_voice_start
- overlay_voice_stop
- overlay_text_save
- overlay_save_success
- overlay_save_failure

## 9. Performance Budgets

- Frame budget: keep overlay interactions at 60fps+ target.
- Save action to local DB: < 200ms target.
- Overlay startup: < 500ms warm target.

## 10. Milestones

M1: Base bubble + drag + hide
- Bubble appears, drags, snaps, hides, restores.

M2: Text capture
- Open input panel, save pending note instantly.

M3: Voice capture
- Press-to-talk with clean start/stop lifecycle.

M4: Polish
- Animations, error handling, QA pass.

## 11. Acceptance Criteria

- No black screen or startup crash when overlay is enabled/disabled.
- Save from overlay always creates a local note.
- Folder counts update immediately after overlay save.
- Overlay can be fully disabled from settings.
- App works fully even if overlay permission is denied.

## 12. Rebuild Checklist

- [ ] Add overlay_v1 module skeleton.
- [ ] Add feature flag in settings.
- [ ] Implement bubble container.
- [ ] Implement drag + snap.
- [ ] Implement quick action sheet.
- [ ] Wire text save path.
- [ ] Wire voice press-and-hold path.
- [ ] Add instrumentation logs.
- [ ] Regression test note save/count refresh.
