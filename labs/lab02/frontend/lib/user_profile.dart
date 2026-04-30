import 'package:flutter/material.dart';
import 'package:lab02_chat/user_service.dart';

// UserProfile displays and updates user info
class UserProfile extends StatefulWidget {
  final UserService
      userService; // Accepts a user service for fetching user info
  const UserProfile({Key? key, required this.userService}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Map<String, String>? _user;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = await widget.userService.fetchUser();
      if (!mounted) return;
      setState(() {
        _user = user;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'error: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_user == null) {
      return const Center(child: Text('User not found'));
    }
    return Column(
      children: [
        Text(_user!['name'] ?? ''),
        Text(_user!['email'] ?? ''),
        TextButton(
          onPressed: () {
            _fetchUser();
          },
          child: const Text('Refresh'),
        ),
      ],
    );
  }
}
