class QazoCounts {
  final int fajr;
  final int dhuhr;
  final int asr;
  final int maghrib;
  final int isha;

  const QazoCounts({
    this.fajr = 0,
    this.dhuhr = 0,
    this.asr = 0,
    this.maghrib = 0,
    this.isha = 0,
  });

  int get total => fajr + dhuhr + asr + maghrib + isha;

  QazoCounts copyWith({int? fajr, int? dhuhr, int? asr, int? maghrib, int? isha}) => QazoCounts(
        fajr: fajr ?? this.fajr,
        dhuhr: dhuhr ?? this.dhuhr,
        asr: asr ?? this.asr,
        maghrib: maghrib ?? this.maghrib,
        isha: isha ?? this.isha,
      );
}
