import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/features/ai/data/unified_ai_classifier.dart';
import 'package:wishperlog/features/nlp/nlp_task_parser.dart';
import 'package:wishperlog/shared/models/enums.dart';

class AiModelOption {
  const AiModelOption({
    required this.provider,
    required this.id,
    required this.label,
    required this.description,
    this.recommended = false,
  });

  final AiProvider provider;
  final String id;
  final String label;
  final String description;
  final bool recommended;
}

/// Consolidated router for all AI providers (Groq, Mistral, Cerebras, HuggingFace).
/// Gemini has been completely removed from this system.
class AiClassifierRouter {
  static const _prefsProviderKey = 'ai_provider';
  static const _prefsModelPrefix = 'ai_model_';

  static const List<AiProvider> _fallbackOrder = [
    AiProvider.groq,
    AiProvider.mistral,
    AiProvider.cerebras,
    AiProvider.huggingface,
  ];

  static const Map<AiProvider, List<AiModelOption>> _modelCatalog = {
    AiProvider.groq: [
      AiModelOption(
        provider: AiProvider.groq,
        id: 'llama-3.3-70b-versatile',
        label: 'Llama 3.3 70B Versatile',
        description: 'Premium quality for classification and note enhancement. Best all-around performance.',
        recommended: true,
      ),
      AiModelOption(
        provider: AiProvider.groq,
        id: 'llama-3.1-8b-instant',
        label: 'Llama 3.1 8B Instant',
        description: 'Fast and lightweight fallback. Great for testing and quota limits.',
      ),
      AiModelOption(
        provider: AiProvider.groq,
        id: 'qwen3-32b',
        label: 'Qwen 3 32B',
        description: 'Strong multilingual performance for mixed-language notes.',
      ),
      AiModelOption(
        provider: AiProvider.groq,
        id: 'llama-4-scout-17b-16e-instruct',
        label: 'Llama 4 Scout',
        description: 'Balanced quality and speed for general-purpose classification.',
      ),
    ],
    AiProvider.mistral: [
      AiModelOption(
        provider: AiProvider.mistral,
        id: 'mistral-large-latest',
        label: 'Mistral Large',
        description: 'Strong structured reasoning and high-quality classification. Excellent for complex notes.',
        recommended: true,
      ),
      AiModelOption(
        provider: AiProvider.mistral,
        id: 'open-mistral-nemo',
        label: 'Mistral Nemo',
        description: 'Efficient model with solid accuracy. Good for fast classification.',
      ),
      AiModelOption(
        provider: AiProvider.mistral,
        id: 'codestral-latest',
        label: 'Codestral',
        description: 'For highly structured output and technical notes.',
      ),
    ],
    AiProvider.huggingface: [
      AiModelOption(
        provider: AiProvider.huggingface,
        id: 'meta-llama/Llama-3.1-70B-Instruct',
        label: 'Llama 3.1 70B Instruct',
        description: 'Powerful reasoning via Hugging Face hosted inference. High quality.',
        recommended: true,
      ),
      AiModelOption(
        provider: AiProvider.huggingface,
        id: 'mistralai/Mistral-Nemo-Instruct-2407',
        label: 'Mistral Nemo Instruct',
        description: 'Efficient and fast via Hugging Face API.',
      ),
      AiModelOption(
        provider: AiProvider.huggingface,
        id: 'google/gemma-2-27b-it',
        label: 'Gemma 2 27B IT',
        description: 'Solid compact alternative for general classification.',
      ),
    ],
    AiProvider.cerebras: [
      AiModelOption(
        provider: AiProvider.cerebras,
        id: 'llama-3.3-70b',
        label: 'Llama 3.3 70B',
        description: 'High-throughput inference with excellent note enhancement quality.',
        recommended: true,
      ),
      AiModelOption(
        provider: AiProvider.cerebras,
        id: 'llama-3.1-8b',
        label: 'Llama 3.1 8B',
        description: 'Fast fallback for quick classification.',
      ),
      AiModelOption(
        provider: AiProvider.cerebras,
        id: 'llama-4-scout-17b-16e-instruct',
        label: 'Llama 4 Scout',
        description: 'Latest instruction model on Cerebras.',
      ),
    ],
    AiProvider.auto: [],
  };

  final Map<AiProvider, UnifiedAiClassifier> _classifiers = {};

  AiProvider _activeProvider = AiProvider.auto;
  String _lastUsedModelName = 'AI';
  final Map<AiProvider, String> _selectedModelIds = {};

  AiClassifierRouter() {
    _initializeClassifiers();
    _seedDefaults();
  }

  void _initializeClassifiers() {
    _classifiers[AiProvider.groq] = UnifiedAiClassifier(
      providerName: 'groq',
      apiKey: AppEnv.groqApiKey,
      endpoint: Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      primaryModels: const ['llama-3.3-70b-versatile'],
      fallbackModels: const [
        'llama-3.1-8b-instant',
        'qwen3-32b',
        'llama-4-scout-17b-16e-instruct',
      ],
    );

    _classifiers[AiProvider.mistral] = UnifiedAiClassifier(
      providerName: 'mistral',
      apiKey: AppEnv.mistralApiKey,
      endpoint: Uri.parse('https://api.mistral.ai/v1/chat/completions'),
      primaryModels: const ['mistral-large-latest'],
      fallbackModels: const ['open-mistral-nemo', 'codestral-latest'],
    );

    _classifiers[AiProvider.cerebras] = UnifiedAiClassifier(
      providerName: 'cerebras',
      apiKey: AppEnv.cerebrasApiKey,
      endpoint: Uri.parse('https://api.cerebras.ai/v1/chat/completions'),
      primaryModels: const ['llama-3.3-70b'],
      fallbackModels: const ['llama-3.1-8b', 'llama-4-scout-17b-16e-instruct'],
    );

    _classifiers[AiProvider.huggingface] = UnifiedAiClassifier(
      providerName: 'huggingface',
      apiKey: AppEnv.huggingFaceApiKey,
      endpoint: Uri.parse(
          'https://api-inference.huggingface.co/v1/chat/completions'),
      primaryModels: const ['meta-llama/Llama-3.1-70B-Instruct'],
      fallbackModels: const [
        'mistralai/Mistral-Nemo-Instruct-2407',
        'google/gemma-2-27b-it',
      ],
    );
  }

  AiProvider get activeProvider => _activeProvider;
  String get lastUsedModelName => _lastUsedModelName;
  bool get groqConfigured => AppEnv.groqApiKey.isNotEmpty;
  bool get mistralConfigured => AppEnv.mistralApiKey.isNotEmpty;
  bool get huggingfaceConfigured => AppEnv.huggingFaceApiKey.isNotEmpty;
  bool get cerebrasConfigured => AppEnv.cerebrasApiKey.isNotEmpty;

  List<AiModelOption> modelsFor(AiProvider provider) {
    return List.unmodifiable(_modelCatalog[provider] ?? const <AiModelOption>[]);
  }

  String selectedModelIdFor(AiProvider provider) {
    final models = _modelCatalog[provider] ?? const <AiModelOption>[];
    final selected = _selectedModelIds[provider];
    if (selected != null && selected.isNotEmpty) {
      return selected;
    }
    return models.firstWhere(
      (option) => option.recommended,
      orElse: () => models.isNotEmpty
          ? models.first
          : const AiModelOption(
              provider: AiProvider.auto,
              id: 'local',
              label: 'Local',
              description: 'No AI provider configured.',
            ),
    ).id;
  }

  AiModelOption? selectedModelFor(AiProvider provider) {
    final modelId = selectedModelIdFor(provider);
    for (final option in modelsFor(provider)) {
      if (option.id == modelId) return option;
    }
    return null;
  }

  bool isConfigured(AiProvider provider) {
    switch (provider) {
      case AiProvider.auto:
        return groqConfigured ||
            mistralConfigured ||
            huggingfaceConfigured ||
            cerebrasConfigured;
      case AiProvider.groq:
        return groqConfigured;
      case AiProvider.mistral:
        return mistralConfigured;
      case AiProvider.huggingface:
        return huggingfaceConfigured;
      case AiProvider.cerebras:
        return cerebrasConfigured;
    }
  }

  String providerLabel(AiProvider provider) {
    switch (provider) {
      case AiProvider.auto:
        return 'Auto';
      case AiProvider.groq:
        return 'Groq';
      case AiProvider.mistral:
        return 'Mistral';
      case AiProvider.huggingface:
        return 'Hugging Face';
      case AiProvider.cerebras:
        return 'Cerebras';
    }
  }

  String providerDescription(AiProvider provider) {
    switch (provider) {
      case AiProvider.auto:
        return 'Tries Groq first, then Mistral, Cerebras, and Hugging Face.';
      case AiProvider.groq:
        return 'Fastest and most reliable for real-time note classification.';
      case AiProvider.mistral:
        return 'Strong structured reasoning and high-quality output.';
      case AiProvider.huggingface:
        return 'Broad open-model testing via hosted inference.';
      case AiProvider.cerebras:
        return 'High-throughput inference with low latency.';
    }
  }

  Future<void> hydrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedProvider = prefs.getString(_prefsProviderKey);
      var provider = AiProvider.values.firstWhere(
        (p) => p.name == storedProvider,
        orElse: () => AiProvider.auto,
      );

      _activeProvider = provider;

      for (final p in AiProvider.values) {
        if (p == AiProvider.auto) continue;
        final storedModel = prefs.getString('$_prefsModelPrefix${p.name}');
        if (storedModel != null && storedModel.isNotEmpty) {
          _selectedModelIds[p] = storedModel;
        }
      }
      _seedDefaults();
    } catch (e) {
      debugPrint('[AiClassifierRouter] hydrate error: $e');
    }
  }

  Future<void> setProvider(AiProvider provider) async {
    _activeProvider = provider;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsProviderKey, provider.name);
    } catch (e) {
      debugPrint('[AiClassifierRouter] setProvider error: $e');
    }
  }

  Future<void> setModel(AiProvider provider, String modelId) async {
    _selectedModelIds[provider] = modelId;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefsModelPrefix${provider.name}', modelId);
    } catch (e) {
      debugPrint('[AiClassifierRouter] setModel error: $e');
    }
  }

  Future<UnifiedAiClassificationResult> classify(String rawTranscript) async {
    final providers = _orderedProviders();
    for (final provider in providers) {
      final result = await _classifyWithProvider(provider, rawTranscript);
      if (result != null) {
        _lastUsedModelName = result.model;
        debugPrint('[AiClassifierRouter] Classified via ${result.model} '
            '(fallback=${result.wasFallback}): ${result.category.name}');
        return result;
      }
    }

    final fallback = _localFallback(rawTranscript);
    _lastUsedModelName = fallback.model;
    debugPrint(
        '[AiClassifierRouter] All providers failed — using local fallback');
    return fallback;
  }

  List<AiProvider> _orderedProviders() {
    if (_activeProvider == AiProvider.auto) {
      return _fallbackOrder;
    }
    return <AiProvider>[
      _activeProvider,
      ..._fallbackOrder.where((provider) => provider != _activeProvider),
    ];
  }

  Future<UnifiedAiClassificationResult?> _classifyWithProvider(
    AiProvider provider,
    String rawTranscript,
  ) async {
    if (provider == AiProvider.auto) return null;

    final classifier = _classifiers[provider];
    if (classifier == null || !classifier.isConfigured) return null;

    try {
      return await classifier.classify(
        rawTranscript,
        modelName: selectedModelIdFor(provider),
      );
    } catch (e) {
      debugPrint('[AiClassifierRouter] ${provider.name} failed: $e');
      return null;
    }
  }

  UnifiedAiClassificationResult _localFallback(String raw) {
    final cleaned = raw.trim();
    final parsed = NlpTaskParser.parse(cleaned);
    return UnifiedAiClassificationResult(
      title: parsed.cleanTitle?.isNotEmpty == true
          ? parsed.cleanTitle!
          : _fallbackTitle(cleaned),
      translatedTitle: null,
      category: parsed.category,
      priority: parsed.priority,
      extractedDate: parsed.extractedDate,
      cleanBody: cleaned,
      model: 'local',
      wasFallback: true,
    );
  }

  String _fallbackTitle(String raw) {
    final words = raw.trim().split(RegExp(r'\s+')).take(8).toList();
    return words.isEmpty ? 'Quick note' : words.join(' ');
  }

  void _seedDefaults() {
    for (final entry in _modelCatalog.entries) {
      final provider = entry.key;
      if (provider == AiProvider.auto) {
        continue;
      }
      if (_selectedModelIds[provider]?.isNotEmpty == true) continue;
      final models = entry.value;
      if (models.isEmpty) continue;
      _selectedModelIds[provider] = models
          .firstWhere(
            (option) => option.recommended,
            orElse: () => models.first,
          )
          .id;
    }
  }
}
