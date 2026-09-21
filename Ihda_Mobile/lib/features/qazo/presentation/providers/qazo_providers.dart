import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/qazo_counts.dart';

class QazoController extends Notifier<QazoCounts> {
  @override
  QazoCounts build() => const QazoCounts();

  void increment(String key) => _adjust(key, 1);
  void decrement(String key) => _adjust(key, -1);

  void _adjust(String key, int delta) {
    final c = state;
    int clamp(int v) => (v + delta).clamp(0, 999);
    switch (key) {
      case 'fajr':
        state = c.copyWith(fajr: clamp(c.fajr));
        break;
      case 'dhuhr':
        state = c.copyWith(dhuhr: clamp(c.dhuhr));
        break;
      case 'asr':
        state = c.copyWith(asr: clamp(c.asr));
        break;
      case 'maghrib':
        state = c.copyWith(maghrib: clamp(c.maghrib));
        break;
      case 'isha':
        state = c.copyWith(isha: clamp(c.isha));
        break;
    }
  }
}

final qazoControllerProvider = NotifierProvider<QazoController, QazoCounts>(QazoController.new);
