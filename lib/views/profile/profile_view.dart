import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/routes/app_router.dart';
import '../../models/user_model.dart';
import '../../repositories/auth_repository.dart';
import '../../viewmodels/auth_vm.dart';
import '../../viewmodels/book_vm.dart';
import '../../viewmodels/providers.dart';
import '../../widgets/responsive_layout.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  late Future<UserModel> _profileFuture;

  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _profileFuture = _authRepository.getProfile();
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    ref.read(bookProvider.notifier).reset();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  Widget _profileContent(AsyncSnapshot<UserModel> snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(snapshot.error.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  setState(() => _profileFuture = _authRepository.getProfile());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final user = snapshot.requireData;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CircleAvatar(
                  radius: 36,
                  child: Text(
                    user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 24),
                _profileField('Nama', user.name),
                _profileField('Email', user.email),
                _profileField(
                  'Tanggal Bergabung',
                  user.createdAt == null ? '-' : _formatDate(user.createdAt!),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileField(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 3),
        SelectableText(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final userName =
        ref.watch(authProvider.select((state) => state.user?.name)) ?? '';
    final appBar = AppBar(title: const Text('Profil'));
    final content = FutureBuilder<UserModel>(
      future: _profileFuture,
      builder: (context, snapshot) => _profileContent(snapshot),
    );

    return ResponsiveLayout(
      mobile: Scaffold(appBar: appBar, body: content),
      desktop: Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            NavigationRail(
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.library_books),
                  label: Text('Buku'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Profil'),
                ),
              ],
              selectedIndex: 1,
              onDestinationSelected: (index) {
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, AppRoutes.books);
                }
              },
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      child: Text(
                        userName.isEmpty ? '?' : userName[0].toUpperCase(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 72,
                      child: Text(
                        userName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}
