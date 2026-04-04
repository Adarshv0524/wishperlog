import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class OverlayV1Logger {
  static const _tag = 'overlay_v1';

  static void event(String name, [Map<String, Object?> meta = const {}]) {
    final payload = meta.isEmpty ? '' : ' | $meta';
    final message = '[$_tag] $name$payload';
    debugPrint(message);
    developer.log(message, name: _tag);
  }
}
