import 'package:flutter/material.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F141C),
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
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Security notifications clicked')),
              );
            },
          ),
          _buildAccountOption(
            icon: Icons.phone_android,
            title: 'Change number',
            subtitle: 'Migrate account to a new phone number',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Change number clicked')),
              );
            },
          ),
          _buildAccountOption(
            icon: Icons.lock_outline,
            title: 'Two-step verification',
            subtitle: 'Add extra security with a PIN',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Two-step verification clicked')),
              );
            },
          ),
          _buildAccountOption(
            icon: Icons.description_outlined,
            title: 'Request account info',
            subtitle: 'Get a report of your account settings',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Request account info clicked')),
              );
            },
          ),
          _buildAccountOption(
            icon: Icons.delete_forever,
            title: 'Delete account',
            subtitle: 'Permanently delete your account and data',
            textColor: Colors.redAccent,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF0F141C),
                  title: const Text('Delete Account', style: TextStyle(color: Colors.white)),
                  content: const Text('Are you sure you want to permanently delete your account?', style: TextStyle(color: Colors.grey)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.blueAccent)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );
            },
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
