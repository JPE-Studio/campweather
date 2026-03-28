import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/weather_models.dart';

const String _favoritesStorageKey = 'weather-favorites';

class FavoritesRepository {
  const FavoritesRepository(this._prefs);

  final SharedPreferences _prefs;

  List<FavoriteLocation> load() {
    final raw = _prefs.getString(_favoritesStorageKey);
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      return decoded
          .whereType<Map>()
          .map((e) => FavoriteLocation.fromJson(e.cast<String, Object?>()))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(List<FavoriteLocation> items) async {
    final raw = jsonEncode(items.map((e) => e.toJson()).toList(growable: false));
    await _prefs.setString(_favoritesStorageKey, raw);
  }

  Future<List<FavoriteLocation>> add(FavoriteLocation location) async {
    final current = load();
    if (current.any((f) => f.id == location.id)) return current;

    final next = [...current, location];
    await save(next);
    return next;
  }

  Future<List<FavoriteLocation>> remove(String id) async {
    final current = load();
    final next = current.where((f) => f.id != id).toList(growable: false);
    await save(next);
    return next;
  }
}

Future<FavoritesRepository> createFavoritesRepository() async {
  final prefs = await SharedPreferences.getInstance();
  return FavoritesRepository(prefs);
}

