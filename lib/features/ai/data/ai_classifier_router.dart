import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/features/ai/data/gemini_note_classifier.dart';
import 'package:wishperlog/features/ai/data/groq_note_classifier.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

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

class AiClassifierRouter {
  static const _prefsProviderKey = 'ai_provider';
  static const _prefsModelPrefix = 'ai_model_';

  static const List<AiProvider> _fallbackOrder = [
    AiProvider.gemini,
    AiProvider.groq,
    AiProvider.mistral,
    AiProvider.cerebras,
    AiProvider.huggingface,
  ];

  static const Map<AiProvider, List<AiModelOption>> _modelCatalog = {
    AiProvider.gemini: [
      AiModelOption(
        provider: AiProvider.gemini,
        id: 'gemini-1.5-flash',
        label: 'Gemini 1.5 Flash',
        description: 'Best compatibility for AI Studio keys. Fast and stable for note cleanup, categorization, and digest extraction.',
        recommended: true,
      ),
      AiModelOption(
        provider: AiProvider.gemini,
        id: 'gemini-2.5-flash',
        label: 'Gemini 2.5 Flash',
        description: 'Higher-quality reasoning when available. Good for longer transcripts and denser note summaries.',
      ),
      AiModelOption(
        provider: AiProvider.gemini,
        id: 'gemini-3-flash',
        label: 'Gemini 3 Flash',
        description: 'Newest fast Gemini option. Use when you want the strongest quality-to-speed balance.',
      ),
    ],
    AiProvider.groq: [
      AiModelOption(
        provider: AiProvider.groq,
        id: 'llama-3.3-70b-versatile',
        label: 'Llama 3.3 70B Versatile',
        description: 'Best quality on Groq for classification and clean note rewriting.',
        recommended: true,
      ),
      AiModelOption(
        provider: AiProvider.groq,
        id: 'llama-3.1-8b-instant',
        label: 'Llama 3.1 8B Instant',
        description: 'Very fast fallback for quick routing, short notes, and quota-sensitive sessions.',
      ),
      AiModelOption(
        provider: AiProvider.groq,
        id: 'qwen3-32b',
        label: 'Qwen 3 32B',
        description: 'Good multilingual and structured-output performance for mixed-language notes.',
      ),
      AiModelOption(
        provider: AiProvider.groq,
        id: 'llama-4-scout-17b-16e-instruct',
        label: 'Llama 4 Scout',
        description: 'Balanced quality and speed for general-purpose note classification.',
      ),
    ],
    AiProvider.mistral: [
      AiModelOption(
        provider: AiProvider.mistral,
        id: 'mistral-large-latest',
        label: 'Mistral Large',
        description: 'Strong structured reasoning and classification quality for free-form notes.',
        recommended: true,
      ),
      AiModelOption(
        provider: AiProvider.mistral,
        id: 'open-mistral-nemo',
        label: 'Mistral Nemo',
        description: 'Efficient daily-driver model when you want lower latency and solid accuracy.',
      ),
      AiModelOption(
        provider: AiProvider.mistral,
        id: 'codestral-latest',
        label: 'Codestral',
        description: 'Useful for terse, highly structured output when the note text is noisy or fragmented.',
      ),
    ],
    AiProvider.huggingface: [
      AiModelOption(
        provider: AiProvider.huggingface,
        id: 'meta-llama/Llama-3.1-70B-Instruct',
        label: 'Llama 3.1 70B Instruct',
        description: 'Strong general reasoning via Hugging Face hosted inference.',
        recommended: true,
      ),
      AiModelOption(
        provider: AiProvider.huggingface,
        id: 'mistralai/Mistral-Nemo-Instruct-2407',
        label: 'Mistral Nemo Instruct',
        description: 'Good for fast testing and light-weight classification on the HF API.',
      ),
      AiModelOption(
        provider: AiProvider.huggingface,
        id: 'google/gemma-2-27b-it',
        label: 'Gemma 2 27B IT',
        description: 'Solid compact alternative for testing broad open-model support.',
      ),
    ],
    AiProvider.cerebras: [
      AiModelOption(
        provider: AiProvider.cerebras,
        id: 'llama-3.3-70b',
        label: 'Llama 3.3 70B',
        description: 'High-throughput model for strong note cleanup and extraction.',
        recommended: true,
      ),
      AiModelOption(
        provider: AiProvider.cerebras,
        id: 'llama-3.1-8b',
        label: 'Llama 3.1 8B',
        description: 'Fast and inexpensive fallback for short notes or quota-sensitive runs.',
      ),
      AiModelOption(
        provider: AiProvider.cerebras,
        id: 'llama-4-scout-17b-16e-instruct',
        label: 'Llama 4 Scout',
        description: 'Balanced choice when you want a newer instruction model on Cerebras.',
      ),
    ],
    AiProvider.auto: [],
  };

  final GeminiNoteClassifier _gemini;
  final GroqNoteClassifier _groq;
  final Map<AiProvider, _OpenAiCompatibleClassifier> _openAiClients = {};

  AiProvider _activeProvider = AiProvider.auto;
  String _lastUsedModelName = 'AI';
  final Map<AiProvider, String> _selectedModelIds = {};

  AiClassifierRouter()
      : _gemini = GeminiNoteClassifier(),
        _groq = GroqNoteClassifier() {
    _seedDefaults();
    _openAiClients[AiProvider.mistral] = _OpenAiCompatibleClassifier(
      providerName: 'mistral',
      apiKey: AppEnv.mistralApiKey,
      endpoint: Uri.parse('https://api.mistral.ai/v1/chat/completions'),
      fallbackModels: const ['open-mistral-nemo', 'codestral-latest'],
    );
    _openAiClients[AiProvider.huggingface] = _OpenAiCompatibleClassifier(
      providerName: 'huggingface',
      apiKey: AppEnv.huggingFaceApiKey,
      endpoint: Uri.parse('https://api-inference.huggingface.co/v1/chat/completions'),
      fallbackModels: const [
        'mistralai/Mistral-Nemo-Instruct-2407',
        'google/gemma-2-27b-it',
      ],
    );
    _openAiClients[AiProvider.cerebras] = _OpenAiCompatibleClassifier(
      providerName: 'cerebras',
      apiKey: AppEnv.cerebrasApiKey,
      endpoint: Uri.parse('https://api.cerebras.ai/v1/chat/completions'),
      fallbackModels: const ['llama-3.1-8b', 'llama-4-scout-17b-16e-instruct'],
    );
  }

  AiProvider get activeProvider => _activeProvider;
  String get lastUsedModelName => _lastUsedModelName;
  bool get geminiConfigured => _gemini.isConfigured;
  bool get groqConfigured => _groq.isConfigured;
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
      orElse: () => models.isNotEmpty ? models.first : const AiModelOption(
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
        return geminiConfigured || groqConfigured || mistralConfigured || huggingfaceConfigured || cerebrasConfigured;
      case AiProvider.gemini:
        return geminiConfigured;
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
      case AiProvider.gemini:
        return 'Gemini';
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
        return 'Tries Gemini first, then Groq, then Mistral, Cerebras, and Hugging Face.';
      case AiProvider.gemini:
        return 'Best for AI Studio keys and the cleanest note rewrites.';
      case AiProvider.groq:
        return 'Fastest OpenAI-compatible fallback for real-time note capture.';
      case AiProvider.mistral:
        return 'Strong structured reasoning with an experimentation-friendly API.';
      case AiProvider.huggingface:
        return 'Broad open-model testing via hosted inference endpoints.';
      case AiProvider.cerebras:
        return 'High-throughput Llama inference with low-latency responses.';
    }
  }

  Future<void> hydrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedProvider = prefs.getString(_prefsProviderKey);
      _activeProvider = AiProvider.values.firstWhere(
        (p) => p.name == storedProvider,
        orElse: () => AiProvider.auto,
      );

      for (final provider in AiProvider.values) {
        if (provider == AiProvider.auto) continue;
        final storedModel = prefs.getString('$_prefsModelPrefix${provider.name}');
        if (storedModel != null && storedModel.isNotEmpty) {
          _selectedModelIds[provider] = storedModel;
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

  Future<GeminiClassificationResult> classify(String rawTranscript) async {
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
    debugPrint('[AiClassifierRouter] All providers failed — using local fallback');
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

  Future<GeminiClassificationResult?> _classifyWithProvider(
    AiProvider provider,
    String rawTranscript,
  ) async {
    switch (provider) {
      case AiProvider.auto:
        return null;
      case AiProvider.gemini:
        if (!_gemini.isConfigured) return null;
        try {
          return await _gemini.classify(
            rawTranscript,
            modelName: selectedModelIdFor(AiProvider.gemini),
          );
        } catch (e) {
          debugPrint('[AiClassifierRouter] Gemini failed: $e');
          return null;
        }
      case AiProvider.groq:
        if (!_groq.isConfigured) return null;
        try {
          return await _groq.classify(
            rawTranscript,
            modelName: selectedModelIdFor(AiProvider.groq),
          );
        } catch (e) {
          debugPrint('[AiClassifierRouter] Groq failed: $e');
          return null;
        }
      case AiProvider.mistral:
      case AiProvider.huggingface:
      case AiProvider.cerebras:
        final client = _openAiClients[provider];
        if (client == null || !client.isConfigured) return null;
        try {
          return await client.classify(
            rawTranscript,
            modelName: selectedModelIdFor(provider),
          );
        } catch (e) {
          debugPrint('[AiClassifierRouter] ${provider.name} failed: $e');
          return null;
        }
    }
  }

  GeminiClassificationResult _localFallback(String raw) {
    final cleaned = raw.trim();
    final words = cleaned.split(RegExp(r'\s+')).take(6).toList();
    final title = words.isEmpty ? 'Quick note' : words.join(' ');
    return GeminiClassificationResult(
      title: title,
      category: inferCategoryFromText(cleaned),
      priority: NotePriority.medium,
      extractedDate: null,
      cleanBody: cleaned,
      model: 'local',
      wasFallback: true,
    );
  }

  void _seedDefaults() {
    for (final entry in _modelCatalog.entries) {
      final provider = entry.key;
      if (provider == AiProvider.auto) continue;
      if (_selectedModelIds[provider]?.isNotEmpty == true) continue;
      final models = entry.value;
      if (models.isEmpty) continue;
      _selectedModelIds[provider] = models.firstWhere(
        (option) => option.recommended,
        orElse: () => models.first,
      ).id;
    }
  }
}

class _OpenAiCompatibleClassifier {
  _OpenAiCompatibleClassifier({
    required this.providerName,
    required this.apiKey,
    required this.endpoint,
    required this.fallbackModels,
  });

  final String providerName;
  final String apiKey;
  final Uri endpoint;
  final List<String> fallbackModels;

  bool get isConfigured => apiKey.isNotEmpty;

  Future<GeminiClassificationResult?> classify(
    String rawTranscript, {
    String? modelName,
  }) async {
    if (!isConfigured || rawTranscript.trim().isEmpty) return null;

    final candidates = <String>{
      if (modelName != null && modelName.trim().isNotEmpty) modelName.trim(),
      ...fallbackModels,
    }.toList();

    for (final model in candidates) {
      final result = await _callApi(rawTranscript, model);
      if (result != null) return result;
    }
    return null;
  }

  Future<GeminiClassificationResult?> _callApi(
    String rawTranscript,
    String model,
  ) async {
    try {
      final response = await http.post(
        endpoint,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'system', 'content': GeminiNoteClassifier.buildSystemPrompt()},
            {'role': 'user', 'content': 'Raw input: ${rawTranscript.trim()}'},
          ],
          'temperature': 0.2,
          'max_tokens': 512,
          'response_format': {'type': 'json_object'},
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 429) {
        debugPrint('[$providerName] Rate limit hit on $model');
        return null;
      }

      if (response.statusCode != 200) {
        debugPrint('[$providerName] API error ${response.statusCode} on $model: ${response.body}');
        return null;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final content = _extractContent(body);
      if (content == null || content.trim().isEmpty) return null;

      return _parse(rawTranscript, content.trim(), model: '$providerName-$model');
    } catch (e) {
      debugPrint('[$providerName] classify error on $model: $e');
      return null;
    }
  }

  String? _extractContent(Map<String, dynamic> body) {
    final choices = body['choices'];
    if (choices is! List || choices.isEmpty) return null;
    final first = choices.first;
    if (first is! Map<String, dynamic>) return null;
    final message = first['message'];
    if (message is! Map<String, dynamic>) return null;
    final content = message['content'];
    return content is String ? content : null;
  }

  GeminiClassificationResult? _parse(
    String raw,
    String payload, {
    required String model,
  }) {
    try {
      final noFence = payload
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll('```', '')
          .trim();
      final start = noFence.indexOf('{');
      final end = noFence.lastIndexOf('}');
      if (start < 0 || end <= start) return null;

      final decoded = jsonDecode(noFence.substring(start, end + 1)) as Map<String, dynamic>;
      final title = (decoded['title'] as String?)?.trim();
      final cleanBody = (decoded['clean_body'] as String?)?.trim();
      final categoryText = (decoded['category'] as String?) ?? NoteCategory.general.name;
      final inferredCategory = parseCategory(categoryText);
      final textForHeuristics = [raw, title, cleanBody].whereType<String>().join(' ');

      return GeminiClassificationResult(
        title: title?.isNotEmpty == true ? title! : _fallbackTitle(raw),
        category: inferredCategory == NoteCategory.general
            ? inferCategoryFromText(textForHeuristics)
            : inferredCategory,
        priority: parsePriority((decoded['priority'] as String?) ?? NotePriority.medium.name),
        extractedDate: _parseDate(decoded['extracted_date']),
        cleanBody: cleanBody?.isNotEmpty == true ? cleanBody! : raw.trim(),
        model: model,
        wasFallback: false,
      );
    } catch (e) {
      debugPrint('[$providerName] parse error: $e');
      return null;
    }
  }

  String _fallbackTitle(String raw) {
    final words = raw.trim().split(RegExp(r'\s+')).take(6).toList();
    return words.isEmpty ? 'Quick note' : words.join(' ');
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().toLowerCase() == 'null') return null;
    try {
      return DateTime.parse(value.toString().trim());
    } catch (_) {
      return null;
    }
  }
}
