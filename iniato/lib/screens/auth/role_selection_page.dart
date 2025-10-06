import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  final _nameCtrl = TextEditingController();
  String? _role; // passenger | driver
  String? _vehicleType; // ev | normal (for driver)
  bool _loading = false;
  final _service = SupabaseService();

  Future<void> _save() async {
    if (_role == null) return;
    setState(() => _loading = true);
    try {
      await _service.upsertProfile(
        name: _nameCtrl.text,
        role: _role!,
        vehicleType: _role == 'driver' ? _vehicleType : null,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Select role')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(user?.email ?? ''),
            const SizedBox(height: 12),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Your name')),
            const SizedBox(height: 12),
            const Text('Role'),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Passenger'),
                  selected: _role == 'passenger',
                  onSelected: (_) => setState(() => _role = 'passenger'),
                ),
                ChoiceChip(
                  label: const Text('Driver'),
                  selected: _role == 'driver',
                  onSelected: (_) => setState(() => _role = 'driver'),
                ),
              ],
            ),
            if (_role == 'driver') ...[
              const SizedBox(height: 12),
              const Text('Vehicle type'),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('EV'),
                    selected: _vehicleType == 'ev',
                    onSelected: (_) => setState(() => _vehicleType = 'ev'),
                  ),
                  ChoiceChip(
                    label: const Text('Normal'),
                    selected: _vehicleType == 'normal',
                    onSelected: (_) => setState(() => _vehicleType = 'normal'),
                  ),
                ],
              ),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: _loading ? null : _save,
              child: _loading ? const CircularProgressIndicator() : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
