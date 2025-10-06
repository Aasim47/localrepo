import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../models/ride.dart';

class RideHistoryPage extends StatefulWidget {
  const RideHistoryPage({super.key});

  @override
  State<RideHistoryPage> createState() => _RideHistoryPageState();
}

class _RideHistoryPageState extends State<RideHistoryPage> {
  final _service = SupabaseService();
  late Future<List<Ride>> _asPassenger;
  late Future<List<Ride>> _asDriver;

  @override
  void initState() {
    super.initState();
    _asPassenger = _service.fetchMyPassengerRides();
    _asDriver = _service.fetchMyDriverRides();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ride History'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Passenger'),
            Tab(text: 'Driver'),
          ]),
        ),
        body: TabBarView(children: [
          _RideList(future: _asPassenger),
          _RideList(future: _asDriver),
        ]),
      ),
    );
  }
}

class _RideList extends StatelessWidget {
  final Future<List<Ride>> future;
  const _RideList({required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Ride>>(
      future: future,
      builder: (context, snapshot) {
        final rides = snapshot.data ?? [];
        if (rides.isEmpty) {
          return const Center(child: Text('No rides yet.'));
        }
        return ListView.separated(
          itemCount: rides.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final r = rides[index];
            return ListTile(
              title: Text('₹${r.fare.toStringAsFixed(0)} • ${r.distanceKm.toStringAsFixed(1)} km'),
              subtitle: Text('${r.status.toUpperCase()} • EV: ${r.isEv ? 'Yes' : 'No'}'),
            );
          },
        );
      },
    );
  }
}
