import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wetterkarte/src/models/weather_models.dart';
import 'package:wetterkarte/src/services/favorites_repository.dart';
import 'package:wetterkarte/src/services/open_meteo_service.dart';
import 'package:wetterkarte/src/utils/weather_utils.dart';

abstract class _BaseMapTile {
  String get urlTemplate;
  List<String> get subdomains;
  String get attribution;
}

class _OpenStreetMapTile implements _BaseMapTile {
  @override
  String get urlTemplate =>
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';

  @override
  List<String> get subdomains => const ['a', 'b', 'c', 'd'];

  @override
  String get attribution => '© OpenStreetMap contributors';
}

class WeatherMapScreen extends StatefulWidget {
  const WeatherMapScreen({super.key});

  @override
  State<WeatherMapScreen> createState() => _WeatherMapScreenState();
}

class _WeatherMapScreenState extends State<WeatherMapScreen> {
  final MapController _mapController = MapController();
  final _BaseMapTile _tile = _OpenStreetMapTile();
  late final FavoritesRepository _favoritesRepository;
  final _openMeteoService = OpenMeteoService();

  int _selectedDay = 0;

  List<FavoriteLocation> _favorites = const [];
  Map<String, WeatherData> _weatherCache = const {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _favoritesRepository = FavoritesRepository(prefs);
    await _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = _favoritesRepository.load();
    if (!mounted) return;
    setState(() => _favorites = favorites);

    for (final fav in favorites) {
      await _fetchWeatherForFavorite(fav);
    }
    _fitMapToFavorites();
  }

  Future<void> _fetchWeatherForFavorite(FavoriteLocation fav) async {
    try {
      final weather = await _openMeteoService.fetchForecast(
        latitude: fav.latitude,
        longitude: fav.longitude,
      );
      if (!mounted) return;
      setState(() => _weatherCache = {..._weatherCache, fav.id: weather});
    } catch (_) {
      // Silently fail (matching the web app behavior)
    }
  }

  void _fitMapToFavorites() {
    if (_favorites.isEmpty) {
      _mapController.move(const LatLng(51.1657, 10.4515), 5);
      return;
    }
    if (_favorites.length == 1) {
      final f = _favorites[0];
      _mapController.move(LatLng(f.latitude, f.longitude), 8);
      return;
    }

    final lats = _favorites.map((f) => f.latitude).toList(growable: false);
    final lons = _favorites.map((f) => f.longitude).toList(growable: false);
    final bounds = LatLngBounds(
      LatLng(lats.reduce((a, b) => a < b ? a : b), lons.reduce((a, b) => a < b ? a : b)),
      LatLng(lats.reduce((a, b) => a > b ? a : b), lons.reduce((a, b) => a > b ? a : b)),
    );
    _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
  }

  Future<void> _openAddFavoriteSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _AddFavoriteSheet(),
    );
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wetterkarte'),
        actions: [
          TextButton.icon(
            onPressed: _openAddFavoriteSheet,
            icon: const Icon(Icons.add),
            label: const Text('Favorit hinzufügen'),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(51.1657, 10.4515),
              initialZoom: 5,
            ),
            children: [
              TileLayer(
                urlTemplate: _tile.urlTemplate,
                subdomains: _tile.subdomains,
                userAgentPackageName: 'com.example.wetterkarte',
              ),
              RichAttributionWidget(
                alignment: AttributionAlignment.bottomRight,
                attributions: [
                  TextSourceAttribution(_tile.attribution),
                ],
              ),
              MarkerLayer(
                markers: _favorites
                    .map(
                      (fav) => Marker(
                        point: LatLng(fav.latitude, fav.longitude),
                        width: 64,
                        height: 72,
                        child: _WeatherMarker(
                          favorite: fav,
                          selectedDay: _selectedDay,
                          weather: _weatherCache[fav.id],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: _DaySlider(
                selectedDay: _selectedDay,
                onChanged: (next) => setState(() => _selectedDay = next),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DaySlider extends StatelessWidget {
  const _DaySlider({
    required this.selectedDay,
    required this.onChanged,
  });

  final int selectedDay;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  selectedDay == 0 ? 'Heute' : 'Tag $selectedDay',
                  style: theme.textTheme.labelLarge,
                ),
                const Spacer(),
                Text(
                  '${selectedDay + 1}/7',
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
            Slider(
              min: 0,
              max: 6,
              divisions: 6,
              value: selectedDay.toDouble(),
              onChanged: (v) => onChanged(v.round()),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherMarker extends StatelessWidget {
  const _WeatherMarker({
    required this.favorite,
    required this.selectedDay,
    required this.weather,
  });

  final FavoriteLocation favorite;
  final int selectedDay;
  final WeatherData? weather;

  @override
  Widget build(BuildContext context) {
    final markerTheme = Theme.of(context);

    if (weather == null) return const SizedBox.shrink();

    double temp = weather!.current.temperature;
    int weatherCode = weather!.current.weatherCode;
    if (selectedDay > 0 && selectedDay < weather!.daily.length) {
      final day = weather!.daily[selectedDay];
      temp = (day.tempMax + day.tempMin) / 2;
      weatherCode = day.weatherCode;
    }

    final color = getTemperatureColor(temp);
    final info = getWeatherInfo(weatherCode);

    final isSelected = selectedDay == 0;
    final borderWidth = isSelected ? 3.0 : 2.0;

    return Semantics(
      label: 'Wettermarker für ${favorite.name}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            await showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (context) => _ForecastSheet(
                favorite: favorite,
                weather: weather!,
                selectedDay: selectedDay,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF1D4ED8)
                    : Colors.black.withValues(alpha: 0.2),
                width: borderWidth,
              ),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 8,
                  offset: Offset(0, 2),
                  color: Color(0x4D000000),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    info.icon,
                    style: (isSelected
                            ? markerTheme.textTheme.headlineSmall
                            : markerTheme.textTheme.titleLarge)
                        ?.copyWith(color: Colors.white),
                  ),
                  Text(
                    '${temp.round()}°',
                    style: markerTheme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ForecastSheet extends StatelessWidget {
  const _ForecastSheet({
    required this.favorite,
    required this.weather,
    required this.selectedDay,
  });

  final FavoriteLocation favorite;
  final WeatherData weather;
  final int selectedDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayLabel = selectedDay == 0 ? 'Heute' : 'Tag $selectedDay';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            favorite.name,
            style: theme.textTheme.titleLarge,
          ),
          if (favorite.country != null && favorite.country!.isNotEmpty)
            Text(
              favorite.country!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 12),
          Text(dayLabel, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _ForecastSummary(weather: weather, selectedDay: selectedDay),
          const SizedBox(height: 16),
          Text('7-Tage', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: weather.daily.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final d = weather.daily[index];
                final info = getWeatherInfo(d.weatherCode);
                return ListTile(
                  dense: true,
                  leading: Text(info.icon, style: theme.textTheme.titleLarge),
                  title: Text(d.date),
                  subtitle: Text(info.description),
                  trailing: Text(
                    '${d.tempMin.round()}° / ${d.tempMax.round()}°',
                    style: theme.textTheme.labelLarge,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastSummary extends StatelessWidget {
  const _ForecastSummary({
    required this.weather,
    required this.selectedDay,
  });

  final WeatherData weather;
  final int selectedDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (selectedDay == 0) {
      final info = getWeatherInfo(weather.current.weatherCode);
      return Row(
        children: [
          Text(info.icon, style: theme.textTheme.headlineMedium),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${weather.current.temperature.round()}°C', style: theme.textTheme.headlineSmall),
              Text(info.description, style: theme.textTheme.bodyMedium),
              Text(
                'Wind ${weather.current.windSpeed.round()} km/h',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      );
    }

    final day = selectedDay < weather.daily.length ? weather.daily[selectedDay] : null;
    if (day == null) return const SizedBox.shrink();
    final info = getWeatherInfo(day.weatherCode);
    return Row(
      children: [
        Text(info.icon, style: theme.textTheme.headlineMedium),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${day.tempMin.round()}° / ${day.tempMax.round()}°',
              style: theme.textTheme.headlineSmall,
            ),
            Text(info.description, style: theme.textTheme.bodyMedium),
            Text(
              'Niederschlag ${day.precipitationSum.toStringAsFixed(1)} mm • Wind ${day.windSpeedMax.round()} km/h',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AddFavoriteSheet extends StatefulWidget {
  const _AddFavoriteSheet();

  @override
  State<_AddFavoriteSheet> createState() => _AddFavoriteSheetState();
}

class _AddFavoriteSheetState extends State<_AddFavoriteSheet> {
  late FavoritesRepository _favoritesRepository;
  final _openMeteoService = OpenMeteoService();
  final _controller = TextEditingController();

  bool _isLoading = false;
  List<GeocodingResult> _results = const [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _favoritesRepository = FavoritesRepository(prefs);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final results = await _openMeteoService.searchPlaces(query: query);
      if (!mounted) return;
      setState(() => _results = results);
    } catch (_) {
      if (!mounted) return;
      setState(() => _results = const []);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _add(GeocodingResult r) async {
    final current = _favoritesRepository.load();
    if (current.any((f) => f.id == r.id)) {
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }

    final next = [
      ...current,
      FavoriteLocation(
        id: r.id,
        name: r.name,
        latitude: r.latitude,
        longitude: r.longitude,
        country: r.country,
      ),
    ];
    await _favoritesRepository.save(next);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: 'Ort suchen',
              hintText: 'z.B. München',
              suffixIcon: IconButton(
                onPressed: _isLoading ? null : _search,
                icon: const Icon(Icons.search),
              ),
            ),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 12),
          if (_isLoading) const LinearProgressIndicator(),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _results.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final r = _results[index];
                final subtitleParts = <String>[
                  if (r.admin1 != null && r.admin1!.isNotEmpty) r.admin1!,
                  if (r.country != null && r.country!.isNotEmpty) r.country!,
                ];
                return ListTile(
                  title: Text(r.name),
                  subtitle: subtitleParts.isEmpty ? null : Text(subtitleParts.join(' • ')),
                  onTap: () => _add(r),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

