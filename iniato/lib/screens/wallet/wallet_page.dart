import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../models/transaction.dart';
import '../../models/user_profile.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final _service = SupabaseService();
  late Future<List<TokenTransaction>> _futureTx;
  late Future<UserProfile?> _futureProfile;

  @override
  void initState() {
    super.initState();
    _futureTx = _service.fetchMyTransactions();
    _futureProfile = _service.fetchMyProfile();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureTx = _service.fetchMyTransactions();
      _futureProfile = _service.fetchMyProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Green Wallet')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<UserProfile?>(
                  future: _futureProfile,
                  builder: (context, snapshot) {
                    final balance = snapshot.data?.tokenBalance ?? 0;
                    return Card(
                      color: const Color(0xFFE8F5E9),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Current Tokens', style: TextStyle(fontSize: 18)),
                            Text(balance.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text('Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                FutureBuilder<List<TokenTransaction>>(
                  future: _futureTx,
                  builder: (context, snapshot) {
                    final txs = snapshot.data ?? [];
                    if (txs.isEmpty) return const Text('No transactions yet.');
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: txs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final t = txs[index];
                        return ListTile(
                          title: Text('${t.reason}'),
                          subtitle: Text(t.createdAt.toLocal().toString()),
                          trailing: Text('+${t.tokens}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Redeem Tokens (mock)'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
