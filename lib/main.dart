import 'package:chitchat/common/routes/routes.dart';
import 'package:chitchat/common/theme/dark_theme.dart';
import 'package:chitchat/common/theme/light_theme.dart';
import 'package:chitchat/feature/auth/controller/auth_controller.dart';
import 'package:chitchat/feature/auth/pages/user_info_page.dart';
import 'package:chitchat/feature/contact/pages/contact_page.dart';
import 'package:chitchat/feature/home/pages/home_page.dart';
import 'package:chitchat/feature/welcome/pages/welcome_page.dart';
import 'package:chitchat/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChitChat',
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: ThemeMode.system,
      home: ref.watch(userInfoAuthProvider).when(
        data: (user) {
          FlutterNativeSplash.remove();
          if (user == null) return const WelcomePage();
          return const HomePage();
        },
        error: (error, trace) {
          return const Scaffold(
            body: Center(
              child: Text('Something wrong happened!'),
            ),
          );
        },
        loading: () {
          return const SizedBox();
        },
        //loading: () {
        //return Scaffold(
        //body: Center(
        //child: Builder(
        //builder: (context) {
        //final isDarkMode =
        //Theme.of(context).brightness == Brightness.dark;

        //final logoPath = isDarkMode
        //? 'assets/images/splash_dark.png'
        //: 'assets/images/splash_light.png';

        //return Image.asset(
        //logoPath,
        //key: ValueKey(logoPath),
        //width: 100,
        //height: 100,
        //fit: BoxFit.contain, // Görüntü stili
        //);
        //},
        //),
        //),
        //);
        //},
      ),
      onGenerateRoute: Routes.onGenerateRoute,
    );
  }
}
