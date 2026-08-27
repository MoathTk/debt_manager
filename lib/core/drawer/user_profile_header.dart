import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/services/auth_service.dart';
import 'package:local_debt_management/features/authentication/data/repositories/pin_repository_impl.dart';

class UserProfileHeader extends ConsumerWidget {
  const UserProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (user == null) return const SizedBox.shrink();

    return FutureBuilder<Map<String, String>?>(
      future: PinRepositoryImpl().getUserProfile(user.uid),
      builder: (context, snapshot) {
        final name = snapshot.data?['name'] ?? '';
        final phone = snapshot.data?['phone'] ?? user.phoneNumber ?? '';
        final displayPhone = phone.replaceRange(
          phone.length > 4 ? phone.length - 4 : 0,
          phone.length,
          '****',
        );

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name.isNotEmpty ? name : 'User',
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                displayPhone,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
