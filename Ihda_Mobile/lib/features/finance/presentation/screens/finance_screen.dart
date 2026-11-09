import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/blurred_bottom_sheet.dart';
import '../../../../shared/widgets/design_background.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/finance_analytics_tab.dart';
import '../widgets/finance_dashboard_tab.dart';
import '../widgets/finance_emergency_fund_tab.dart';
import '../widgets/finance_investment_tab.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: DesignBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: Text(
                        'Shaxsiy Moliya & Sarmoya',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_rounded, size: 28),
                      color: primaryColor,
                      onPressed: () => _showAddTransactionModal(context),
                    ),
                  ],
                ),
              ),

              // TabBar
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: primaryColor,
                unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
                indicatorColor: primaryColor,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Bosh sahifa'),
                  Tab(text: 'Analitika'),
                  Tab(text: 'Zaxira (Fonds)'),
                  Tab(text: 'Sarmoya'),
                ],
              ),

              // TabBarView
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    FinanceDashboardTab(),
                    FinanceAnalyticsTab(),
                    FinanceEmergencyFundTab(),
                    FinanceInvestmentTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTransactionModal(BuildContext context) {
    showBlurredBottomSheet(
      context: context,
      child: const AddTransactionSheet(),
    );
  }
}
