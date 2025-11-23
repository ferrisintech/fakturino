import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/invoices_list_screen.dart';
import 'domain/models/invoice.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/localization/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(InvoiceAdapter());
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      routes: {
        '/invoices': (context) => const InvoicesListScreen(),
      },
    );
  }
}