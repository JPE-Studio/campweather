# Active Context: Wetterkarte App

## Current State

**Status**: ✅ Wetter-App mit Karte implementiert

Die App zeigt eine interaktive Karte mit gespeicherten Favoriten-Standorten und deren Temperaturen. Open-Meteo (kostenlose API) wird für Wetterdaten und Geocoding verwendet.

## Recently Completed

- [x] Base Next.js 16 setup with App Router
- [x] TypeScript configuration with strict mode
- [x] Tailwind CSS 4 integration
- [x] ESLint configuration
- [x] Memory bank documentation
- [x] Recipe system for common features
- [x] Wetter-App: Interaktive Leaflet-Karte mit Temperatur-Markern
- [x] Favoriten-Verwaltung mit localStorage-Persistenz
- [x] Open-Meteo API Integration (Wetter + Geocoding)
- [x] Wochenvorhersage-Modal bei Klick auf Standort
- [x] Tag-Slider für 7-Tage-Navigation auf der Karte
- [x] Such-Modal zum Hinzufügen von Favoriten-Standorten

## Current Structure

| File/Directory | Purpose | Status |
|----------------|---------|--------|
| `src/app/page.tsx` | Home page → WeatherApp | ✅ Ready |
| `src/app/layout.tsx` | Root layout (de) | ✅ Ready |
| `src/app/globals.css` | Global styles + Map styles | ✅ Ready |
| `src/app/api/weather/route.ts` | API: Wetter + Geocoding | ✅ Ready |
| `src/components/WeatherApp.tsx` | Hauptkomponente | ✅ Ready |
| `src/components/WeatherMap.tsx` | Leaflet-Karte mit Temperatur-Markern | ✅ Ready |
| `src/components/AddFavoriteModal.tsx` | Modal zum Suchen/Hinzufügen | ✅ Ready |
| `src/components/ForecastModal.tsx` | 7-Tage-Vorhersage Modal | ✅ Ready |
| `src/components/DaySlider.tsx` | Tag-Slider Navigation | ✅ Ready |
| `src/hooks/useFavorites.ts` | Favoriten Hook (localStorage) | ✅ Ready |
| `src/lib/weatherUtils.ts` | Wettercode-Infos + Farben | ✅ Ready |
| `src/types/weather.ts` | TypeScript Typen | ✅ Ready |

## Dependencies Added

- `react-leaflet` + `leaflet` - Interaktive Karte
- `@types/leaflet` - TypeScript Typen

## Current Focus

Wetter-App ist vollständig funktionsfähig. Features:
- Karte mit Favoriten-Standorten und aktueller Temperatur
- Farbcodierte Temperatur-Marker (blau→rot)
- Klick auf Marker → Popup mit Wetter + Vorhersage-Button
- 7-Tage-Vorhersage-Modal mit max/min Temperaturen
- Tag-Slider zum Navigieren durch die Woche
- Favoriten suchen und hinzufügen (Open-Meteo Geocoding)
- Favoriten entfernen
- Safe Area Support für mobile Geräte (Notch/Home-Indicator)

## Session History

| Date | Changes |
|------|---------|
| Initial | Template created with base setup |
| 2026-03-28 | Wetter-App mit Karte, Favoriten und Wochenvorhersage implementiert |
| 2026-03-28 | Safe Area Support für mobile Geräte (viewport-fit=cover, env(safe-area-inset-*)) |
