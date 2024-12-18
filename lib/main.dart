import 'package:flutter/material.dart';
import 'screens/product_list.dart';
import 'screens/product_form.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => ProductListScreen(),
        '/addProduct': (context) => ProductFormScreen(),
        '/editProduct': (context) => ProductFormScreen(
            product: ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>?),
      },
    );
  }
}
