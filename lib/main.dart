import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toramonline/firebase_options.dart';

import 'app_shell/app_shell_page.dart';
import 'critical_simulator_page/critical_simulator_page.dart';
import 'login_builds_page/login_screen.dart';
import 'shared/app_theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _ensureIconFontsLoaded();
  await AppThemeController.instance.load();

  runApp(const MyApp());
}

Future<void> _ensureIconFontsLoaded() async {
  try {
    final ByteData materialIcons = await rootBundle.load(
      'assets/fonts/MaterialIcons-Regular.otf',
    );
    final FontLoader materialLoader = FontLoader('MaterialIcons')
      ..addFont(Future<ByteData>.value(materialIcons));
    await materialLoader.load();
  } catch (_) {
    // Keep running with default font loading path.
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AppThemeController themeController = AppThemeController.instance;
    return AnimatedBuilder(
      animation: themeController,
      builder: (BuildContext context, _) {
        final ThemeData darkBase = ThemeData.dark(useMaterial3: true);
        final ThemeData lightBase = ThemeData.light(useMaterial3: true);

        final TextTheme darkTextTheme = GoogleFonts.notoSansThaiTextTheme(
          darkBase.textTheme,
        );
        final TextTheme darkPrimaryTextTheme =
            GoogleFonts.notoSansThaiTextTheme(darkBase.primaryTextTheme);
        final TextTheme lightTextTheme = GoogleFonts.notoSansThaiTextTheme(
          lightBase.textTheme,
        );
        final TextTheme lightPrimaryTextTheme =
            GoogleFonts.notoSansThaiTextTheme(lightBase.primaryTextTheme);

        final ThemeData darkTheme = darkBase.copyWith(
          scaffoldBackgroundColor: const Color(0xFF000000),
          textTheme: darkTextTheme,
          primaryTextTheme: darkPrimaryTextTheme,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF000000),
            foregroundColor: Colors.white,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        );
        final ThemeData lightTheme = lightBase.copyWith(
          scaffoldBackgroundColor: const Color(0xFFFFFFFF),
          textTheme: lightTextTheme,
          primaryTextTheme: lightPrimaryTextTheme,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFFFFFF),
            foregroundColor: Colors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        );

        return MaterialApp(
          title: 'Toram Build Simulator',
          debugShowCheckedModeBanner: false,
          routes: <String, WidgetBuilder>{
            '/login': (_) => const LoginScreen(),
            '/app': (_) => const AppShellScreen(),
            '/critical-simulator': (_) => const CriticalSimulatorPage(),
          },
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeController.themeMode,
          home: const FirebaseBootstrapGate(),
        );
      },
    );
  }
}

class FirebaseBootstrapGate extends StatefulWidget {
  const FirebaseBootstrapGate({super.key});

  @override
  State<FirebaseBootstrapGate> createState() => _FirebaseBootstrapGateState();
}

class _FirebaseBootstrapGateState extends State<FirebaseBootstrapGate> {
  late final Future<bool> _initializeFuture;
  bool _openWithoutAuth = false;

  @override
  void initState() {
    super.initState();
    _initializeFuture = _initializeFirebase();
  }

  Future<bool> _initializeFirebase() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_openWithoutAuth) {
      return const AppShellScreen();
    }

    return FutureBuilder<bool>(
      future: _initializeFuture,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoadingScreen();
        }

        if (snapshot.data == true) {
          return const AuthGate();
        }

        return _FirebaseMissingConfigScreen(
          onOpenWithoutAuth: () {
            setState(() {
              _openWithoutAuth = true;
            });
          },
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        if (snapshot.data != null) {
          return const AppShellScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      ),
    );
  }
}

class _FirebaseMissingConfigScreen extends StatelessWidget {
  const _FirebaseMissingConfigScreen({required this.onOpenWithoutAuth});

  final VoidCallback onOpenWithoutAuth;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color borderColor = colorScheme.onSurface.withValues(alpha: 0.18);
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 640),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Firebase is not configured',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(
                  'Login and register require Firebase configuration. '
                  'Add your Firebase project files, then restart the app.',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.75),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                const _SetupStepText(text: '1. Run: flutterfire configure'),
                const _SetupStepText(
                  text: '2. Ensure firebase_options.dart is generated in lib/',
                ),
                const _SetupStepText(
                  text: '3. Keep platform config files in Android/iOS folders',
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: onOpenWithoutAuth,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurface,
                    side: BorderSide(color: borderColor),
                    minimumSize: const Size.fromHeight(46),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Open simulator without login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupStepText extends StatelessWidget {
  const _SetupStepText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}
