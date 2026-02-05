import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/story_service.dart';
import 'services/favorite_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/admin/admin_main_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => StoryService()),
        ChangeNotifierProvider(create: (_) => FavoriteService()),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          return MaterialApp(
            title: 'Audio Story',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            home: _buildHome(authService),
          );
        },
      ),
    );
  }

  Widget _buildHome(AuthService authService) {
    if (!authService.isAuthenticated) {
      return const LoginScreen();
    }
    
    if (authService.isAdmin) {
      return const AdminMainScreen();
    }
    
    return const MainScreen();
  }
}
