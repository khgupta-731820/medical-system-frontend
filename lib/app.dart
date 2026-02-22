import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/routes.dart';
import 'core/config/theme.dart';
import 'presentation/providers/theme_provider.dart';

class MedicalApp extends StatelessWidget {
  const MedicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'MediCare System',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.materialThemeMode,
          initialRoute: Routes.splash,
          onGenerateRoute: Routes.generateRoute,
        );
      },
    );
  }
}