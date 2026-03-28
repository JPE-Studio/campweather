import 'package:flutter/material.dart';

const Map<int, ({String description, String icon})> _wmoCodes = {
  0: (description: 'Klarer Himmel', icon: '☀️'),
  1: (description: 'Überwiegend klar', icon: '🌤️'),
  2: (description: 'Teilweise bewölkt', icon: '⛅'),
  3: (description: 'Bedeckt', icon: '☁️'),
  45: (description: 'Nebel', icon: '🌫️'),
  48: (description: 'Reifnebel', icon: '🌫️'),
  51: (description: 'Leichter Nieselregen', icon: '🌦️'),
  53: (description: 'Mäßiger Nieselregen', icon: '🌦️'),
  55: (description: 'Starker Nieselregen', icon: '🌧️'),
  61: (description: 'Leichter Regen', icon: '🌧️'),
  63: (description: 'Mäßiger Regen', icon: '🌧️'),
  65: (description: 'Starker Regen', icon: '🌧️'),
  71: (description: 'Leichter Schneefall', icon: '❄️'),
  73: (description: 'Mäßiger Schneefall', icon: '❄️'),
  75: (description: 'Starker Schneefall', icon: '❄️'),
  77: (description: 'Schneekörner', icon: '❄️'),
  80: (description: 'Leichte Regenschauer', icon: '🌦️'),
  81: (description: 'Mäßige Regenschauer', icon: '🌧️'),
  82: (description: 'Starke Regenschauer', icon: '🌧️'),
  85: (description: 'Leichte Schneeschauer', icon: '❄️'),
  86: (description: 'Starke Schneeschauer', icon: '❄️'),
  95: (description: 'Gewitter', icon: '⛈️'),
  96: (description: 'Gewitter mit Hagel', icon: '⛈️'),
  99: (description: 'Gewitter mit starkem Hagel', icon: '⛈️'),
};

({String description, String icon}) getWeatherInfo(int code) {
  return _wmoCodes[code] ?? (description: 'Unbekannt', icon: '❓');
}

Color getTemperatureColor(double temp) {
  if (temp <= -10) return const Color(0xFF0047AB);
  if (temp <= 0) return const Color(0xFF4169E1);
  if (temp <= 5) return const Color(0xFF6495ED);
  if (temp <= 10) return const Color(0xFF87CEEB);
  if (temp <= 15) return const Color(0xFF90EE90);
  if (temp <= 20) return const Color(0xFFFFD700);
  if (temp <= 25) return const Color(0xFFFFA500);
  if (temp <= 30) return const Color(0xFFFF6347);
  return const Color(0xFFDC143C);
}

