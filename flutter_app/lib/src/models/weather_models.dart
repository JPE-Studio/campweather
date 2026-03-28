import 'dart:convert';

import 'package:flutter/foundation.dart';

@immutable
class FavoriteLocation {
  const FavoriteLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? country;

  factory FavoriteLocation.fromJson(Map<String, dynamic> json) {
    return FavoriteLocation(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
    };
  }
}

@immutable
class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.weatherCode,
    required this.precipitationSum,
    required this.windSpeedMax,
  });

  final String date;
  final double tempMax;
  final double tempMin;
  final int weatherCode;
  final double precipitationSum;
  final double windSpeedMax;

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: json['date'] as String,
      tempMax: (json['tempMax'] as num).toDouble(),
      tempMin: (json['tempMin'] as num).toDouble(),
      weatherCode: (json['weatherCode'] as num).toInt(),
      precipitationSum: (json['precipitationSum'] as num).toDouble(),
      windSpeedMax: (json['windSpeedMax'] as num).toDouble(),
    );
  }
}

@immutable
class WeatherData {
  const WeatherData({
    required this.current,
    required this.daily,
  });

  final CurrentWeather current;
  final List<DailyForecast> daily;

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      current: CurrentWeather.fromJson(json['current'] as Map<String, dynamic>),
      daily: (json['daily'] as List<dynamic>)
          .map((item) => DailyForecast.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

@immutable
class CurrentWeather {
  const CurrentWeather({
    required this.temperature,
    required this.weatherCode,
    required this.windSpeed,
  });

  final double temperature;
  final int weatherCode;
  final double windSpeed;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature'] as num).toDouble(),
      weatherCode: (json['weatherCode'] as num).toInt(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
    );
  }
}

@immutable
class GeocodingResult {
  const GeocodingResult({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? admin1;

  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    return GeocodingResult(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String?,
      admin1: json['admin1'] as String?,
    );
  }
}

List<FavoriteLocation> favoriteLocationsFromStorage(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is! List) return const [];
  return decoded
      .whereType<Map>()
      .map((e) => FavoriteLocation.fromJson(e.cast<String, dynamic>()))
      .toList(growable: false);
}

