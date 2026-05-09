import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/product/product_bloc.dart';
import 'blocs/product/product_event.dart';
import 'blocs/cart/cart_bloc.dart';
import 'blocs/cart/cart_event.dart';
import 'blocs/product_detail/product_detail_bloc.dart';
import 'blocs/admin/admin_bloc.dart';
import 'pages/products_page.dart';
import 'pages/login_page.dart';
import 'pages/product_detail_page.dart';
import 'pages/cart_page.dart';
import 'pages/admin_page.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(AuthCheckRequested())),
        BlocProvider(create: (_) => ProductBloc()..add(FetchProductsRequested())),
        BlocProvider(create: (_) => CartBloc()..add(LoadCartRequested())),
        BlocProvider(create: (_) => ProductDetailBloc()),
        BlocProvider(create: (_) => AdminBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.teal,
            side: const BorderSide(color: Colors.teal),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ProductsPage(),
        '/login': (context) => const LoginPage(),
        '/product-detail': (context) => const ProductDetailPage(),
        '/cart': (context) => const CartPage(),
        '/admin': (context) => const AdminPage(),
      },
    );
  }
}
