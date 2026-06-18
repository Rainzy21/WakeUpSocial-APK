import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/wallet_repository.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _walletRepo = WalletRepository();
  Map<String, dynamic>? _wallet;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final wallet = await _walletRepo.getWallet();
      if (mounted) setState(() { _wallet = wallet; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet & Stamps'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _StampCard(
                    stamps: (_wallet?['current_stamp_count'] as num?)?.toInt() ?? 0,
                    points: (_wallet?['loyalty_points'] as num?)?.toInt() ?? 0,
                    tier: _wallet?['current_tier'] as String? ?? 'BRONZE',
                  ),
                  const SizedBox(height: 24),
                  const Text('Kupon Tersedia', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  ..._buildCoupons(),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildCoupons() {
    final coupons = (_wallet?['available_coupons'] as List?) ?? [];
    if (coupons.isEmpty) {
      return [const Text('Belum ada kupon.')];
    }
    return coupons.map((c) {
      final map = Map<String, dynamic>.from(c as Map);
      return Card(
        child: ListTile(
          title: Text(map['code'] as String? ?? ''),
          subtitle: Text('Diskon ${map['discount_value']} IDR'),
        ),
      );
    }).toList();
  }
}

class _StampCard extends StatelessWidget {
  final int stamps;
  final int points;
  final String tier;

  const _StampCard({
    required this.stamps,
    required this.points,
    required this.tier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tier $tier', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          Text('$points poin'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(10, (i) {
              final filled = i < stamps;
              return Icon(
                filled ? Icons.local_cafe : Icons.local_cafe_outlined,
                color: filled ? AppColors.primary : AppColors.textSecondary,
                size: 22,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text('$stamps / 10 stamp'),
        ],
      ),
    );
  }
}
