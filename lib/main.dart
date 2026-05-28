import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart' as core_theme;
import 'services/notification_service.dart';
import 'screens/splash/splash_screen.dart';
import 'data/hive_init.dart';

const String _backgroundTaskName = 'deadlineCheck';

/// Theme state manager
class ThemeNotifier extends ChangeNotifier {
  bool _isDark = true; // Default dark mode for premium feel

  bool get isDark => _isDark;

  ThemeNotifier() { _loadTheme(); }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('isDark') ?? true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _isDark);
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode for clean UI
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Poppins font is bundled as local asset — no preload needed

  // Initialize Hive for local storage
  await Hive.initFlutter();
  await initHive();

  // Initialize notifications
  await NotificationService.initialize();

  // Initialize background task for deadline checking (skipped on web)
  if (!kIsWeb) {
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      _backgroundTaskName,
      _backgroundTaskName,
      frequency: const Duration(hours: 1),
    );
  }

  // Make status bar transparent
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

/// Background task callback — runs periodically to check deadlines
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await NotificationService.backgroundCheck();
    return Future.value(true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      
      title: 'Smart Student Planner',
      debugShowCheckedModeBanner: false,
      theme: core_theme.StudyFlowTheme.lightTheme,
      darkTheme: core_theme.StudyFlowTheme.darkTheme,
      themeMode: themeNotifier.isDark ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
      builder: (context, child) => child!,
    );
  }
}