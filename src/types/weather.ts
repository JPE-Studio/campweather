export interface FavoriteLocation {
  id: string;
  name: string;
  latitude: number;
  longitude: number;
  country?: string;
}

export interface DailyForecast {
  date: string;
  tempMax: number;
  tempMin: number;
  weatherCode: number;
  precipitationSum: number;
  windSpeedMax: number;
}

export interface WeatherData {
  current: {
    temperature: number;
    weatherCode: number;
    windSpeed: number;
  };
  daily: DailyForecast[];
}

export interface GeocodingResult {
  id: string;
  name: string;
  latitude: number;
  longitude: number;
  country?: string;
  admin1?: string;
}
