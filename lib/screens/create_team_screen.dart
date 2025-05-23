import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({Key? key}) : super(key: key);

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  List<Map<String, dynamic>> players = [];
  List<String> selectedPlayerIds = [];
  bool isLoading = true;
  String matchId = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args != null && args.containsKey('matchId')) {
      matchId = args['matchId'];
      fetchPlayers();
    }
  }

  Future<void> fetchPlayers() async {
    await Future.delayed(const Duration(seconds: 1)); // simulate fetching
    setState(() {
      players = List.generate(11, (index) {
        return {
          'playerId': 'P$index',
          'name': 'Player $index',
          'role': index < 4
              ? 'Batsman'
              : index < 8
                  ? 'Bowler'
                  : 'All-rounder'
        };
        // In production, replace with actual API call to get match players
      });
      isLoading = false;
    });
  }

  Future<void> createTeam() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final selectedPlayers = players
        .where((p) => selectedPlayerIds.contains(p['playerId']))
        .toList();

    final response = await http.post(
      Uri.parse('https://crictake-backend.onrender.com/teams/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'matchId': matchId,
        'players': selectedPlayers,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Team created successfully')),
      );
      Navigator.pushNamed(context, '/contest', arguments: {'matchId': matchId});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create team')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Create Team')),
      body: ListView(
        children: players.map((player) {
          final isSelected = selectedPlayerIds.contains(player['playerId']);
          return CheckboxListTile(
            title: Text(player['name']),
            subtitle: Text(player['role']),
            value: isSelected,
            onChanged: (selected) {
              setState(() {
                if (selected!) {
                  selectedPlayerIds.add(player['playerId']);
                } else {
                  selectedPlayerIds.remove(player['playerId']);
                }
              });
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: selectedPlayerIds.length == 11 ? createTeam : null,
        label: const Text('Submit Team'),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
