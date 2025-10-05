import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [
          // Account section
          _buildSectionHeader(context, 'Аккаунт'),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(authProvider.user?.name ?? 'Пользователь'),
                subtitle: Text(authProvider.user?.email ?? ''),
                trailing: authProvider.user?.isPremium == true
                    ? Chip(
                        label: const Text('Premium'),
                        backgroundColor: Colors.amber.shade100,
                      )
                    : null,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('Премиум подписка'),
            subtitle: const Text('Без рекламы, больше проверок'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement subscription
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Подписка скоро будет доступна'),
                ),
              );
            },
          ),

          const Divider(),

          // Privacy section
          _buildSectionHeader(context, 'Конфиденциальность'),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Политика конфиденциальности'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Show privacy policy
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Экспорт данных'),
            subtitle: const Text('Скачать все ваши данные'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement data export (GDPR)
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Удалить аккаунт'),
            subtitle: const Text('Это действие нельзя отменить'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Удалить аккаунт?'),
                  content: const Text(
                    'Все ваши данные будут удалены без возможности восстановления. '
                    'Это действие нельзя отменить.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Отмена'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Удалить'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                // TODO: Implement account deletion
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Функция скоро будет доступна'),
                  ),
                );
              }
            },
          ),

          const Divider(),

          // About section
          _buildSectionHeader(context, 'О приложении'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Версия'),
            trailing: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Помощь и поддержка'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Support page
            },
          ),

          const Divider(),

          // Sign out
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Выйти', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Выйти?'),
                  content: const Text('Вы уверены, что хотите выйти?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Отмена'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Выйти'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.signOut();
                
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}