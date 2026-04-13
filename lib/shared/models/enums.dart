enum NoteCategory {
  tasks,
  reminders,
  ideas,
  followUp,
  journal,
  general,
}

enum NotePriority {
  high,
  medium,
  low,
}

enum NoteStatus {
  active,
  archived,
  pendingAi,
  deleted,
}

enum CaptureSource {
  voiceOverlay,
  textOverlay,
  homeWritingBox,
  shortcutTile,
  notification,
  googleTasks,
  googleCalendar,
}

enum AiProvider {
  auto,
  groq,
  mistral,
  huggingface,
  cerebras,
}
