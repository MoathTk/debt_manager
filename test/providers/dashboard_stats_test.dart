import 'package:flutter_test/flutter_test.dart';
import 'package:local_debt_management/Providers/database_provider.dart';

void main() {
  group('DashboardStats', () {
    test('collectionRate = payments / debts', () {
      final stats = DashboardStats(
        customerCount: 10,
        totalDebts: 1000,
        totalPayments: 500,
        pendingReminders: 5,
      );
      expect(stats.collectionRate, 0.5);
    });

    test('collectionRate = 0 when no debts', () {
      final stats = DashboardStats(
        customerCount: 10,
        totalDebts: 0,
        totalPayments: 500,
        pendingReminders: 5,
      );
      expect(stats.collectionRate, 0.0);
    });

    test('collectionRate > 1 when payments exceed debts', () {
      final stats = DashboardStats(
        customerCount: 10,
        totalDebts: 100,
        totalPayments: 200,
        pendingReminders: 0,
      );
      expect(stats.collectionRate, 2.0);
    });

    test('defaults for periodicData and topDebtors are empty', () {
      final stats = DashboardStats(
        customerCount: 0,
        totalDebts: 0,
        totalPayments: 0,
        pendingReminders: 0,
      );
      expect(stats.periodicData, isEmpty);
      expect(stats.topDebtors, isEmpty);
    });

    test('all fields accessible', () {
      final stats = DashboardStats(
        customerCount: 25,
        totalDebts: 15000,
        totalPayments: 7500,
        pendingReminders: 8,
        periodicData: [
          {'label': '06', 'debts': 1000.0, 'payments': 500.0},
        ],
        topDebtors: [
          {'name': 'Ahmed', 'outstanding': 5000.0},
        ],
      );
      expect(stats.customerCount, 25);
      expect(stats.totalDebts, 15000);
      expect(stats.totalPayments, 7500);
      expect(stats.pendingReminders, 8);
      expect(stats.periodicData.length, 1);
      expect(stats.topDebtors.length, 1);
    });
  });
}
