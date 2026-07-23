library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import '../providers/subscription_provider.dart';

class MutationGuard {
  static bool checkBlocked(BuildContext context, WidgetRef ref) {
    final state = ref.read(subscriptionProvider);
    
    if (state.subscription?.status.name != 'blocked') return false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.subExpiredReadonly),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return true;
  }
}
