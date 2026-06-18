import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/session_provider.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../routes/navigation_helper.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final _sessionRepo = SessionRepository();
  bool _processing = false;

  Future<void> _onQrDetected(String rawValue) async {
    if (_processing) return;
    setState(() => _processing = true);

    try {
      final table = await _sessionRepo.resolveTableByQr(rawValue.trim());
      final session = await _sessionRepo.createSession(table['id'] as String);

      if (!mounted) return;
      await context.read<SessionProvider>().setSession(
        sessionId: session['id'] as String,
        tableId: table['id'] as String,
        tableNumber: table['table_number'] as int,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Meja ${table['table_number']} siap!')),
      );
      NavigationHelper.toHome(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('QR tidak valid: $e')));
        setState(() => _processing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Meja'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Arahkan kamera ke QR code di meja Anda untuk mulai memesan.',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: _processing
                ? const Center(child: CircularProgressIndicator())
                : _ManualQrEntry(onSubmit: _onQrDetected),
          ),
        ],
      ),
    );
  }
}

/// Manual entry fallback until camera permissions are configured.
class _ManualQrEntry extends StatefulWidget {
  final Future<void> Function(String) onSubmit;

  const _ManualQrEntry({required this.onSubmit});

  @override
  State<_ManualQrEntry> createState() => _ManualQrEntryState();
}

class _ManualQrEntryState extends State<_ManualQrEntry> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Kode QR Meja',
              hintText: 'WUS-TABLE-001',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onSubmit(_controller.text),
              child: const Text('Mulai Sesi'),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tip: gunakan WUS-TABLE-001 s/d WUS-TABLE-005 untuk testing.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
