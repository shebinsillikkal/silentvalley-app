// Silent Valley App — Trek Tracking Service
// Author: Shebin S Illikkal

import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrekTrackerService {
  StreamSubscription<Position>? _positionStream;
  final List<Position> _trackPoints = [];
  bool _isTracking = false;
  String? _activeTrekId;
  final _db = FirebaseFirestore.instance;

  bool get isTracking => _isTracking;
  List<Position> get trackPoints => List.unmodifiable(_trackPoints);

  double get distanceCoveredKm {
    if (_trackPoints.length < 2) return 0;
    double total = 0;
    for (int i = 1; i < _trackPoints.length; i++) {
      total += Geolocator.distanceBetween(
        _trackPoints[i-1].latitude, _trackPoints[i-1].longitude,
        _trackPoints[i].latitude,   _trackPoints[i].longitude,
      );
    }
    return total / 1000;
  }

  Future<void> startTrek(String userId, String trailId) async {
    final permitted = await _checkPermission();
    if (!permitted) throw Exception('Location permission denied');

    final trekDoc = await _db.collection('active_treks').add({
      'userId': userId,
      'trailId': trailId,
      'startTime': FieldValue.serverTimestamp(),
      'status': 'active',
      'trackPoints': [],
    });
    _activeTrekId = trekDoc.id;
    _isTracking = true;
    _trackPoints.clear();

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // update every 10 metres
      ),
    ).listen(_onPosition);
  }

  void _onPosition(Position pos) {
    _trackPoints.add(pos);
    // Sync to Firestore every 10 points
    if (_trackPoints.length % 10 == 0 && _activeTrekId != null) {
      _db.collection('active_treks').doc(_activeTrekId!).update({
        'trackPoints': _trackPoints.map((p) => {
          'lat': p.latitude, 'lng': p.longitude,
          'alt': p.altitude, 'ts': p.timestamp.millisecondsSinceEpoch
        }).toList(),
        'distanceKm': distanceCoveredKm,
        'lastUpdate': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> sendSOS(String userId, String message) async {
    final pos = await Geolocator.getCurrentPosition();
    await _db.collection('sos_alerts').add({
      'userId': userId,
      'latitude': pos.latitude,
      'longitude': pos.longitude,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'active',
      'trekId': _activeTrekId,
    });
    // In production: also SMS Forest Department emergency number
  }

  Future<void> endTrek() async {
    _positionStream?.cancel();
    _isTracking = false;
    if (_activeTrekId != null) {
      await _db.collection('active_treks').doc(_activeTrekId!).update({
        'endTime': FieldValue.serverTimestamp(),
        'status': 'completed',
        'totalDistanceKm': distanceCoveredKm,
        'finalTrackPoints': _trackPoints.map((p) => {
          'lat': p.latitude, 'lng': p.longitude,
        }).toList(),
      });
    }
  }

  Future<bool> _checkPermission() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.always ||
           perm == LocationPermission.whileInUse;
  }
}
