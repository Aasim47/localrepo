class Ride {
  final String id;
  final String passengerId;
  final String? driverId;
  final double distanceKm;
  final double fare;
  final bool isEv;
  final String status; // requested | accepted | completed
  final DateTime createdAt;

  Ride({
    required this.id,
    required this.passengerId,
    required this.driverId,
    required this.distanceKm,
    required this.fare,
    required this.isEv,
    required this.status,
    required this.createdAt,
  });

  factory Ride.fromMap(Map<String, dynamic> map) {
    return Ride(
      id: map['id'] as String,
      passengerId: map['passenger_id'] as String,
      driverId: map['driver_id'] as String?,
      distanceKm: (map['distance_km'] as num?)?.toDouble() ?? 0,
      fare: (map['fare'] as num?)?.toDouble() ?? 0,
      isEv: (map['is_ev'] as bool?) ?? false,
      status: map['status'] as String? ?? 'requested',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'passenger_id': passengerId,
      'driver_id': driverId,
      'distance_km': distanceKm,
      'fare': fare,
      'is_ev': isEv,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
