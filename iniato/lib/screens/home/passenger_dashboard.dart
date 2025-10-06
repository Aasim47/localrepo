import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../models/ride.dart';

class PassengerDashboard extends StatefulWidget {
  const PassengerDashboard({super.key});

  @override
  State<PassengerDashboard> createState() => _PassengerDashboardState();
}

class _PassengerDashboardState extends State<PassengerDashboard> {
  final _service = SupabaseService();
  bool _isEv = true;
  double _distanceKm = 5.0;
  double _fare = 100.0;
  bool _loading = false;

  Future<void> _bookRide() async {
    setState(() => _loading = true);
    try {
      final uid = Supabase.instance.client.auth.currentUser!.id;
      final ride = await _service.createRide(
        passengerId: uid,
        distanceKm: _distanceKm,
        fare: _fare,
        isEv: _isEv,
      );
      if (mounted) Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PassengerRideDetails(ride: ride)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniato - Passenger'),
        actions: [
          IconButton(onPressed: () => Navigator.pushNamed(context, '/history'), icon: const Icon(Icons.history)),
          IconButton(onPressed: () => Navigator.pushNamed(context, '/wallet'), icon: const Icon(Icons.wallet)),
          IconButton(onPressed: () => Navigator.pushNamed(context, '/profile'), icon: const Icon(Icons.person)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pickup & Drop (MVP: mock)'),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/map'),
                  child: const Text('Select on Map'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Ride Type:'),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('EV'),
                  selected: _isEv,
                  onSelected: (_) => setState(() => _isEv = true),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Normal'),
                  selected: !_isEv,
                  onSelected: (_) => setState(() => _isEv = false),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Distance: ${_distanceKm.toStringAsFixed(1)} km'),
            Slider(
              value: _distanceKm,
              min: 1,
              max: 20,
              divisions: 19,
              label: _distanceKm.toStringAsFixed(1),
              onChanged: (v) => setState(() {
                _distanceKm = v;
                _fare = 20 + v * (_isEv ? 15 : 12);
              }),
            ),
            Text('Estimated Fare: ₹${_fare.toStringAsFixed(0)}'),
            const Spacer(),
            ElevatedButton(
              onPressed: _loading ? null : _bookRide,
              child: _loading ? const CircularProgressIndicator() : const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}

class PassengerRideDetails extends StatelessWidget {
  final Ride ride;
  const PassengerRideDetails({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final stream = SupabaseService().watchRide(ride.id);
    return Scaffold(
      appBar: AppBar(title: const Text('Ride Details')),
      body: StreamBuilder<Ride>(
        stream: stream,
        builder: (context, snapshot) {
          final r = snapshot.data ?? ride;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ride: ${r.id}'),
                Text('Status: ${r.status}'),
                Text('EV: ${r.isEv ? 'Yes' : 'No'}'),
                Text('Fare: ₹${r.fare.toStringAsFixed(0)}'),
                const Spacer(),
                if (r.status == 'completed')
                  const Text('Completed! Tokens will reflect in your Wallet.'),
              ],
            ),
          );
        },
      ),
    );
  }
}
