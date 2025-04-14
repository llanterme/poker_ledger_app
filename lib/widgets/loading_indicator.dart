import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:poker_ledger/theme/app_theme.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;

  const LoadingIndicator({
    super.key,
    this.size = 50.0,
    this.color,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitPulse(
            color: color ?? AppTheme.primaryColor,
            size: size,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTheme.bodyLarge.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
