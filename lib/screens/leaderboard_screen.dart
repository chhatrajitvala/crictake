import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List leaderboard = [];
  String matchId = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args != null && args.containsKey('matchId')) {
      matchId = args['matchId'];
      fetchLeaderboard();
    }
  }

  Future<void> fetchLeaderboard() async {
    final response = await http.get(
      Uri.parse('https://crictake-backend.onrender.com/leaderboard/$matchId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        leaderboard = data['leaderboard'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch leaderboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: leaderboard.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final entry = leaderboard[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(entry['email'] ?? 'Unknown'),
                  subtitle: Text('Points: ${entry['points']}'),
                );
              },
            ),
    );
  }
}
