const WMO_CODES: Record<number, { description: string; icon: string }> = {
  0: { description: "Klarer Himmel", icon: "\u2600\uFE0F" },
  1: { description: "Überwiegend klar", icon: "\uD83C\uDF24\uFE0F" },
  2: { description: "Teilweise bewölkt", icon: "\u26C5" },
  3: { description: "Bedeckt", icon: "\u2601\uFE0F" },
  45: { description: "Nebel", icon: "\uD83C\uDF2B\uFE0F" },
  48: { description: "Reifnebel", icon: "\uD83C\uDF2B\uFE0F" },
  51: { description: "Leichter Nieselregen", icon: "\uD83C\uDF26\uFE0F" },
  53: { description: "Mäßiger Nieselregen", icon: "\uD83C\uDF26\uFE0F" },
  55: { description: "Starker Nieselregen", icon: "\uD83C\uDF27\uFE0F" },
  61: { description: "Leichter Regen", icon: "\uD83C\uDF27\uFE0F" },
  63: { description: "Mäßiger Regen", icon: "\uD83C\uDF27\uFE0F" },
  65: { description: "Starker Regen", icon: "\uD83C\uDF27\uFE0F" },
  71: { description: "Leichter Schneefall", icon: "\u2744\uFE0F" },
  73: { description: "Mäßiger Schneefall", icon: "\u2744\uFE0F" },
  75: { description: "Starker Schneefall", icon: "\u2744\uFE0F" },
  77: { description: "Schneekörner", icon: "\u2744\uFE0F" },
  80: { description: "Leichte Regenschauer", icon: "\uD83C\uDF26\uFE0F" },
  81: { description: "Mäßige Regenschauer", icon: "\uD83C\uDF27\uFE0F" },
  82: { description: "Starke Regenschauer", icon: "\uD83C\uDF27\uFE0F" },
  85: { description: "Leichte Schneeschauer", icon: "\u2744\uFE0F" },
  86: { description: "Starke Schneeschauer", icon: "\u2744\uFE0F" },
  95: { description: "Gewitter", icon: "\u26C8\uFE0F" },
  96: { description: "Gewitter mit Hagel", icon: "\u26C8\uFE0F" },
  99: { description: "Gewitter mit starkem Hagel", icon: "\u26C8\uFE0F" },
};

export function getWeatherInfo(code: number) {
  return WMO_CODES[code] ?? { description: "Unbekannt", icon: "\u2753" };
}

export function getTemperatureColor(temp: number): string {
  if (temp <= -10) return "#0047AB";
  if (temp <= 0) return "#4169E1";
  if (temp <= 5) return "#6495ED";
  if (temp <= 10) return "#87CEEB";
  if (temp <= 15) return "#90EE90";
  if (temp <= 20) return "#FFD700";
  if (temp <= 25) return "#FFA500";
  if (temp <= 30) return "#FF6347";
  return "#DC143C";
}
