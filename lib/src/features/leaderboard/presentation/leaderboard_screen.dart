
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../application/leaderboard_providers.dart';
import '../domain/leaderboard_entry.dart';
import '../../../core/theme/app_theme.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthRepository.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liderlik Tablosu'),
        centerTitle: true,
        actions: [
          // Dev Menu
          if (kDebugMode)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == 'populate') {
                  // Show confirmation or just do it
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Botlar ekleniyor...')),
                  );
                  await ref.read(leaderboardRepositoryProvider).populateDummyData();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Botlar eklendi!')),
                    );
                  }
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'populate',
                    child: Row(
                      children: [
                        Icon(Icons.smart_toy, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Bot Ekle (Dev)'),
                      ],
                    ),
                  ),
                ];
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Haftalık'),
            Tab(text: 'Aylık'),
            Tab(text: 'Tüm Zamanlar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LeaderboardList(
            provider: topUsersWeeklyProvider,
            currentUserId: currentUser?.uid,
            period: 'weekly',
          ),
          _LeaderboardList(
            provider: topUsersMonthlyProvider,
            currentUserId: currentUser?.uid,
            period: 'monthly',
          ),
          _LeaderboardList(
            provider: topUsersAllTimeProvider,
            currentUserId: currentUser?.uid,
            period: 'all_time',
          ),
        ],
      ),
    );
  }
}

class _LeaderboardList extends ConsumerWidget {
  final AutoDisposeStreamProvider<List<LeaderboardEntry>> provider;
  final String? currentUserId;
  final String period;

  const _LeaderboardList({
    required this.provider,
    required this.currentUserId,
    required this.period,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(provider);

    return leaderboardAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Henüz veri yok', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final entry = entries[index];
            final rank = index + 1;
            final isMe = entry.uid == currentUserId;
            
            // Determine score based on period
            int score;
            if (period == 'weekly') {
              score = entry.weeklyXp;
            } else if (period == 'monthly') {
              score = entry.monthlyXp;
            } else {
              score = entry.xp;
            }

            return _LeaderboardTile(
              rank: rank,
              entry: entry,
              isMe: isMe,
              score: score,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text('Bir hata oluştu: $err', textAlign: TextAlign.center),
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;
  final bool isMe;
  final int score;

  const _LeaderboardTile({
    required this.rank,
    required this.entry,
    required this.isMe,
    required this.score,
  });

  Color get rankColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isMe 
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isMe 
            ? Border.all(color: theme.colorScheme.primary, width: 1.5)
            : null,
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: SizedBox(
          width: 50,
          child: Row(
            children: [
              Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: rank <= 3 ? rankColor : theme.textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(width: 8),
              if (rank <= 3)
                Icon(Icons.emoji_events, color: rankColor, size: 16),
            ],
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: entry.photoUrl != null
                  ? NetworkImage(entry.photoUrl!)
                  : null,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: entry.photoUrl == null
                  ? Text(
                      entry.displayName.isNotEmpty ? entry.displayName[0].toUpperCase() : '?',
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.displayName + (isMe ? ' (Sen)' : ''),
                style: TextStyle(
                  fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
                  color: isMe ? theme.colorScheme.primary : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$score XP',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}
