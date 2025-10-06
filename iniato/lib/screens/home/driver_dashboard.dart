import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../models/ride.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  final _service = SupabaseService();
  late Future<List<Ride>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchRequestedRides();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _service.fetchRequestedRides();
    });
  }

  Future<void> _accept(String rideId) async {
    await _service.acceptRide(rideId: rideId);
    await _refresh();
  }

  Future<void> _complete(String rideId) async {
    await _service.completeRide(rideId: rideId);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniato - Driver'),
        actions: [
          IconButton(onPressed: () => Navigator.pushNamed(context, '/history'), icon: const Icon(Icons.history)),
          IconButton(onPressed: () => Navigator.pushNamed(context, '/wallet'), icon: const Icon(Icons.wallet)),
          IconButton(onPressed: () => Navigator.pushNamed(context, '/profile'), icon: const Icon(Icons.person)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Ride>>(
          future: _future,
          builder: (context, snapshot) {
            final rides = snapshot.data ?? [];
            if (rides.isEmpty) {
              return const Center(child: Text('No ride requests right now.'));
            }
            return ListView.separated(
              itemCount: rides.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final r = rides[index];
                return ListTile(
                  title: Text('₹${r.fare.toStringAsFixed(0)} • ${r.distanceKm.toStringAsFixed(1)} km'),
                  subtitle: Text('EV: ${r.isEv ? 'Yes' : 'No'} • ${r.status}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (r.status == 'requested')
                        TextButton(onPressed: () => _accept(r.id), child: const Text('Accept')),
                      if (r.status == 'accepted')
                        ElevatedButton(onPressed: () => _complete(r.id), child: const Text('Complete')),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
