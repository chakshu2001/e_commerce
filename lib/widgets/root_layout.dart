import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../utils/api_client.dart';

class RootLayout extends StatelessWidget {
  final Widget child;
  final VoidCallback? onRefresh;

  const RootLayout({super.key, required this.child, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Commerce Store'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          if (onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reload',
              onPressed: onRefresh,
            ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return state is Authenticated
                  ? IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
                    )
                  : IconButton(
                      icon: const Icon(Icons.login),
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                    );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Text('Navigation', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Products'),
              onTap: () => Navigator.pushReplacementNamed(context, '/'),
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Admin'),
              onTap: () => Navigator.pushNamed(context, '/admin'),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          child,
          ValueListenableBuilder<bool>(
            valueListenable: apiClient.isLoading,
            builder: (context, isLoading, _) {
              if (isLoading) {
                return Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator(color: Colors.teal)),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
