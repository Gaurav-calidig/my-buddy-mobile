import 'dart:collection';

import 'deep_linking_config.dart';

class DeepLinkingService {
  static const String scheme = DeepLinkConfig.scheme;
  static const String host = DeepLinkConfig.host;

  static String? initialLocationFromRouteName(String? routeName) {
    if (routeName == null || routeName.isEmpty || routeName == '/') {
      return null;
    }

    final uri = Uri.tryParse(routeName);
    if (uri == null) {
      return null;
    }

    return locationFromUri(uri);
  }

  static String? locationFromUri(Uri uri) {
    final path = _normalizedPath(uri);
    if (path.isEmpty) {
      return null;
    }

    return Uri(
      path: path,
      queryParameters: uri.queryParameters.isEmpty
          ? null
          : UnmodifiableMapView(uri.queryParameters),
      fragment: uri.fragment.isEmpty ? null : uri.fragment,
    ).toString();
  }

  static String buildDeepLink(String location) {
    final parsed = Uri.parse(location);
    final path = _normalizedPath(parsed);

    return Uri(
      scheme: scheme,
      host: host,
      path: path == '/' ? '' : path,
      queryParameters: parsed.queryParameters.isEmpty
          ? null
          : UnmodifiableMapView(parsed.queryParameters),
      fragment: parsed.fragment.isEmpty ? null : parsed.fragment,
    ).toString();
  }

  static String _normalizedPath(Uri uri) {
    if (uri.scheme == scheme) {
      if (uri.host == host) {
        return _ensureLeadingSlash(uri.path);
      }
      if (uri.host.isEmpty) {
        return _ensureLeadingSlash(uri.path);
      }
      return _ensureLeadingSlash('${uri.host}${uri.path}');
    }

    return _ensureLeadingSlash(uri.path);
  }

  static String _ensureLeadingSlash(String path) {
    if (path.isEmpty) {
      return '/';
    }
    return path.startsWith('/') ? path : '/$path';
  }
}
