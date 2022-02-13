import 'dart:convert';

import 'package:http/http.dart' as http;

String base = "https://archimede.fumaz.dev";

Future<Map<String, dynamic>> get(String path) async {
  print("GET: $path");
  print('URI: ${Uri.parse(base + path)}');
  final response = await http.get(Uri.parse(base + path));
  print(response.body);
  return jsonDecode(response.body);
}
