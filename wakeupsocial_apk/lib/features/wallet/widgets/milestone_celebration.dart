import 'package:flutter/material.dart';

Future<void> showMilestoneCelebration(
  BuildContext context, {
  required String couponCode,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (ctx.mounted) Navigator.of(ctx).pop();
      });
      return AlertDialog(
        title: const Text('Reward Unlocked!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            const Text('Kupon milestone Anda:'),
            const SizedBox(height: 8),
            Text(
              couponCode,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      );
    },
  );
}
