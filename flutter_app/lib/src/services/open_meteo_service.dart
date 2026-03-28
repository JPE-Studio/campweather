import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather_models.dart';

class OpenMeteoService {
  OpenMeteoService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _forecastBase = 'https://api.open-meteo.com/v1/forecast';
  static const String _geocodingBase =
      'https://geocoding-api.open-meteo.com/v1/search';

  Future<WeatherData> fetchForecast({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(_forecastBase).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': 'temperature_2m,weather_code,wind_speed_10m',
        'daily':
            'temperature_2m_max,temperature_2m_min,weather_code,precipitation_sum,wind_speed_10m_max',
        'forecast_days': '7',
        'timezone': 'auto',
      },
    );

    final res = await _client.get(uri, headers: const {'accept': 'application/json'});
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Forecast request failed (${res.statusCode})');
    }

    final dynamic jsonBody = jsonDecode(res.body);
    if (jsonBody is! Map<String, dynamic>) {
      throw Exception('Unexpected forecast response');
    }

    final current = jsonBody['current'];
    final daily = jsonBody['daily'];
    if (current is! Map<String, dynamic> || daily is! Map<String, dynamic>) {
      throw Exception('Malformed forecast response');
    }

    final time = daily['time'];
    final maxTemps = daily['temperature_2m_max'];
    final minTemps = daily['temperature_2m_min'];
    final weatherCodes = daily['weather_code'];
    final precipSums = daily['precipitation_sum'];
    final windMax = daily['wind_speed_10m_max'];

    if (time is! List ||
        maxTemps is! List ||
        minTemps is! List ||
        weatherCodes is! List ||
        precipSums is! List ||
        windMax is! List) {
      throw Exception('Malformed daily forecast arrays');
    }

    final dailyForecasts = <DailyForecast>[];
    for (var i = 0; i < time.length; i++) {
      dailyForecasts.add(
        DailyForecast(
          date: (time[i] as Object).toString(),
          tempMax: (maxTemps[i] as num).toDouble(),
          tempMin: (minTemps[i] as num).toDouble(),
          weatherCode: (weatherCodes[i] as num).toInt(),
          precipitationSum: (precipSums[i] as num).toDouble(),
          windSpeedMax: (windMax[i] as num).toDouble(),
        ),
      );
    }

    return WeatherData(
      current: WeatherCurrent(
        temperature: (current['temperature_2m'] as num).toDouble(),
        weatherCode: (current['weather_code'] as num).toInt(),
        windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      ),
      daily: dailyForecasts,
    );
  }

  Future<List<GeocodingResult>> searchPlaces({
    required String query,
    int count = 5,
    String language = 'de',
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final uri = Uri.parse(_geocodingBase).replace(
      queryParameters: {
        'name': trimmed,
        'count': count.toString(),
        'language': language,
        'format': 'json',
      },
    );

    final res = await _client.get(uri, headers: const {'accept': 'application/json'});
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Geocoding request failed (${res.statusCode})');
    }

    final dynamic jsonBody = jsonDecode(res.body);
    if (jsonBody is! Map<String, dynamic>) {
      throw Exception('Unexpected geocoding response');
    }

    final results = jsonBody['results'];
    if (results is! List) return [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(
          (r) => GeocodingResult(
            id: (r['id'] as Object).toString(),
            name: (r['name'] as Object).toString(),
            latitude: (r['latitude'] as num).toDouble(),
            longitude: (r['longitude'] as num).toDouble(),
            country: (r['country'] as Object?)?.toString(),
            admin1: (r['admin1'] as Object?)?.toString(),
          ),
        )
        .toList(growable: false);
  }
}

