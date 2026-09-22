import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/qazo_counts.dart';

class QazoController extends Notifier<QazoCounts> {
  @override
  QazoCounts build() => const QazoCounts();

  void increment(String key) => _adjust(key, 1);
  void decrement(String key) => _adjust(key, -1);

  void setCount(String key, int newCount) {
    final c = state;
    final val = newCount.clamp(0, 99999);
    switch (key) {
      case 'fajr':
        state = c.copyWith(fajr: val);
        break;
      case 'dhuhr':
        state = c.copyWith(dhuhr: val);
        break;
      case 'asr':
        state = c.copyWith(asr: val);
        break;
      case 'maghrib':
        state = c.copyWith(maghrib: val);
        break;
      case 'isha':
        state = c.copyWith(isha: val);
        break;
    }
  }

  void addDays(int days) {
    final c = state;
    int clamp(int current) => (current + days).clamp(0, 99999);
    state = c.copyWith(
      fajr: clamp(c.fajr),
      dhuhr: clamp(c.dhuhr),
      asr: clamp(c.asr),
      maghrib: clamp(c.maghrib),
      isha: clamp(c.isha),
    );
  }

  void _adjust(String key, int delta) {
    final c = state;
    int clamp(int v) => (v + delta).clamp(0, 99999);
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
