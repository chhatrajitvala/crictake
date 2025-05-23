import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/create_team_screen.dart';
import 'screens/contest_screen.dart';
import 'screens/leaderboard_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crictake',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/create-team': (context) => const CreateTeamScreen(),
        '/contest': (context) => const ContestScreen(),
        '/leaderboard': (context) => const LeaderboardScreen(),
      },
    );
  }
}
