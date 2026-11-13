import 'package:flutter/material.dart';

enum PrayerType { fajr, sunrise, dhuhr, asr, maghrib, isha }

extension PrayerTypeX on PrayerType {
  String get label {
    switch (this) {
      case PrayerType.fajr:
        return 'Bomdod';
      case PrayerType.sunrise:
        return 'Quyosh';
      case PrayerType.dhuhr:
        return 'Peshshin';
      case PrayerType.asr:
        return 'Asr';
      case PrayerType.maghrib:
        return 'Shom';
      case PrayerType.isha:
        return 'Xufton';
    }
  }

  bool get isNotifiable => this != PrayerType.sunrise;
}

class Prayer {
  final PrayerType type;
  final DateTime time;

  const Prayer({required this.type, required this.time});

  Prayer copyWith({DateTime? time}) => Prayer(type: type, time: time ?? this.time);
}

enum CalculationMethod { mwl, isna, egypt, makkah, karachi, diyanet }

extension CalculationMethodX on CalculationMethod {
  String get label {
    switch (this) {
      case CalculationMethod.mwl:
        return 'Muslim World League';
      case CalculationMethod.isna:
        return 'Islamic Society of North America';
      case CalculationMethod.egypt:
        return 'Egyptian General Authority';
      case CalculationMethod.makkah:
        return 'Umm al-Qura, Makkah';
      case CalculationMethod.karachi:
        return 'University of Islamic Sciences, Karachi';
      case CalculationMethod.diyanet:
        return 'Diyanet (Turkey)';
    }
  }
}
