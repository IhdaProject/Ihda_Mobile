/// Where a repository's data actually comes from.
///
/// This is the ONE switch that decides whether the app runs on mock data
/// or on your real backend. UI code never checks this directly - it only
/// ever talks to a repository interface. Data sources are chosen once,
/// in the provider layer (see each feature's `presentation/providers`).
enum DataSourceMode { mock, api }

class AppEnvironment {
  AppEnvironment._();

  /// Flip this to [DataSourceMode.api] once your backend is ready.
  /// Everything else (UI, state, repositories) keeps working unchanged.
  static const DataSourceMode dataSourceMode = DataSourceMode.mock;

  static bool get isMock => dataSourceMode == DataSourceMode.mock;
  static bool get isApi => dataSourceMode == DataSourceMode.api;
}
