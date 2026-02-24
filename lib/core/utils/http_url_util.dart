// lib/core/utils/http_url_util.dart
import 'package:leelame/core/api/api_endpoints.dart';

class HttpUrlUtil {
  static String? normalizeHttpUrl(String? url) {
    if (url == null || url.isEmpty) {
      return null;
    }

    // 1. Check if it already starts with http:// or https://
    final urlRegex = RegExp(r"^https?://");
    if (urlRegex.hasMatch(url)) {
      return url;
    }

    // 2. Get the base URL from api endpoints
    final String base = ApiEndpoints.serverUrl;

    // 3. Normalize slashes and combine
    final cleanBase = base.endsWith("/")
        ? base.substring(0, base.length - 1)
        : base;

    final cleanUrl = url.startsWith("/") ? url : "/$url";

    return "$cleanBase$cleanUrl";
  }
}
