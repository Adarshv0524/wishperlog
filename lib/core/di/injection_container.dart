import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:wishperlog/core/background/connectivity_sync_coordinator.dart';
import 'package:wishperlog/core/settings/app_preferences_repository.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/core/theme/theme_cubit.dart';
import 'package:wishperlog/features/ai/data/ai_processing_service.dart';
import 'package:wishperlog/features/auth/data/repositories/user_repository.dart';
import 'package:wishperlog/features/capture/data/capture_service.dart';
import 'package:wishperlog/features/capture/presentation/state/capture_ui_controller.dart';
import 'package:wishperlog/features/notes/data/note_repository.dart';
import 'package:wishperlog/features/ai/data/ai_classifier_router.dart';
import 'package:wishperlog/features/overlay/overlay_notifier.dart';
import 'package:wishperlog/features/sync/data/external_sync_service.dart';
import 'package:wishperlog/features/sync/data/telegram_service.dart';
import 'package:wishperlog/features/sync/data/fcm_sync_service.dart';
import 'package:wishperlog/features/sync/data/firestore_note_sync_service.dart';
import 'package:wishperlog/features/sync/data/message_state_service.dart';
import 'package:wishperlog/shared/events/note_event_bus.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ── Core repositories ──────────────────────────────────────────────────────
  sl.registerLazySingleton<AppPreferencesRepository>(
    () => AppPreferencesRepository(),
  );
    sl.registerLazySingleton<NoteRepository>(() => NoteRepository());
  sl.registerLazySingleton<SpeechToText>(() => SpeechToText());
  sl.registerLazySingleton<TelegramService>(() => TelegramService.instance);
  sl.registerLazySingleton<NoteEventBus>(() => NoteEventBus.instance);
  sl.registerLazySingleton<IsarNoteStore>(() => IsarNoteStore.instance);

  // ── Capture ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<CaptureService>(() => CaptureService());
  sl.registerLazySingleton<CaptureUiController>(
    () => CaptureUiController(
      captureService: sl<CaptureService>(),
      speechToText: sl<SpeechToText>(),
    ),
  );

  // ── Overlay (new, clean) ───────────────────────────────────────────────────
  // Single source of truth for overlay enabled/position.
  // NO BuildContext references anywhere in this layer.
  sl.registerLazySingleton<OverlayNotifier>(() => OverlayNotifier());

  // ── AI + Sync services ─────────────────────────────────────────────────────
  sl.registerLazySingleton<AiClassifierRouter>(
    () => AiClassifierRouter()..hydrate(),
  );
  sl.registerLazySingleton<FirestoreNoteSyncService>(
    () => FirestoreNoteSyncService(),
  );

  // ── Background services ────────────────────────────────────────────────────
  sl.registerLazySingleton<AiProcessingService>(
    () => AiProcessingService(noteEventBus: sl<NoteEventBus>()),
  );
  sl.registerLazySingleton<FcmSyncService>(() => FcmSyncService());
  sl.registerLazySingleton<ConnectivitySyncCoordinator>(
    () => ConnectivitySyncCoordinator(),
  );

  // ── Presentation state ─────────────────────────────────────────────────────
  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(sl<AppPreferencesRepository>()),
  );

  // ── Google Sign-In ────────────────────────────────────────────────────────
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn(scopes: [
    'email',
    'https://www.googleapis.com/auth/calendar',
    'https://www.googleapis.com/auth/tasks',
  ]));

  sl.registerLazySingleton<ExternalSyncService>(
    () => ExternalSyncService(googleSignIn: sl<GoogleSignIn>()),
  );

  sl.registerLazySingleton<UserRepository>(
    () => UserRepository(googleSignIn: sl<GoogleSignIn>()),
  );

  // ── Message-state service ──────────────────────────────────────────────────
  sl.registerLazySingleton<MessageStateService>(
    () => MessageStateService.instance,
  );
}