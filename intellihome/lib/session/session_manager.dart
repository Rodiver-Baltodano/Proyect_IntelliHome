class SessionManager {
  static String? _currentUserId;

  static void setCurrentUserId(String? id) {
    _currentUserId = id;
  }

  static String? get currentUserId => _currentUserId;
}
