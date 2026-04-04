import 'package:http/http.dart' as http;

class HeaderClient extends http.BaseClient {
  HeaderClient(this._headers, [http.Client? inner])
      : _inner = inner ?? http.Client();

  final Map<String, String> _headers;
  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
