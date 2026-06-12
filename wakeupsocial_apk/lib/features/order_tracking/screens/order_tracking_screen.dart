import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../routes/navigation_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ============================================================
/// OrderTrackingScreen — Halaman tracking status pesanan.
/// ============================================================
///
/// Sesuai mockup desain:
/// - AppBar: logo "Wake Up Social" + search
/// - Order # + estimated arrival time
/// - Delivery Status card dengan step indicator:
///   Unpaid → Accepted → In Progress → Ready
/// - Info summary: Nama, No table, Total
///
/// **Navigasi:**
/// - Back → kembali ke halaman sebelumnya
///
/// TODO: Ganti mock data dengan data real-time dari backend.
class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _order;

  /// Status saat ini (0-3): Unpaid, Accepted, In Progress, Ready
  int _currentStep = 0; 

  final List<_TrackingStep> _steps = const [
    _TrackingStep(icon: Icons.check_circle_outline, label: 'Unpaid'),
    _TrackingStep(icon: Icons.inventory_2_outlined, label: 'Accepted'),
    _TrackingStep(icon: Icons.coffee_maker_outlined, label: 'In Progress'),
    _TrackingStep(icon: Icons.takeout_dining_outlined, label: 'Ready'),
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('orders')
          .select()
          .eq('id', widget.orderId)
          .single();

      if (mounted) {
        setState(() {
          _order = response;
          _currentStep = _mapStatusToStep(_order!['status']);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int _mapStatusToStep(String status) {
    switch (status) {
      case 'pending': return 1; // accepted
      case 'processing': return 2; // in progress
      case 'ready': return 3; // ready
      case 'delivered': return 3; // ready
      default: return 0; // unpaid
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => NavigationHelper.toHome(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 22),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.coffee, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            const Text(
              'Wake Up Social',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColors.textPrimary, size: 22),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider.withValues(alpha: 0.5)),
        ),
      ),
      body: ShimmerLoading(
        isLoading: _isLoading,
        skeleton: const _TrackingSkeleton(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── ORDER HEADER ────────────────────────────────
              Text(
                'Order #${widget.orderId.split('-').first}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Estimated arrival in 12-15 minutes',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // ─── DELIVERY STATUS CARD ────────────────────────
              _DeliveryStatusCard(
                steps: _steps,
                currentStep: _currentStep,
                orderData: _order,
              ),
            ],
          ),
        ),
      ),

      // ─── BOTTOM: DONE BUTTON ──────────────────────────────
      bottomNavigationBar: _isLoading
          ? null
          : _buildDoneButton(),
    );
  }

  Widget _buildDoneButton() {
    final bool isReady = _currentStep >= 3;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: _DoneButton(
            isEnabled: isReady,
            onTap: () => NavigationHelper.toOrderHistory(context),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// TRACKING STEP DATA
// ══════════════════════════════════════════════════════════════

class _TrackingStep {
  final IconData icon;
  final String label;
  const _TrackingStep({required this.icon, required this.label});
}

// ══════════════════════════════════════════════════════════════
// DELIVERY STATUS CARD
// ══════════════════════════════════════════════════════════════

class _DeliveryStatusCard extends StatefulWidget {
  final List<_TrackingStep> steps;
  final int currentStep;
  final Map<String, dynamic>? orderData;

  const _DeliveryStatusCard({
    required this.steps,
    required this.currentStep,
    this.orderData,
  });

  @override
  State<_DeliveryStatusCard> createState() => _DeliveryStatusCardState();
}

class _DeliveryStatusCardState extends State<_DeliveryStatusCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: _isHovered ? 0.08 : 0.05,
              ),
              blurRadius: _isHovered ? 16 : 8,
              offset: Offset(0, _isHovered ? 6 : 3),
              spreadRadius: _isHovered ? 1 : 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── HEADER: Title + Status Badge ──────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Delivery\nStatus',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusLabel(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ─── STEP INDICATOR ────────────────────────────
            _buildStepIndicator(),
            const SizedBox(height: 24),

            // ─── ORDER INFO ────────────────────────────────
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return 'Rp $buffer';
  }

  String _getStatusLabel() {
    switch (widget.currentStep) {
      case 0: return 'UNPAID';
      case 1: return 'ACCEPTED';
      case 2: return 'IN PROGRESS';
      case 3: return 'READY';
      default: return 'UNKNOWN';
    }
  }

  /// ─── STEP INDICATOR ────────────────────────────────────────
  /// 4 step icons connected by lines.
  /// Completed steps: filled circle + colored icon.
  /// Current step: filled circle + colored icon (highlighted).
  /// Future steps: outlined circle + grey icon.
  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(widget.steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Connector line
          final stepBefore = index ~/ 2;
          final isCompleted = stepBefore < widget.currentStep;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted
                  ? AppColors.accent
                  : AppColors.divider,
            ),
          );
        }

        // Step circle + label
        final stepIndex = index ~/ 2;
        final step = widget.steps[stepIndex];
        final isCompleted = stepIndex <= widget.currentStep;
        final isCurrent = stepIndex == widget.currentStep;

        return SizedBox(
          width: 56,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCurrent ? 38 : 32,
                height: isCurrent ? 38 : 32,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? (isCurrent ? AppColors.accent : Colors.white)
                      : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted ? AppColors.accent : AppColors.divider,
                    width: isCompleted ? 2 : 1.5,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  step.icon,
                  size: isCurrent ? 18 : 15,
                  color: isCurrent
                      ? Colors.white
                      : isCompleted
                          ? AppColors.accent
                          : AppColors.textSecondary.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 6),

              // Label
              Text(
                step.label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                  color: isCompleted
                      ? AppColors.textPrimary
                      : AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }),
    );
  }

  /// ─── INFO SECTION ──────────────────────────────────────────
  Widget _buildInfoSection() {
    final data = widget.orderData;
    if (data == null) return const SizedBox();

    final name = (data['notes'] as String?)?.replaceAll('Atas nama: ', '') ?? '-';
    final tableStr = data['table_number']?.toString() ?? '-';
    final total = data['total_price'] != null ? (data['total_price'] as num).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _infoRow('Nama', name),
          Container(
            height: 1,
            color: AppColors.divider.withValues(alpha: 0.5),
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),
          _infoRow('No table', tableStr),
          Container(
            height: 1,
            color: AppColors.divider.withValues(alpha: 0.5),
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),
          _infoRow('Total', _formatPrice(total), isBold: true),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// DONE BUTTON (enabled/disabled)
// ══════════════════════════════════════════════════════════════

class _DoneButton extends StatefulWidget {
  final bool isEnabled;
  final VoidCallback onTap;

  const _DoneButton({required this.isEnabled, required this.onTap});

  @override
  State<_DoneButton> createState() => _DoneButtonState();
}

class _DoneButtonState extends State<_DoneButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.isEnabled;
    return MouseRegion(
      onEnter: (_) { if (enabled) setState(() => _isHovered = true); },
      onExit: (_) => setState(() => _isHovered = false),
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: (_) { if (enabled) setState(() => _isPressed = true); },
        onTapUp: (_) {
          if (enabled) {
            setState(() => _isPressed = false);
            widget.onTap();
          }
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 50,
          decoration: BoxDecoration(
            color: enabled
                ? (_isPressed
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF388E3C))
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(28),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: const Color(0xFF388E3C).withValues(
                        alpha: _isPressed ? 0.15 : _isHovered ? 0.3 : 0.12,
                      ),
                      blurRadius: _isPressed ? 4 : _isHovered ? 14 : 6,
                      offset: Offset(0, _isPressed ? 1 : _isHovered ? 5 : 2),
                    ),
                  ]
                : [],
          ),
          transform: _isPressed
              ? (Matrix4.identity()..scale(0.97))
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                enabled ? Icons.check_circle : Icons.hourglass_top_rounded,
                color: enabled ? Colors.white : Colors.grey[500],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                enabled ? 'Done' : 'Waiting...',
                style: TextStyle(
                  color: enabled ? Colors.white : Colors.grey[500],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// TRACKING SKELETON
// ══════════════════════════════════════════════════════════════

class _TrackingSkeleton extends StatelessWidget {
  const _TrackingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order header
          SkeletonLine(width: 160, height: 22),
          const SizedBox(height: 6),
          SkeletonLine(width: 220, height: 12),
          const SizedBox(height: 24),

          // Status card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLine(width: 80, height: 16),
                        const SizedBox(height: 4),
                        SkeletonLine(width: 60, height: 16),
                      ],
                    ),
                    SkeletonBox(width: 90, height: 28, borderRadius: 20),
                  ],
                ),
                const SizedBox(height: 28),

                // Step indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (_) => Column(
                    children: [
                      SkeletonCircle(size: 30),
                      const SizedBox(height: 6),
                      SkeletonLine(width: 36, height: 10),
                    ],
                  )),
                ),
                const SizedBox(height: 28),

                // Info section
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      ...List.generate(3, (i) => Padding(
                        padding: EdgeInsets.only(bottom: i < 2 ? 16 : 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(child: SkeletonLine(width: 50, height: 12)),
                            const SizedBox(width: 8),
                            Flexible(child: SkeletonLine(width: 70, height: 12)),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
