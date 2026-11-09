import 'package:flutter/material.dart';

class PrayerPosterWidget extends StatelessWidget {
  final String region;
  final DateTime month;
  final List<dynamic> days;

  const PrayerPosterWidget({
    super.key,
    required this.region,
    required this.month,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1B5E20);
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mosque_rounded, color: primaryColor, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'IHDA MOBILE • NAMOZ TAQVIMI',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      region,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _formatUzbekMonthStatic(month),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('Sana', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: primaryColor))),
                Expanded(flex: 3, child: Text('Bomdod', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: primaryColor), textAlign: TextAlign.center)),
                Expanded(flex: 3, child: Text('Quyosh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: primaryColor), textAlign: TextAlign.center)),
                Expanded(flex: 3, child: Text('Peshshin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: primaryColor), textAlign: TextAlign.center)),
                Expanded(flex: 3, child: Text('Asr', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: primaryColor), textAlign: TextAlign.center)),
                Expanded(flex: 3, child: Text('Shom', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: primaryColor), textAlign: TextAlign.center)),
                Expanded(flex: 3, child: Text('Xufton', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: primaryColor), textAlign: TextAlign.center)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          for (final day in days) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      '${day.date.day}-${_formatShortWeekdayStatic(day.date)}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                  ),
                  for (final prayer in day.prayers)
                    Expanded(
                      flex: 3,
                      child: Text(
                        '${prayer.time.hour.toString().padLeft(2, '0')}:${prayer.time.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 10, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
            if (day != days.last)
              Divider(height: 1, color: Colors.grey.withOpacity(0.15)),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: ColorScheme != null ? MainAxisAlignment.center : MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_rounded, size: 12, color: primaryColor.withOpacity(0.7)),
              const SizedBox(width: 4),
              const Text(
                'Ihda Mobile rasmiy taqvimi',
                style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatUzbekMonthStatic(DateTime date) {
    const months = ['Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun', 'Iyul', 'Avgust', 'Sentabr', 'Oktyabr', 'Noyabr', 'Dekabr'];
    return '${months[date.month - 1]} ${date.year}';
  }

  static String _formatShortWeekdayStatic(DateTime date) {
    const days = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
    return days[date.weekday - 1];
  }
}
