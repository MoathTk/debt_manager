import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../Providers/database_provider.dart';
import '../widgets/customer_header.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/action_bar.dart';
import '../widgets/edit_customer_sheet.dart';

/// Customer detail screen showing profile, balance, and transaction history.
class CustomerDetailScreen extends ConsumerWidget {
  final int customerId;
  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerByIdProvider(customerId));
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customerDetail),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: l10n.editCustomer,
            onPressed: () {
              final c = ref.read(customerByIdProvider(customerId)).valueOrNull;
              if (c != null) showEditCustomerSheet(context, ref, c);
            },
          ),
        ],
      ),
      bottomNavigationBar: ActionBar(customerId: customerId),
      body: customerAsync.when(
        data: (c) {
          if (c == null) return const Center(child: Text('Customer not found'));
          return _Body(customerId: customerId, customer: c);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  final int customerId;
  final dynamic customer;
  const _Body({required this.customerId, required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(customerBalanceProvider(customerId));
    final txnsAsync = ref.watch(transactionsByCustomerProvider(customerId));
    final debtsAsync = ref.watch(debtsWithRemainingProvider(customerId));
    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: CustomerHeader(customer: customer)),
        SliverToBoxAdapter(
          child: balanceAsync.when(
            data: (b) => BalanceCard(balance: b),
            loading: () => const SizedBox(height: 80),
            error: (_, __) => const SizedBox(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              l10n.recentTransactions.toUpperCase(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
        txnsAsync.when(
          data: (txns) {
            if (txns.isEmpty) {
              return SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: l10n.noTransactionsForCustomer,
                  message: l10n.noTransactionsMessage,
                ),
              );
            }

            final rMap = <int, double>{};
            debtsAsync.whenData((ds) {
              for (final d in ds){
                rMap[d['id'] as int] = (d['remaining'] as num).toDouble();
              }
                
            });
            return SliverList.separated(
              itemCount: txns.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, i) {
                final txn = txns[i];
                return TransactionTile(
                  transaction: txn,
                  remaining: txn.isDebt ? rMap[txn.id] : null,
                );
              },
            );
          },
          loading: () => const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          error: (e, _) =>
              SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}
