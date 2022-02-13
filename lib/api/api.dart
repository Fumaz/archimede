import 'dart:convert';

import 'package:http/http.dart' as http;

String base = "https://archimede.fumaz.dev";

Future<Map<String, dynamic>> get(String path) async {
  final response = await http.get(Uri.parse(base + path));
  return jsonDecode(response.body);
}
