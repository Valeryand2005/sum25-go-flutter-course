import 'package:flutter/material.dart';
import 'chat_service.dart';
import 'dart:async';

// ChatScreen displays the chat UI
class ChatScreen extends StatefulWidget {
  final ChatService chatService;
  const ChatScreen({super.key, required this.chatService});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  StreamSubscription<String>? _messageSub;

  bool _isLoading = false;
  String? _error;
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _messageSub = widget.chatService.messageStream.listen((message) {
      setState(() {
        _messages.add(message);
      });
    });
    _connect();
  }

  Future<void> _connect() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await widget.chatService.connect();
    } catch (_) {
      setState(() {
        _error = 'Connection error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _error = 'Message is empty';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await widget.chatService.sendMessage(text);
      _messageController.clear();
    } catch (_) {
      setState(() {
        _error = 'Send error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isLoading) const LinearProgressIndicator(),
        if (_error != null) Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(_error!),
        ),
        Expanded(
          child: ListView(
            children: _messages.map((m) => ListTile(title: Text(m))).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(hintText: 'Message'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
