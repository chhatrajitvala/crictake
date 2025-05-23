import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "https://crictake-backend.onrender.com/api";

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> getHeaders({bool auth = false}) async {
    final headers = {"Content-Type": "application/json"};
    if (auth) {
      final token = await getToken();
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
    }
    return headers;
  }

  static Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    return await http.post(
      url,
      headers: await getHeaders(),
      body: jsonEncode({"email": email, "password": password}),
    );
  }

  static Future<http.Response> register(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/register');
    return await http.post(
      url,
      headers: await getHeaders(),
      body: jsonEncode({"email": email, "password": password}),
    );
  }

  static Future<http.Response> getMatches() async {
    final url = Uri.parse('$baseUrl/matches/list');
    return await http.get(url, headers: await getHeaders(auth: true));
  }

  static Future<http.Response> createTeam(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/teams/create');
    return await http.post(
      url,
      headers: await getHeaders(auth: true),
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> getTeams(String userId) async {
    final url = Uri.parse('$baseUrl/teams/user/$userId');
    return await http.get(url, headers: await getHeaders(auth: true));
  }

  static Future<http.Response> joinContest(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/contests/join');
    return await http.post(
      url,
      headers: await getHeaders(auth: true),
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> getUserContests(String userId) async {
    final url = Uri.parse('$baseUrl/contests/user/$userId');
    return await http.get(url, headers: await getHeaders(auth: true));
  }

  static Future<http.Response> getLeaderboard(String matchId) async {
    final url = Uri.parse('$baseUrl/leaderboard/$matchId');
    return await http.get(url, headers: await getHeaders());
  }
}
