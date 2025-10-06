class TokenTransaction {
  final String id;
  final String userId;
  final String rideId;
  final int tokens;
  final String reason; // EV Ride | EV Ride Completed
  final DateTime createdAt;

  TokenTransaction({
    required this.id,
    required this.userId,
    required this.rideId,
    required this.tokens,
    required this.reason,
    required this.createdAt,
  });

  factory TokenTransaction.fromMap(Map<String, dynamic> map) {
    return TokenTransaction(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      rideId: map['ride_id'] as String,
      tokens: map['tokens'] as int,
      reason: map['reason'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
