"use client";

import { useEffect, useState, useCallback } from "react";
import dynamic from "next/dynamic";
import { FavoriteLocation, WeatherData, GeocodingResult } from "@/types/weather";
import { useFavorites } from "@/hooks/useFavorites";
import AddFavoriteModal from "@/components/AddFavoriteModal";
import ForecastModal from "@/components/ForecastModal";
import DaySlider from "@/components/DaySlider";

const WeatherMap = dynamic(() => import("@/components/WeatherMap"), {
  ssr: false,
  loading: () => (
    <div className="flex-1 flex items-center justify-center bg-gray-100">
      <p className="text-gray-500">Karte wird geladen...</p>
    </div>
  ),
});

export default function WeatherApp() {
  const { favorites, addFavorite, removeFavorite } = useFavorites();
  const [weatherCache, setWeatherCache] = useState<Record<string, WeatherData>>({});
  const [selectedDay, setSelectedDay] = useState(0);
  const [showAddModal, setShowAddModal] = useState(false);
  const [selectedFavorite, setSelectedFavorite] = useState<FavoriteLocation | null>(null);

  const fetchWeather = useCallback(async (fav: FavoriteLocation) => {
    try {
      const res = await fetch(
        `/api/weather?lat=${fav.latitude}&lon=${fav.longitude}`
      );
      const data = await res.json();
      if (!data.error) {
        setWeatherCache((prev) => ({ ...prev, [fav.id]: data }));
      }
    } catch {
      // silently fail
    }
  }, []);

  useEffect(() => {
    favorites.forEach((fav) => {
      fetchWeather(fav);
    });
  }, [favorites, fetchWeather]);

  const handleAddFavorite = (result: GeocodingResult) => {
    addFavorite({
      id: result.id,
      name: result.name,
      latitude: result.latitude,
      longitude: result.longitude,
      country: result.country,
    });
  };

  const handleMarkerClick = (fav: FavoriteLocation) => {
    setSelectedFavorite(fav);
  };

  return (
    <div className="h-screen flex flex-col bg-gray-50">
      <header className="bg-gradient-to-r from-blue-600 to-blue-800 text-white px-4 py-3 shadow-lg z-10">
        <div className="flex items-center justify-between max-w-7xl mx-auto">
          <h1 className="text-xl font-bold">Wetterkarte</h1>
          <div className="flex gap-2">
            <button
              onClick={() => setShowAddModal(true)}
              className="bg-white/20 hover:bg-white/30 px-4 py-2 rounded-lg text-sm font-medium transition-colors"
            >
              + Favorit hinzufügen
            </button>
          </div>
        </div>
      </header>

      <div style={{ flex: 1, position: "relative", minHeight: 0 }}>
        <WeatherMap
          favorites={favorites}
          weatherCache={weatherCache}
          selectedDay={selectedDay}
          onMarkerClick={handleMarkerClick}
          onRemoveFavorite={removeFavorite}
        />

        <div className="absolute bottom-4 left-4 right-4 z-[1000]">
          <DaySlider selectedDay={selectedDay} onChange={setSelectedDay} />
        </div>
      </div>

      {showAddModal && (
        <AddFavoriteModal
          onAdd={handleAddFavorite}
          onClose={() => setShowAddModal(false)}
          existingIds={favorites.map((f) => f.id)}
        />
      )}

      {selectedFavorite && (
        <ForecastModal
          favorite={selectedFavorite}
          weather={weatherCache[selectedFavorite.id] ?? null}
          onClose={() => setSelectedFavorite(null)}
        />
      )}
    </div>
  );
}
