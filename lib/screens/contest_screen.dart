import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ContestScreen extends StatefulWidget {
  const ContestScreen({Key? key}) : super(key: key);

  @override
  State<ContestScreen> createState() => _ContestScreenState();
}

class _ContestScreenState extends State<ContestScreen> {
  List contests = [];
  String matchId = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args != null && args.containsKey('matchId')) {
      matchId = args['matchId'];
      fetchContests();
    }
  }

  Future<void> fetchContests() async {
    // Static dummy contest
    setState(() {
      contests = [
        {"name": "Grand League", "entryFee": 50, "prize": 500},
        {"name": "Small League", "entryFee": 20, "prize": 200},
        {"name": "Practice Contest", "entryFee": 0, "prize": 0}
      ];
    });
  }

  Future<void> joinContest(Map contest) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');

    final response = await http.post(
      Uri.parse('https://crictake-backend.onrender.com/contests/join'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'matchId': matchId,
        'userId': userId,
        'contestName': contest['name'],
        'entryFee': contest['entryFee'],
        'prize': contest['prize'],
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joined ${contest['name']} successfully')),
      );
      Navigator.pushNamed(context, '/leaderboard', arguments: {'matchId': matchId});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to join contest')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contests")),
      body: ListView.builder(
        itemCount: contests.length,
        itemBuilder: (context, index) {
          final contest = contests[index];
          return ListTile(
            title: Text(contest['name']),
            subtitle: Text('Fee: ₹${contest['entryFee']}  Prize: ₹${contest['prize']}'),
            trailing: ElevatedButton(
              onPressed: () => joinContest(contest),
              child: const Text("Join"),
            ),
          );
        },
      ),
    );
  }
}
