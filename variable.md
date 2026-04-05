# Variable Reference

This file is the shared reference for project-level enums, constants, and helper functions that are used across the app.

## Enums

- `NoteCategory`: `tasks`, `reminders`, `ideas`, `followUp`, `journal`, `general`
- `NotePriority`: `high`, `medium`, `low`
- `NoteStatus`: `active`, `archived`, `pendingAi`, `deleted`
- `CaptureSource`: `voiceOverlay`, `textOverlay`, `homeWritingBox`

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

## Background Task Names

- `WorkManagerService.periodicTaskName`: `wishperlog.periodic_google_tasks_sync`
- `WorkManagerService.periodicTaskUnique`: `wishperlog.periodic_google_tasks_sync.unique`
- `WorkManagerService.flushPendingTaskName`: `wishperlog.flush_pending_ai`
- `WorkManagerService.flushPendingTaskUnique`: `wishperlog.flush_pending_ai.unique`
- `WorkManagerService.telegramDigestTaskName`: `wishperlog.telegram_daily_digest`
- `WorkManagerService.telegramDigestTaskUnique`: `wishperlog.telegram_daily_digest.unique`

## Local Storage Keys

- `_lastTelegramDigestDateKey`: `digest.last_telegram_sent_date`

## Notes

- Enum string parsing should go through the shared helpers above instead of duplicating `trim().toLowerCase()` switch blocks.
- This file tracks shared values only. Local function variables are intentionally not listed here.