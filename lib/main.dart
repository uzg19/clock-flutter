import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzlookup;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

void main() {
  tz.initializeTimeZones();
  runApp(const WorldClockApp());
}

class WorldClockApp extends StatelessWidget {
  const WorldClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World Clock Map',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  void _onMapTap(TapPosition tapPosition, LatLng point) {
    final String timezoneId = tzlookup.latLngToTimezoneString(
      point.latitude,
      point.longitude,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClockBottomSheet(
          timezoneId: timezoneId,
          latitude: point.latitude,
          longitude: point.longitude,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('World Clock Map'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(20, 0),
          initialZoom: 2,
          onTap: _onMapTap,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          const RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ClockBottomSheet extends StatefulWidget {
  final String timezoneId;
  final double latitude;
  final double longitude;

  const ClockBottomSheet({
    super.key,
    required this.timezoneId,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<ClockBottomSheet> createState() => _ClockBottomSheetState();
}

class _ClockBottomSheetState extends State<ClockBottomSheet> {
  late Timer _timer;
  late DateTime _currentTime;
  late tz.Location _location;

  @override
  void initState() {
    super.initState();
    try {
      _location = tz.getLocation(widget.timezoneId);
    } catch (e) {
      // Fallback to UTC if timezone is not found
      _location = tz.getLocation('UTC');
    }
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateTime();
        });
      }
    });
  }

  void _updateTime() {
    _currentTime = tz.TZDateTime.now(_location);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String timeString = DateFormat('HH:mm:ss').format(_currentTime);
    final String dateString = DateFormat('EEEE, MMMM d, yyyy').format(_currentTime);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            widget.timezoneId.replaceAll('_', ' '),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lat: ${widget.latitude.toStringAsFixed(4)}, Lon: ${widget.longitude.toStringAsFixed(4)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const Divider(height: 32),
          Text(
            timeString,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            dateString,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Close'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
