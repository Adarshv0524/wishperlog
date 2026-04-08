# Variables Reference

This file is the shared reference for project-level enums, constants, helpers, task names, and persisted keys used across the app.

## Enums

- `NoteCategory`: `tasks`, `reminders`, `ideas`, `followUp`, `journal`, `general`
- `NotePriority`: `high`, `medium`, `low`
- `NoteStatus`: `active`, `archived`, `pendingAi`, `deleted`
- `CaptureSource`: `voiceOverlay`, `textOverlay`, `homeWritingBox`, `shortcutTile`, `notification`, `googleTasks`, `googleCalendar`
- `AiProvider`: `auto`, `gemini`, `groq`, `huggingface`

## Shared Collections And Helpers

- `kAllNoteCategories`: ordered list of note categories used by category pickers and folder views
- `categoryLabel(NoteCategory)`: human-readable category label
- `categoryIcon(NoteCategory)`: category icon mapping
- `categoryColor(NoteCategory)`: category color mapping
- `normalizeEnumToken(String)`: shared normalizer for enum-like raw strings
- `parseCategory(String)`: canonical category parser for raw strings and aliases
- `parsePriority(String)`: canonical priority parser for raw strings and aliases
- `parseStatus(String)`: canonical status parser for raw strings and aliases
- `parseSource(String)`: canonical capture-source parser for raw strings and aliases
- `priorityWeight(NotePriority)`: sort weight helper for priority
- `saveOriginPrefix(String)`: prefix helper for saved-note origin labels

## Background Task Names

- `WorkManagerService.periodicTaskName`: `wishperlog.periodic_google_tasks_sync`
- `WorkManagerService.periodicTaskUnique`: `wishperlog.periodic_google_tasks_sync.unique`
- `WorkManagerService.flushPendingTaskName`: `wishperlog.flush_pending_ai`
- `WorkManagerService.flushPendingTaskUnique`: `wishperlog.flush_pending_ai.unique`
- `WorkManagerService.telegramDigestTaskName`: `wishperlog.telegram_daily_digest`
- `WorkManagerService.telegramDigestTaskUnique`: `wishperlog.telegram_daily_digest.unique`

## MethodChannel Names

- `wishperlog/overlay`: native overlay bridge between `MainActivity` and `OverlayNotifier`

## Shared Preferences And Local Keys

- `overlay_v2.enabled`: overlay enabled flag
- `overlay_v2.pos_x`: overlay X position
- `overlay_v2.pos_y`: overlay Y position
- `digest.last_telegram_sent_date`: once-per-day Telegram digest guard

## Firestore Fields And Paths

- `users/{uid}/notes/{noteId}`: note collection path
- `users/{uid}.telegram_chat_id`: linked Telegram chat ID
- `users/{uid}.pending_telegram.token`: temporary Telegram connect token
- `users/{uid}.pending_telegram.expires_at`: Telegram connect token expiry

## Notes

- Enum string parsing should go through the shared helpers above instead of duplicating `trim().toLowerCase()` switch blocks.
- This file tracks shared values only. Local function variables are intentionally not listed here.
- Older docs used SQLite terminology, but the current local store is Isar.
