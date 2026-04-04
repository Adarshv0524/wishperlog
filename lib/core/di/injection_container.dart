import 'package:get_it/get_it.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:wishperlog/core/background/connectivity_sync_coordinator.dart';
import 'package:wishperlog/core/settings/app_preferences_repository.dart';
import 'package:wishperlog/core/theme/theme_cubit.dart';
import 'package:wishperlog/features/ai/data/ai_processing_service.dart';
import 'package:wishperlog/features/auth/data/repositories/user_repository.dart';
import 'package:wishperlog/features/capture/data/capture_service.dart';
import 'package:wishperlog/features/capture/data/note_save_service.dart';
import 'package:wishperlog/features/notes/data/note_repository.dart';
import 'package:wishperlog/features/overlay_v1/data/overlay_v1_preferences.dart';
import 'package:wishperlog/features/overlay_v1/overlay_coordinator.dart';
import 'package:wishperlog/features/sync/data/external_sync_service.dart';
import 'package:wishperlog/features/sync/data/fcm_sync_service.dart';
import 'package:wishperlog/features/sync/data/firestore_note_sync_service.dart';
import 'package:wishperlog/shared/events/note_event_bus.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Repositories
  sl.registerLazySingleton<AppPreferencesRepository>(
    () => AppPreferencesRepository(),
  );
  sl.registerLazySingleton<UserRepository>(() => UserRepository());
  sl.registerLazySingleton<NoteRepository>(() => NoteRepository());
  sl.registerLazySingleton<SpeechToText>(() => SpeechToText());
  sl.registerLazySingleton<ExternalSyncService>(() => ExternalSyncService());
  sl.registerLazySingleton<NoteEventBus>(() => NoteEventBus.instance);
  sl.registerLazySingleton<CaptureService>(() => CaptureService());
  sl.registerLazySingleton<NoteSaveService>(
    () => NoteSaveService(noteEventBus: sl<NoteEventBus>()),
  );
  sl.registerLazySingleton<OverlayV1Preferences>(() => OverlayV1Preferences());
  sl.registerLazySingleton<OverlayCoordinator>(
    () => OverlayCoordinator(sl<OverlayV1Preferences>()),
  );
  sl.registerLazySingleton<FirestoreNoteSyncService>(
    () => FirestoreNoteSyncService(),
  );

  // Background services
  sl.registerLazySingleton<AiProcessingService>(
    () => AiProcessingService(noteEventBus: sl<NoteEventBus>()),
  );
  sl.registerLazySingleton<FcmSyncService>(() => FcmSyncService());
  sl.registerLazySingleton<ConnectivitySyncCoordinator>(
    () => ConnectivitySyncCoordinator(),
  );

  // Presentation state
  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(sl<AppPreferencesRepository>()),
  );
}
