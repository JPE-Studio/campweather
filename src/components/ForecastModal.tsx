"use client";

import { FavoriteLocation, WeatherData } from "@/types/weather";
import { getWeatherInfo } from "@/lib/weatherUtils";

interface ForecastModalProps {
  favorite: FavoriteLocation;
  weather: WeatherData | null;
  onClose: () => void;
}

const DAY_NAMES = ["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"];

function formatDate(dateStr: string) {
  const d = new Date(dateStr + "T00:00:00");
  const dayName = DAY_NAMES[d.getDay()];
  const day = d.getDate().toString().padStart(2, "0");
  const month = (d.getMonth() + 1).toString().padStart(2, "0");
  return `${dayName}, ${day}.${month}.`;
}

export default function ForecastModal({
  favorite,
  weather,
  onClose,
}: ForecastModalProps) {
  return (
    <div
      className="fixed inset-0 bg-black/50 flex items-center justify-center z-[2000]"
      onClick={onClose}
    >
      <div
        className="bg-white rounded-xl shadow-2xl w-full max-w-lg mx-4 overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="bg-gradient-to-r from-blue-600 to-blue-800 text-white px-4 py-3 flex items-center justify-between">
          <div>
            <h2 className="font-bold">{favorite.name}</h2>
            {favorite.country && (
              <p className="text-blue-200 text-xs">{favorite.country}</p>
            )}
          </div>
          <button
            onClick={onClose}
            className="text-white/80 hover:text-white text-xl leading-none"
          >
            ✕
          </button>
        </div>

        <div className="p-4">
          {!weather ? (
            <div className="text-center py-8 text-gray-500">
              Wetterdaten werden geladen...
            </div>
          ) : (
            <>
              <div className="flex items-center justify-between mb-4 p-3 bg-blue-50 rounded-lg">
                <div>
                  <div className="text-xs text-gray-500">Aktuell</div>
                  <div className="text-3xl font-bold text-blue-800">
                    {Math.round(weather.current.temperature)}°C
                  </div>
                </div>
                <div className="text-right">
                  <div className="text-3xl">
                    {getWeatherInfo(weather.current.weatherCode).icon}
                  </div>
                  <div className="text-xs text-gray-600">
                    {getWeatherInfo(weather.current.weatherCode).description}
                  </div>
                </div>
              </div>

              <h3 className="font-semibold text-sm text-gray-700 mb-2">
                7-Tage-Vorhersage
              </h3>

              <div className="space-y-1">
                {weather.daily.map((day, i) => {
                  const info = getWeatherInfo(day.weatherCode);
                  return (
                    <div
                      key={day.date}
                      className={`flex items-center justify-between px-3 py-2 rounded-lg ${
                        i === 0 ? "bg-blue-50" : "hover:bg-gray-50"
                      }`}
                    >
                      <div className="flex items-center gap-3 w-28">
                        <span className="text-sm font-medium">
                          {i === 0 ? "Heute" : formatDate(day.date)}
                        </span>
                      </div>
                      <div className="flex items-center gap-2">
                        <span className="text-lg">{info.icon}</span>
                        <span className="text-xs text-gray-500 w-24 hidden sm:inline">
                          {info.description}
                        </span>
                      </div>
                      <div className="flex items-center gap-1 text-sm">
                        <span className="font-bold text-red-500">
                          {Math.round(day.tempMax)}°
                        </span>
                        <span className="text-gray-400">/</span>
                        <span className="text-blue-500">
                          {Math.round(day.tempMin)}°
                        </span>
                      </div>
                    </div>
                  );
                })}
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
