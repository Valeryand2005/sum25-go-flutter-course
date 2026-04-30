import 'dart:async';

class UserService {
  final StreamController<Map<String, String>> _userController =
      StreamController<Map<String, String>>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  final StreamController<bool> _loadingController =
      StreamController<bool>.broadcast();
  bool fail = false;

  Stream<Map<String, String>> get userStream => _userController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<bool> get loadingStream => _loadingController.stream;

  Future<Map<String, String>> fetchUser() async {
    _loadingController.add(true);
    try {
      if (fail) {
        throw Exception('Failed');
      }
      final data = {'name': 'Valery', 'email': 'v.andruwenko@innopolis.university'};
      _userController.add(data);
      return data;
    } catch (e) {
      _errorController.add(e.toString());
      rethrow;
    } finally {
      _loadingController.add(false);
    }
  }
}
