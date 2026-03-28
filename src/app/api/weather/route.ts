import { NextRequest, NextResponse } from "next/server";

const OPEN_METEO_BASE = "https://api.open-meteo.com/v1/forecast";
const GEOCODING_BASE = "https://geocoding-api.open-meteo.com/v1/search";

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const lat = searchParams.get("lat");
  const lon = searchParams.get("lon");

  if (!lat || !lon) {
    return NextResponse.json(
      { error: "Latitude and longitude are required" },
      { status: 400 }
    );
  }

  try {
    const url = `${OPEN_METEO_BASE}?latitude=${lat}&longitude=${lon}&current=temperature_2m,weather_code,wind_speed_10m&daily=temperature_2m_max,temperature_2m_min,weather_code,precipitation_sum,wind_speed_10m_max&forecast_days=7&timezone=auto`;
    const res = await fetch(url);
    const data = await res.json();

    return NextResponse.json({
      current: {
        temperature: data.current.temperature_2m,
        weatherCode: data.current.weather_code,
        windSpeed: data.current.wind_speed_10m,
      },
      daily: data.daily.time.map((date: string, i: number) => ({
        date,
        tempMax: data.daily.temperature_2m_max[i],
        tempMin: data.daily.temperature_2m_min[i],
        weatherCode: data.daily.weather_code[i],
        precipitationSum: data.daily.precipitation_sum[i],
        windSpeedMax: data.daily.wind_speed_10m_max[i],
      })),
    });
  } catch {
    return NextResponse.json(
      { error: "Failed to fetch weather data" },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const query = searchParams.get("q");

  if (!query) {
    return NextResponse.json(
      { error: "Query parameter 'q' is required" },
      { status: 400 }
    );
  }

  try {
    const url = `${GEOCODING_BASE}?name=${encodeURIComponent(query)}&count=5&language=de&format=json`;
    const res = await fetch(url);
    const data = await res.json();

    if (!data.results) {
      return NextResponse.json([]);
    }

    const results = data.results.map(
      (r: {
        id: number;
        name: string;
        latitude: number;
        longitude: number;
        country?: string;
        admin1?: string;
      }) => ({
        id: String(r.id),
        name: r.name,
        latitude: r.latitude,
        longitude: r.longitude,
        country: r.country,
        admin1: r.admin1,
      })
    );

    return NextResponse.json(results);
  } catch {
    return NextResponse.json(
      { error: "Failed to fetch geocoding data" },
      { status: 500 }
    );
  }
}
