// Silent Valley App — Wildlife Species Model
// Author: Shebin S Illikkal

class WildlifeSpecies {
  final String id;
  final String commonName;
  final String scientificName;
  final String localNameMalayalam;
  final String category; // mammal | bird | reptile | amphibian | butterfly | plant
  final String conservationStatus; // CR | EN | VU | NT | LC
  final String description;
  final List<String> imageUrls;
  final String? callAudioUrl;
  final List<String> bestSightingZones;
  final String bestTime; // dawn | dusk | night | anytime
  final bool isEndemic;
  final bool isKeystone;

  WildlifeSpecies({
    required this.id,
    required this.commonName,
    required this.scientificName,
    required this.localNameMalayalam,
    required this.category,
    required this.conservationStatus,
    required this.description,
    required this.imageUrls,
    this.callAudioUrl,
    required this.bestSightingZones,
    required this.bestTime,
    this.isEndemic = false,
    this.isKeystone = false,
  });

  String get statusLabel {
    const labels = {
      'CR': 'Critically Endangered',
      'EN': 'Endangered',
      'VU': 'Vulnerable',
      'NT': 'Near Threatened',
      'LC': 'Least Concern',
    };
    return labels[conservationStatus] ?? conservationStatus;
  }
}

class TrailRoute {
  final String id;
  final String name;
  final String difficulty;  // easy | moderate | hard
  final double distanceKm;
  final int durationHours;
  final double elevationGainM;
  final String description;
  final List<LatLng> waypoints;
  final List<String> highlights;
  final bool requiresGuide;
  final bool permitRequired;

  TrailRoute({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.distanceKm,
    required this.durationHours,
    required this.elevationGainM,
    required this.description,
    required this.waypoints,
    required this.highlights,
    this.requiresGuide = true,
    this.permitRequired = true,
  });
}

class LatLng {
  final double latitude;
  final double longitude;
  const LatLng(this.latitude, this.longitude);
}

class WildlifeSighting {
  final String id;
  final String userId;
  final String speciesId;
  final String speciesName;
  final LatLng location;
  final DateTime timestamp;
  final String? photoUrl;
  final String? notes;
  final int count;
  final bool sharedWithForestDept;

  WildlifeSighting({
    required this.id,
    required this.userId,
    required this.speciesId,
    required this.speciesName,
    required this.location,
    required this.timestamp,
    this.photoUrl,
    this.notes,
    this.count = 1,
    this.sharedWithForestDept = false,
  });
}
