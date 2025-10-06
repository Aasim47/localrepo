import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/ride.dart';
import '../models/transaction.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<UserProfile?> fetchMyProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final res = await _client.from('users').select('*').eq('id', user.id).maybeSingle();
    final data = res;
    if (data == null) return null;
    return UserProfile.fromMap(Map<String, dynamic>.from(data));
  }

  Future<void> upsertProfile({required String name, required String role, String? vehicleType}) async {
    final user = _client.auth.currentUser!;
    await _client.from('users').upsert({
      'id': user.id,
      'name': name,
      'email': user.email,
      'role': role,
      'vehicle_type': vehicleType,
    });
  }

  Future<Ride> createRide({
    required String passengerId,
    required double distanceKm,
    required double fare,
    required bool isEv,
  }) async {
    final insert = await _client.from('rides').insert({
      'passenger_id': passengerId,
      'distance_km': distanceKm,
      'fare': fare,
      'is_ev': isEv,
      'status': 'requested',
    }).select().single();
    return Ride.fromMap(Map<String, dynamic>.from(insert));
  }

  Future<List<Ride>> fetchRequestedRides() async {
    final rows = await _client.from('rides').select('*').eq('status', 'requested').order('created_at');
    return List<Map<String, dynamic>>.from(rows).map((e) => Ride.fromMap(e)).toList();
  }

  Future<List<Ride>> fetchMyPassengerRides() async {
    final user = _client.auth.currentUser!;
    final rows = await _client
        .from('rides')
        .select('*')
        .eq('passenger_id', user.id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows).map((e) => Ride.fromMap(e)).toList();
  }

  Future<List<Ride>> fetchMyDriverRides() async {
    final user = _client.auth.currentUser!;
    final rows = await _client
        .from('rides')
        .select('*')
        .eq('driver_id', user.id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows).map((e) => Ride.fromMap(e)).toList();
  }

  Future<Ride> acceptRide({required String rideId}) async {
    final user = _client.auth.currentUser!;
    final updated = await _client
        .from('rides')
        .update({'driver_id': user.id, 'status': 'accepted'})
        .eq('id', rideId)
        .select()
        .single();
    return Ride.fromMap(Map<String, dynamic>.from(updated));
  }

  Future<Ride> completeRide({required String rideId}) async {
    final updated = await _client
        .from('rides')
        .update({'status': 'completed'})
        .eq('id', rideId)
        .select()
        .single();

    // Call edge function to reward tokens
    await _client.functions.invoke('reward_tokens', body: {'ride_id': rideId});

    return Ride.fromMap(Map<String, dynamic>.from(updated));
  }

  Stream<Ride> watchRide(String rideId) {
    return _client
        .from('rides')
        .stream(primaryKey: ['id'])
        .eq('id', rideId)
        .map((rows) => Ride.fromMap(Map<String, dynamic>.from(rows.first)));
  }

  Future<List<TokenTransaction>> fetchMyTransactions() async {
    final user = _client.auth.currentUser!;
    final rows = await _client
        .from('transactions')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows)
        .map((e) => TokenTransaction.fromMap(e))
        .toList();
  }
}
