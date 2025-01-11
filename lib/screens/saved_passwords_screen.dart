import 'package:flutter/material.dart';
import './generate_password_screen.dart';

class SavedPasswordsScreen extends StatelessWidget {
  const SavedPasswordsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Passwords'),
      ),
      body: savedPasswords.isEmpty
          ? const Center(
              child: Text(
                'No saved passwords yet!',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: savedPasswords.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.lock),
                  title: Text(savedPasswords[index]),
                );
              },
            ),
    );
  }
}
