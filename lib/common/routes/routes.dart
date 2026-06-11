import 'package:chitchat/common/models/user_model.dart';
import 'package:chitchat/feature/auth/pages/login_page.dart';
import 'package:chitchat/feature/auth/pages/user_info_page.dart';
import 'package:chitchat/feature/auth/pages/verification_page.dart';
import 'package:chitchat/feature/chat/pages/chat_page.dart';
import 'package:chitchat/feature/chat/pages/profile_page.dart';
import 'package:chitchat/feature/contact/pages/contact_page.dart';
import 'package:chitchat/feature/group/pages/group_page.dart';
import 'package:chitchat/feature/home/pages/home_page.dart';
import 'package:chitchat/feature/welcome/pages/welcome_page.dart';
import 'package:chitchat/feature/call/screens/call_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class Routes {
  static const String welcome = 'welcome';
  static const String login = 'login';
  static const String verification = 'verification';
  static const String userInfo = 'user-info';
  static const String home = 'home';
  static const String contact = 'contact';
  static const String chat = 'chat';
  static const String profile = 'profile';
  static const String group = 'group';
  static const String call = 'call';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(
          builder: (context) => const WelcomePage(),
        );

      case login:
        return MaterialPageRoute(
          builder: (context) => const LoginPage(),
        );

      case verification:
        final args = settings.arguments as Map;
        return MaterialPageRoute(
          builder: (context) => VerificationPage(
            smsCodeId: args['smsCodeId'],
            phoneNumber: args['phoneNumber'],
          ),
        );

      case userInfo:
        final String? profileImageUrl = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => UserInfoPage(
            profileImageUrl: profileImageUrl,
          ),
        );

      case home:
        return MaterialPageRoute(
          builder: (context) => const HomePage(),
        );

      case contact:
        return MaterialPageRoute(
          builder: (context) => const ContactPage(),
        );

      case chat:
        final user = settings.arguments;
        if (user is UserModel) {
          return MaterialPageRoute(
            builder: (context) => ChatPage(
              user: user,
              uid: user.uid,
              profileImageUrl: user.profileImageUrl,
            ),
          );
        } else {
          return _errorRoute("Invalid arguments for ChatPage");
        }

      case profile:
        final UserModel user = settings.arguments as UserModel;
        return PageTransition(
          child: ProfilePage(user: user),
          type: PageTransitionType.fade,
          duration: const Duration(milliseconds: 250),
        );

      case group:
        return MaterialPageRoute(
          builder: (context) => const GroupPage(),
        );

      case call:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null &&
            args['channelId'] != null &&
            args['call'] != null &&
            args['isGroupChat'] != null) {
          return MaterialPageRoute(
            builder: (context) => CallScreen(
              channelId: args['channelId'],
              call: args['call'],
              isGroupChat: args['isGroupChat'],
            ),
          );
        } else {
          return _errorRoute("Invalid arguments for CallScreen");
        }

      default:
        return _errorRoute("No route defined for ${settings.name}");
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(
          child: Text(
            message,
            style: const TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
