import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Screens/announcements/announcements_page.dart';
import 'Screens/notifications/notifications_page.dart';
import 'providers/language_provider.dart';
import 'Screens/profile/profile_page.dart';
import 'services/auth_service.dart';
import 'services/notification_helper.dart';
import 'services/websocket_service.dart';
import 'theme/app_theme.dart';
import 'Screens/login/login_page.dart';
import 'Screens/login/register_page.dart';
import 'Screens/dashboard/dashboard_page.dart';
import 'utils/dashboard_history.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hasSession = await AuthService.instance.restoreSession();
  if (hasSession) {
    await WebSocketService.instance.connect();
  }
  await NotificationHelper.instance.initialize();
  final languageProvider = await LanguageProvider.create();
  final themeProvider = await ThemeProvider.create();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: languageProvider),
      ],
      child: SMFApp(initiallyAuthenticated: hasSession),
    ),
  );
}

class SMFApp extends StatefulWidget {
  final bool initiallyAuthenticated;

  const SMFApp({
    super.key,
    required this.initiallyAuthenticated,
  });

  @override
  State<SMFApp> createState() => _SMFAppState();
}

class _SMFAppState extends State<SMFApp> {
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _notificationSubscription = WebSocketService.instance.stream.listen((message) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(message.message),
          backgroundColor: NotificationHelper.instance.colorForType(message.type),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return Directionality(
          textDirection:
              languageProvider.isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: MaterialApp(
            title: 'SMF - Security Monitoring',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeProvider.themeMode,
            initialRoute: DashboardHistory.currentRoute(widget.initiallyAuthenticated),
            onGenerateRoute: _generateRoute,
            builder: (context, child) => Directionality(
              textDirection: languageProvider.isArabic
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: child ?? const SizedBox.shrink(),
            ),
            routes: {
              '/login': (context) => const LoginPage(),
              '/register': (context) => const RegisterPage(),
              '/dashboard': (context) => const DashboardPage(),
              '/announcements': (context) => const AnnouncementsPage(),
              '/profile': (context) => const ProfilePage(),
              '/notifications': (context) => const NotificationsPage(),
            },
          ),
        );
      },
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    final rawName = settings.name ?? '';
    final uri = Uri.tryParse(rawName.startsWith('/') ? rawName : '/$rawName');
    final path = uri?.path.isNotEmpty == true ? uri!.path : '/';

    Widget page;
    switch (path) {
      case '/':
        page = widget.initiallyAuthenticated ? const DashboardPage() : const LoginPage();
        break;
      case '/login':
        page = const LoginPage();
        break;
      case '/register':
        page = const RegisterPage();
        break;
      case '/dashboard':
        page = const DashboardPage();
        break;
      case '/announcements':
        page = const AnnouncementsPage();
        break;
      case '/profile':
        page = const ProfilePage();
        break;
      case '/notifications':
        page = const NotificationsPage();
        break;
      default:
        page = widget.initiallyAuthenticated ? const DashboardPage() : const LoginPage();
    }

    return MaterialPageRoute(
      settings: RouteSettings(name: path, arguments: settings.arguments),
      builder: (_) => page,
    );
  }
}
