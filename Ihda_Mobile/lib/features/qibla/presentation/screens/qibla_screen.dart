import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/design_background.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../domain/entities/qibla_data.dart';
import '../providers/qibla_providers.dart';
import '../widgets/compass_widget.dart';

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.location.request();
    if (mounted) {
      setState(() {
        _hasPermission = status.isGranted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Joylashuv ruxsati kerak"),
              ElevatedButton(onPressed: _checkPermission, child: const Text("Ruxsat berish")),
            ],
          ),
        ),
      );
    }

    final qiblaAsync = ref.watch(qiblaDataProvider);

    return Scaffold(
      body: DesignBackground(
        isWarning: qiblaAsync.valueOrNull == null || (qiblaAsync.valueOrNull?.deviceHeading == 0),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: Text(
                        'Qibla Direction',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: qiblaAsync.when(
                  loading: () => const LoadingView(message: 'Qiblani qidirilmoqda...'),
                  error: (e, _) => ErrorView(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(qiblaDataProvider),
                  ),
                  data: (data) => _QiblaContent(
                    data: data,
                    isWarning: data.deviceHeading == 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QiblaContent extends StatelessWidget {
  final QiblaData data;
  final bool isWarning;

  const _QiblaContent({required this.data, this.isWarning = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),
        if (isWarning)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.sync_problem_rounded, color: Colors.red),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    "Kompas aniqligi past! Iltimos, telefoningizni 8 shaklida silkitib sozlang.",
                    style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CompassWidget(relativeDirectionDegrees: data.relativeDirection),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  '${data.qiblaBearing.toStringAsFixed(1)}° from true north',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Oltin belgini ekranning yuqorisiga qarating.',
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        _CalibrationWarning(),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _CalibrationWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  "Aniqlikni oshirish uchun:",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            "1. Telefoningizni gorizontal holatda ushlang.\n"
            "2. Telefoningizni havoda 8 shaklida silkitib turing.\n"
            "3. Metall buyumlardan uzoqroq turing.",
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
