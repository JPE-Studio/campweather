import 'dart:convert';

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

  factory FavoriteLocation.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final name = json['name'];
    final latitude = json['latitude'];
    final longitude = json['longitude'];

    if (id is! String) throw const FormatException('FavoriteLocation.id is required');
    if (name is! String) throw const FormatException('FavoriteLocation.name is required');
    if (latitude is! num) throw const FormatException('FavoriteLocation.latitude is required');
    if (longitude is! num) throw const FormatException('FavoriteLocation.longitude is required');

    final country = json['country'];
    return FavoriteLocation(
      id: id,
      name: name,
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      country: country is String ? country : null,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        if (country != null) 'country': country,
      };
}

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

  factory DailyForecast.fromJson(Map<String, Object?> json) {
    final date = json['date'];
    final tempMax = json['tempMax'];
    final tempMin = json['tempMin'];
    final weatherCode = json['weatherCode'];
    final precipitationSum = json['precipitationSum'];
    final windSpeedMax = json['windSpeedMax'];

    if (date is! String) throw const FormatException('DailyForecast.date is required');
    if (tempMax is! num) throw const FormatException('DailyForecast.tempMax is required');
    if (tempMin is! num) throw const FormatException('DailyForecast.tempMin is required');
    if (weatherCode is! num) throw const FormatException('DailyForecast.weatherCode is required');
    if (precipitationSum is! num) throw const FormatException('DailyForecast.precipitationSum is required');
    if (windSpeedMax is! num) throw const FormatException('DailyForecast.windSpeedMax is required');

    return DailyForecast(
      date: date,
      tempMax: tempMax.toDouble(),
      tempMin: tempMin.toDouble(),
      weatherCode: weatherCode.toInt(),
      precipitationSum: precipitationSum.toDouble(),
      windSpeedMax: windSpeedMax.toDouble(),
    );
  }
}

class CurrentWeather {
  const CurrentWeather({
    required this.temperature,
    required this.weatherCode,
    required this.windSpeed,
  });

  final double temperature;
  final int weatherCode;
  final double windSpeed;

  factory CurrentWeather.fromJson(Map<String, Object?> json) {
    final temperature = json['temperature'];
    final weatherCode = json['weatherCode'];
    final windSpeed = json['windSpeed'];

    if (temperature is! num) throw const FormatException('CurrentWeather.temperature is required');
    if (weatherCode is! num) throw const FormatException('CurrentWeather.weatherCode is required');
    if (windSpeed is! num) throw const FormatException('CurrentWeather.windSpeed is required');

    return CurrentWeather(
      temperature: temperature.toDouble(),
      weatherCode: weatherCode.toInt(),
      windSpeed: windSpeed.toDouble(),
    );
  }
}

class WeatherData {
  const WeatherData({
    required this.current,
    required this.daily,
  });

  final CurrentWeather current;
  final List<DailyForecast> daily;

  factory WeatherData.fromJson(Map<String, Object?> json) {
    final current = json['current'];
    final daily = json['daily'];

    if (current is! Map) throw const FormatException('WeatherData.current is required');
    if (daily is! List) throw const FormatException('WeatherData.daily is required');

    return WeatherData(
      current: CurrentWeather.fromJson(current.cast<String, Object?>()),
      daily: daily
          .whereType<Map>()
          .map((e) => DailyForecast.fromJson(e.cast<String, Object?>()))
          .toList(growable: false),
    );
  }
}

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

  factory GeocodingResult.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final name = json['name'];
    final latitude = json['latitude'];
    final longitude = json['longitude'];

    if (id is! String) throw const FormatException('GeocodingResult.id is required');
    if (name is! String) throw const FormatException('GeocodingResult.name is required');
    if (latitude is! num) throw const FormatException('GeocodingResult.latitude is required');
    if (longitude is! num) throw const FormatException('GeocodingResult.longitude is required');

    final country = json['country'];
    final admin1 = json['admin1'];

    return GeocodingResult(
      id: id,
      name: name,
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      country: country is String ? country : null,
      admin1: admin1 is String ? admin1 : null,
    );
  }
}

List<FavoriteLocation> favoriteLocationsFromStorage(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is! List) return const [];
  return decoded
      .whereType<Map>()
      .map((e) => FavoriteLocation.fromJson(e.cast<String, Object?>()))
      .toList(growable: false);
}

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

