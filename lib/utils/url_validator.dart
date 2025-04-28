// Create a new file: lib/utils/url_validator.dart
class URLValidator {
  static final urlRegExp = RegExp(
    r'^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?'
    r'[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,5}'
    r'(:[0-9]{1,5})?(\/.*)?$'
  );

  static String? validateURL(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Link is optional, so empty is fine
    }

    String urlToCheck = value.trim();
    if (!urlToCheck.startsWith('http://') && !urlToCheck.startsWith('https://')) {
      urlToCheck = 'https://$urlToCheck';
    }

    try {
      final uri = Uri.parse(urlToCheck);
      if (!uri.hasScheme || !uri.hasAuthority) {
        return 'Please enter a valid URL';
      }
      
      if (!urlRegExp.hasMatch(urlToCheck)) {
        return 'Please enter a valid URL format';
      }
      
      return null;
    } catch (e) {
      return 'Invalid URL format';
    }
  }

  static String? sanitizeURL(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    String sanitizedUrl = value.trim();
    if (!sanitizedUrl.startsWith('http://') && !sanitizedUrl.startsWith('https://')) {
      sanitizedUrl = 'https://$sanitizedUrl';
    }

    return sanitizedUrl;
  }
}