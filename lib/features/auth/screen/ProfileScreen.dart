// lib/features/auth/view/profile_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dio_provider.dart';
import '../../posts/providers/post_provider.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../enum/auth_enum.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state        = ref.watch(authViewModelProvider);
    final user         = state.user;
    final isLoading    = state.isApiLoading(AuthEnum.userDetails);
    final isLoggingOut = state.isApiLoading(AuthEnum.logout);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton.icon(
            onPressed: isLoggingOut
                ? null
                : () => ref.read(authViewModelProvider.notifier).logout(),
            icon: isLoggingOut
                ? const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.logout),
            label: const Text('Logout'),
          ),

        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Could not load profile'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read(authViewModelProvider.notifier)
                  .getUserDetails(),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 48,
              backgroundImage: user.image != null
                  ? NetworkImage(user.image!)
                  : null,
              child: user.image == null
                  ? Text(
                user.firstName[0].toUpperCase(),
                style: const TextStyle(fontSize: 36),
              )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text('@${user.username}',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(user.email,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            _InfoTile(label: 'User ID',    value: '${user.id}'),
            _InfoTile(label: 'First name', value: user.firstName),
            _InfoTile(label: 'Last name',  value: user.lastName),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label, value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}