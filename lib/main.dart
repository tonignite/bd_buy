import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'state/shopping_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const BDBuyApp());
}

class BDBuyApp extends StatelessWidget {
  const BDBuyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShoppingState(),
      child: MaterialApp(
        title: 'BDBuy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
