import 'package:flutter/material.dart';

class MapSelectPage extends StatelessWidget {
  const MapSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select on Map (MVP)')),
      body: const Center(
        child: Text('Map integration stub (use Google Maps SDK later)'),
      ),
    );
  }
}
