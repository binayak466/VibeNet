import 'package:flutter/material.dart';

void main() {
  runApp(const VibeNetApp());
}

class VibeNetApp extends StatelessWidget {
  const VibeNetApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VibeNet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F141C),
      ),
      home: const AccountSettingsScreen(),
    );
  }
}

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F141C),
        title: const Text('Account', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          _buildAccountOption(
            icon: Icons.security,
            title: 'Security notifications',
            subtitle: 'Show security alerts for your account',
            onTap: () {},
          ),
          _buildAccountOption(
            icon: Icons.phone_android,
            title: 'Change number',
            subtitle: 'Migrate account to a new phone number',
            onTap: () {},
          ),
          _buildAccountOption(
            icon: Icons.lock_outline,
            title: 'Two-step verification',
            subtitle: 'Add extra security with a PIN',
            onTap: () {},
          ),
          _buildAccountOption(
            icon: Icons.description_outlined,
            title: 'Request account info',
            subtitle: 'Get a report of your account settings',
            onTap: () {},
          ),
          _buildAccountOption(
            icon: Icons.delete_forever,
            title: 'Delete account',
            subtitle: 'Permanently delete your account and data',
            textColor: Colors.redAccent,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAccountOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color textColor = Colors.white,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      onTap: onTap,
    );
  }
}
