import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/section_header.dart';
import '../../../screens/auth/login_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _name = 'Student';
  String _roll = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _name = prefs.getString('student_name') ?? 'Student';
      _roll = prefs.getString('roll_number') ?? '';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _name.isNotEmpty ? _name[0].toUpperCase() : 'S',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(_name,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            if (_roll.isNotEmpty)
              Text('Roll: $_roll',
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 32),

            // Settings
            SectionHeader(title: 'Settings', padding: const EdgeInsets.only(bottom: 12)),
            GlassCard(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _settingTile(
                    Icons.dark_mode_rounded,
                    'Dark Mode',
                    trailing: Switch(
                      value: themeNotifier.isDark,
                      activeThumbColor: AppColors.primary,
                      onChanged: (_) => themeNotifier.toggleTheme(),
                    ),
                  ),
                  const Divider(height: 1, indent: 60),
                  _settingTile(
                    Icons.notifications_rounded,
                    'Notifications',
                    subtitle: 'Study reminders, deadlines',
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // About
            SectionHeader(title: 'About', padding: const EdgeInsets.only(bottom: 12)),
            GlassCard(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _settingTile(Icons.info_rounded, 'Version', subtitle: '1.0.0'),
                  const Divider(height: 1, indent: 60),
                  _settingTile(Icons.favorite_rounded, 'Made for Students'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _settingTile(IconData icon, String title,
      {String? subtitle, Widget? trailing}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12))
          : null,
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}
