import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'character.dart';

class CharacterStorage {
  static const _key = 'character_v1';

  Future<void> save(Character c) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(c.toJson());
    await prefs.setString(_key, jsonStr);
  }

  Future<Character?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    final map = jsonDecode(jsonStr);
    if (map is! Map<String, dynamic>) return null;
    return Character.fromJson(map);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
