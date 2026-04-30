import 'dart:async';

// ChatService handles chat logic and backend communication
class ChatService {
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  final StreamController<bool> _loadingController =
      StreamController<bool>.broadcast();

  bool failConnect = false;
  bool failSend = false;
  bool _isConnected = false;

  ChatService();

  Future<void> connect() async {
    _loadingController.add(true);
    if (failConnect) {
      _loadingController.add(false);
      _errorController.add('Failed to connect');
      throw Exception('Failed to connect');
    }
    _isConnected = true;
    _loadingController.add(false);
  }

  Future<void> sendMessage(String msg) async {
    if (!_isConnected) {
      await connect();
    }
    _loadingController.add(true);
    if (failSend) {
      _loadingController.add(false);
      _errorController.add('Failed to send message');
      throw Exception('Failed to send message');
    }
    _messageController.add(msg);
    _loadingController.add(false);
  }

  Stream<String> get messageStream => _messageController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<bool> get loadingStream => _loadingController.stream;
}
