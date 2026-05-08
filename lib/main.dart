import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'providers/story_provider.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/add_story_screen.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final GoRouter router = GoRouter(
            debugLogDiagnostics: true,
            refreshListenable: auth,
            initialLocation: '/',
            redirect: (context, state) {
              final bool loggedIn = auth.isLogin;
              final bool isAuthPage =
                  state.uri.path == '/login' || state.uri.path == '/register';

              if (!loggedIn && !isAuthPage) {
                return '/login';
              }

              if (loggedIn && isAuthPage) {
                return '/';
              }

              return null;
            },
            routes: [
              GoRoute(
                path: '/login',
                pageBuilder: (context, state) => _buildTransitionPage(
                  child: const LoginScreen(),
                  state: state,
                ),
              ),
              GoRoute(
                path: '/register',
                pageBuilder: (context, state) => _buildTransitionPage(
                  child: const RegisterScreen(),
                  state: state,
                ),
              ),
              GoRoute(
                path: '/',
                pageBuilder: (context, state) => _buildTransitionPage(
                  child: const HomeScreen(),
                  state: state,
                ),
              ),
              GoRoute(
                path: '/detail',
                pageBuilder: (context, state) {
                  final story = state.extra as dynamic;

                  return _buildTransitionPage(
                    child: DetailScreen(story: story),
                    state: state,
                  );
                },
              ),
              GoRoute(
                path: '/add',
                pageBuilder: (context, state) => _buildTransitionPage(
                  child: const AddStoryScreen(),
                  state: state,
                ),
              ),
            ],
          );

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,

            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            supportedLocales: const [Locale('en'), Locale('id')],

            routerConfig: router,

            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.deepPurple,
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF5F7FB),

              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black,
              ),

              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: Colors.deepPurple,
                    width: 1.5,
                  ),
                ),
              ),

              cardTheme: CardThemeData(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static CustomTransitionPage _buildTransitionPage({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
