import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';
import 'cashier_screen.dart';

/// Route guard: only cashiers may access the cashier queue screen.
class CashierGuardScreen extends StatefulWidget {
  const CashierGuardScreen({super.key});

  @override
  State<CashierGuardScreen> createState() => _CashierGuardScreenState();
}

class _CashierGuardScreenState extends State<CashierGuardScreen> {
  bool _checking = true;
  bool _authorized = false;

  @override
  void initState() {
    super.initState();
    _verifyAccess();
  }

  Future<void> _verifyAccess() async {
    try {
      final profile = await AuthRepository().getProfile();
      if (!mounted) return;

      if (profile?.isCashier == true) {
        setState(() {
          _authorized = true;
          _checking = false;
        });
        return;
      }

      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _authorized ? const CashierScreen() : const SizedBox.shrink();
  }
}
