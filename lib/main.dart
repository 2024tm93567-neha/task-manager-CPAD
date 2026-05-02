import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:provider/provider.dart';

import 'config/back4app_config.dart';
import 'providers/task_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/tasks/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Initialize Back4App (Parse SDK) ──────────────────────────────────────
  await Parse().initialize(
    Back4AppConfig.applicationId,
    Back4AppConfig.serverUrl,
    clientKey: Back4AppConfig.clientKey,
    autoSendSessionId: true,
    debug: true, // set to false for release
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: const TaskManagerApp(),
    ),
  );
}

class TaskManagerApp extends StatefulWidget {
  const TaskManagerApp({super.key});

  @override
  State<TaskManagerApp> createState() => _TaskManagerAppState();
}

class _TaskManagerAppState extends State<TaskManagerApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Back4AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      builder: (context, child) {
        // Constrain to mobile width on web/desktop
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 530),
            child: child!,
          ),
        );
      },
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
