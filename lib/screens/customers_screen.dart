import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../Providers/database_provider.dart';
import '../widgets/customer_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/add_customer_sheet.dart';
import 'customer_detail_screen.dart';

/// Customers list screen with search and add functionality.
class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});
  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          _SearchBar(hint: l10n.searchCustomers, onChanged: (q) => setState(() => _query = q)),
          Expanded(
            child: customersAsync.when(
              data: (all) {
                final list = _query.isEmpty
                    ? all
                    : all.where((c) =>
                        c.name.toLowerCase().contains(_query.toLowerCase()) ||
                        (c.phone != null && c.phone!.contains(_query))).toList();
                if (list.isEmpty) {
                  return EmptyState(icon: Icons.people_outline,
                    title: l10n.noCustomersYet, message: l10n.noCustomersMessage);
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(customersProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 0),
                    itemBuilder: (ctx, i) => CustomerTile(
                      name: list[i].name, phone: list[i].phone, customerId: list[i].id!,
                      onTap: () => Navigator.push(ctx, MaterialPageRoute(
                        builder: (_) => CustomerDetailScreen(customerId: list[i].id!))),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddCustomerSheet(context, ref),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        onChanged: onChanged, style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(fontSize: 16),
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
