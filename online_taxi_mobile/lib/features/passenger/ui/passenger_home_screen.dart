import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../auth/provider/auth_provider.dart';
import '../data/trip_repository.dart';
import '../provider/trip_provider.dart';

final _tripHistoryProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(tripRepositoryProvider).getTripHistory(),
);

class PassengerHomeScreen extends ConsumerWidget {
  const PassengerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth      = ref.watch(authProvider);
    final firstName = auth.name.isNotEmpty
        ? auth.name.split(' ').first
        : 'Пассажир';
    final historyAsync = ref.watch(_tripHistoryProvider);

    // Обновляем историю после завершения поездки
    ref.listen(passengerProvider, (prev, next) {
      if (prev?.pendingReview == true && next.pendingReview == false) {
        ref.invalidate(_tripHistoryProvider);
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Приветствие
              Row(children: [
                UserAvatar(avatarUrl: auth.avatarUrl, size: 44),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Добро пожаловать',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    Text(firstName,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      )),
                  ],
                ),
              ]),

              const SizedBox(height: 32),

              // Кнопка заказа
              GestureDetector(
                onTap: () => context.push('/passenger/map'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Заказать поездку',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            )),
                          SizedBox(height: 4),
                          Text('Куда едем сегодня?',
                            style: TextStyle(color: Colors.black54, fontSize: 14)),
                        ],
                      ),
                    ),
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.local_taxi_rounded, color: Colors.black, size: 26),
                    ),
                  ]),
                ),
              ),

              const SizedBox(height: 32),

              const Text('Последние поездки',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                )),
              const SizedBox(height: 16),

              Expanded(
                child: historyAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary)),
                  error: (_, __) => _emptyHistory(),
                  data: (items) => items.isEmpty
                      ? _emptyHistory()
                      : ListView(
                          padding: const EdgeInsets.only(bottom: 20),
                          children: items.map((item) => _TripHistoryTile(item: item)).toList(),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyHistory() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: AppTheme.card,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.border),
          ),
          child: const Icon(Icons.history_rounded,
            color: AppTheme.textSecondary, size: 32),
        ),
        const SizedBox(height: 14),
        const Text('Поездок пока нет',
          style: TextStyle(
            color: AppTheme.textSecondary, fontSize: 15)),
        const SizedBox(height: 6),
        const Text('Ваши поездки появятся здесь',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      ],
    ),
  );
}

class _TripHistoryTile extends StatelessWidget {
  final TripHistoryItem item;
  const _TripHistoryTile({required this.item});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.card, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.radio_button_checked, color: AppTheme.success, size: 14),
        const SizedBox(width: 6),
        Expanded(child: Text(item.pickupAddress, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13))),
      ]),
      const SizedBox(height: 4),
      Row(children: [
        const Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 14),
        const SizedBox(width: 6),
        Expanded(child: Text(item.destAddress, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13))),
      ]),
      if (item.driverName.isNotEmpty) ...[
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.person_rounded, color: AppTheme.textSecondary, size: 14),
          const SizedBox(width: 6),
          Expanded(child: Text('Водитель: ${item.driverName}', overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
        ]),
      ],
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(item.finishedAt, style: const TextStyle(
            color: AppTheme.textSecondary, fontSize: 12)),
        Text('${item.priceKzt} ₸', style: const TextStyle(
            color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 14)),
      ]),
    ]));
}
