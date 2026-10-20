// lib/screens/SettingsScreen/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _isNotificationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // ✅ IMPLEMENTASI SHARED PREFERENCES (BACA DATA)
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      _isNotificationEnabled = prefs.getBool('notification_enabled') ?? true;
    });
  }

  // ✅ IMPLEMENTASI SHARED PREFERENCES (SIMPAN DATA)
  Future<void> _toggleDarkMode(bool value) async {
    setState(() => _isDarkMode = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
  }

  Future<void> _toggleNotification(bool value) async {
    setState(() => _isNotificationEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_enabled', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Mode Gelap'),
            subtitle: const Text('Aktifkan tema gelap pada aplikasi'),
            value: _isDarkMode,
            onChanged: _toggleDarkMode,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Notifikasi'),
            subtitle: const Text('Terima notifikasi promo dan pesanan'),
            value: _isNotificationEnabled,
            onChanged: _toggleNotification,
          ),
        ],
      ),
    );
  }
}