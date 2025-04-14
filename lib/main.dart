import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_ledger/screens/login_screen.dart';
import 'package:poker_ledger/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.backgroundColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const ProviderScope(child: PokerLedgerApp()));
}

class PokerLedgerApp extends StatelessWidget {
  const PokerLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poker Ledger',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}
