"use client";

import { MapContainer, TileLayer, Marker, Popup, useMap } from "react-leaflet";
import L from "leaflet";
import { FavoriteLocation, WeatherData } from "@/types/weather";
import { getTemperatureColor, getWeatherInfo } from "@/lib/weatherUtils";
import { useEffect } from "react";
import "leaflet/dist/leaflet.css";

interface WeatherMapProps {
  favorites: FavoriteLocation[];
  weatherCache: Record<string, WeatherData>;
  selectedDay: number;
  onMarkerClick: (fav: FavoriteLocation) => void;
  onRemoveFavorite: (id: string) => void;
}

function createTempIcon(temp: number, weatherCode: number, isSelected: boolean): L.DivIcon {
  const color = getTemperatureColor(temp);
  const border = isSelected ? "3px solid #1d4ed8" : "2px solid rgba(0,0,0,0.2)";
  const size = isSelected ? 64 : 56;
  const { icon } = getWeatherInfo(weatherCode);

  return L.divIcon({
    className: "temp-marker",
    html: `<div style="
      background: ${color};
      color: white;
      font-weight: bold;
      width: ${size}px;
      border-radius: 12px;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      border: ${border};
      box-shadow: 0 2px 8px rgba(0,0,0,0.3);
      cursor: pointer;
      transition: transform 0.2s;
      padding: 2px 0;
      line-height: 1;
    "><span style="font-size:${isSelected ? 20 : 16}px">${icon}</span><span style="font-size:${isSelected ? 15 : 13}px">${Math.round(temp)}°</span></div>`,
    iconSize: [size, size + 8],
    iconAnchor: [size / 2, (size + 8) / 2],
  });
}

function FitBounds({ favorites }: { favorites: FavoriteLocation[] }) {
  const map = useMap();

  useEffect(() => {
    setTimeout(() => map.invalidateSize(), 100);
    setTimeout(() => map.invalidateSize(), 500);
  }, [map]);

  useEffect(() => {
    if (favorites.length === 0) {
      map.setView([51.1657, 10.4515], 5);
      return;
    }
    if (favorites.length === 1) {
      map.setView([favorites[0].latitude, favorites[0].longitude], 8);
      return;
    }
    const bounds = L.latLngBounds(
      favorites.map((f) => [f.latitude, f.longitude] as [number, number])
    );
    map.fitBounds(bounds, { padding: [50, 50] });
  }, [favorites, map]);

  return null;
}

export default function WeatherMap({
  favorites,
  weatherCache,
  selectedDay,
  onMarkerClick,
  onRemoveFavorite,
}: WeatherMapProps) {
  return (
    <MapContainer
      center={[51.1657, 10.4515]}
      zoom={5}
      style={{ height: "100%", width: "100%", position: "absolute", top: 0, left: 0, right: 0, bottom: 0 }}
    >
      <TileLayer
        attribution='&copy; <a href="https://carto.com/">CARTO</a> &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
        url="https://{s}.basemaps.carto.com/rastertiles/voyager/{z}/{x}/{y}{r}.png"
      />
      <FitBounds favorites={favorites} />

      {favorites.map((fav) => {
        const weather = weatherCache[fav.id];
        let temp: number;
        let weatherCode = 0;

        if (weather) {
          if (selectedDay === 0) {
            temp = weather.current.temperature;
            weatherCode = weather.current.weatherCode;
          } else {
            const day = weather.daily[selectedDay];
            if (day) {
              temp = (day.tempMax + day.tempMin) / 2;
              weatherCode = day.weatherCode;
            } else {
              temp = weather.current.temperature;
              weatherCode = weather.current.weatherCode;
            }
          }
        } else {
          return null;
        }

        const icon = createTempIcon(temp, weatherCode, false);
        const weatherInfo = getWeatherInfo(weatherCode);

        return (
          <Marker
            key={fav.id}
            position={[fav.latitude, fav.longitude]}
            icon={icon}
            eventHandlers={{
              click: () => onMarkerClick(fav),
            }}
          >
            <Popup>
              <div className="text-center min-w-[140px]">
                <div className="text-2xl mb-1">{weatherInfo.icon}</div>
                <div className="font-bold text-sm">{fav.name}</div>
                {fav.country && (
                  <div className="text-gray-500 text-xs">{fav.country}</div>
                )}
                <div className="text-lg font-bold mt-1">{Math.round(temp)}°C</div>
                <div className="text-xs text-gray-600">{weatherInfo.description}</div>
                <div className="mt-2 flex gap-1">
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      onMarkerClick(fav);
                    }}
                    className="flex-1 text-xs bg-blue-500 text-white px-2 py-1 rounded hover:bg-blue-600"
                  >
                    Vorhersage
                  </button>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      onRemoveFavorite(fav.id);
                    }}
                    className="text-xs bg-red-500 text-white px-2 py-1 rounded hover:bg-red-600"
                  >
                    ✕
                  </button>
                </div>
              </div>
            </Popup>
          </Marker>
        );
      })}
    </MapContainer>
  );
}
