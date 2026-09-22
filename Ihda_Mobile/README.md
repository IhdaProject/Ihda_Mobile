# Namaz Timing

A Flutter Islamic companion app: prayer times with a live countdown, nearby
mosques, Qibla compass, Hadith/Dua/Verse content, a community feed,
notifications, and a profile with settings. Runs completely offline on
mock data out of the box.

> **Note on the design source:** the real screen names/content came from
> screenshots and an Android-vector export you shared (not a live Figma
> pull — Figma disallows automated fetching and needs an authenticated
> session). Layouts here are a close reconstruction of what was visible in
> those exports, not a pixel-perfect trace — colors, spacing and any
> content that wasn't visible (e.g. exact icons/images) are reasonable
> placeholders you can refine once you have the full design files.

## 1. Install & run

```bash
flutter pub get
flutter run
```

If you haven't already, run `flutter create .` once in the project root to
generate the `android/`, `ios/`, `linux/`, `web/`, `windows/`, `macos/`
platform folders (these aren't included in the zip since they're
machine/SDK-generated).

## 2. App structure (bottom navigation)

| Tab | Screen | Notes |
|---|---|---|
| Asosiy | Home | Search bar, live prayer countdown, quick actions, nearby mosques |
| Boshqalar | More | Grid: Hadislar, Duolar, Kundalik oyat, Community, Xarita, Tasbeh, Qazo, Qibla, Taqvim, Islom.uz, Radio |
| Tanlanganlar | Favorites | Saved mosques, 2-column grid |
| Joylashuv | Map | Placeholder map + nearest-mosque card |
| Profil | Profile | Stats, links to Favorites/Settings/Notifications/Log out |

Screens reached by navigating in (not bottom-nav tabs): Mosque detail
(prayer schedule + directions), Notifications (Daily/Recommended),
Hadith & Dua (also serves Duolar/Kundalik oyat), Community, Settings,
Tasbih counter, Qazo (missed-prayer) tracker, Qibla compass, Prayer
calendar.

## 3. Architecture

Feature-based, one-way dependency flow per feature:

```
UI (screens/widgets)
  -> Riverpod providers/controllers
    -> Repository (interface)
      -> DataSource (interface)
        -> Mock DataSource   |   Api DataSource
```

```
lib/
├── app/                     # Shell: theme, routes, bottom-nav shell, More screen
├── core/                    # AppEnvironment (mock/API switch), ApiClient, constants, utils
├── shared/widgets/          # AppCard, SectionHeader, Loading/Error/Empty views
└── features/
    ├── prayer_times/        # Home screen, countdown, monthly calendar
    ├── mosques/             # Mosque list/detail/favorites, prayer schedule table
    ├── feed/                # Unified model for Community, Hadith/Dua/Verse, Notifications
    ├── profile/             # Profile screen + stats
    ├── location/            # City/coordinates (mocked to Tashkent)
    ├── qibla/                # Bearing calculation + compass UI
    ├── map/                 # Placeholder map screen
    ├── tasbih/               # Tasbih counter (local state only)
    ├── qazo/                 # Missed-prayer tracker (local state only)
    ├── notifications/        # Reminder-scheduling abstraction (separate from the feed/notification screen)
    └── settings/             # Account/Notification/Prayer/Other sections, persisted prefs
```

Most features follow the full domain/data/presentation split described in
the previous version of this README. `tasbih` and `qazo` are simple enough
(pure local counters) that they skip the repository/data-source layers and
just use a Riverpod `Notifier` directly - no mock/API split needed since
there's no data to fetch.

## 4. How mock mode works

`lib/core/config/app_environment.dart`:

```dart
enum DataSourceMode { mock, api }
class AppEnvironment {
  static const DataSourceMode dataSourceMode = DataSourceMode.mock;
}
```

Each feature's provider file (e.g. `mosque_providers.dart`,
`prayer_providers.dart`) picks its concrete data source from this one flag.
UI code never checks it directly.

Mock data sources today:
- `MockPrayerDataSource` - realistic times with seasonal drift.
- `MockMosqueDataSource` - 6 mosques (a few reference real, well-known
  Tashkent landmarks as recognizable placeholder names; schedules/distances
  are made up). Favoriting persists in-memory for the session.
- `MockLocationDataSource` - fixed to Tashkent.
- `MockQiblaDataSource` - real great-circle bearing, simulated heading.
- `MockFeedDataSource` - original placeholder text for Community/Dua/Verse;
  two short, classical Hadith texts (public-domain religious sources,
  quoted briefly with attribution) for the Hadith tab.
- `MockProfileDataSource` - a fixed demo profile.

## 5. Switching to your real backend

1. Set `AppEnvironment.dataSourceMode = DataSourceMode.api;`
2. Set your URL in `lib/core/constants/app_constants.dart` (`apiBaseUrl`).
3. `lib/features/prayer_times/data/datasources/api_prayer_data_source.dart`
   is already wired to `PrayerDayModel.fromJson`/`toEntity()` - adjust
   endpoints/JSON shape to match your API.
4. For `mosques`, `feed`, `profile`, `location`, and `qibla`, add an
   `Api<Feature>DataSource` implementing that feature's abstract
   `DataSource` class, then select it in that feature's
   `presentation/providers/*.dart` the same way `prayer_providers.dart`
   does it.

## 6. Where things are

| Concern | File |
|---|---|
| API base URL | `lib/core/constants/app_constants.dart` |
| Mock/API switch | `lib/core/config/app_environment.dart` |
| Home screen | `lib/features/prayer_times/presentation/screens/home_screen.dart` |
| More/Boshqalar grid | `lib/app/more_screen.dart` |
| Mosque detail + schedule | `lib/features/mosques/presentation/screens/mosque_detail_screen.dart` |
| Favorites | `lib/features/mosques/presentation/screens/favorites_screen.dart` |
| Map | `lib/features/map/presentation/screens/map_screen.dart` |
| Community / Hadith & Dua / Notifications | `lib/features/feed/presentation/screens/` |
| Profile | `lib/features/profile/presentation/screens/profile_screen.dart` |
| Settings | `lib/features/settings/presentation/screens/settings_screen.dart` |
| Qibla compass | `lib/features/qibla/presentation/screens/qibla_screen.dart` |
| Prayer calendar | `lib/features/prayer_times/presentation/screens/prayer_calendar_screen.dart` |
| Colors / type / spacing / dark theme | `lib/app/theme/` |
| Bottom navigation | `lib/app/main_shell.dart` |

## 7. Known limitations

- Not a pixel-perfect trace of your Figma file - reconstructed from
  screenshots/exports. Exact colors, image assets, and any screen content
  not visible in what was shared are placeholders.
- No Flutter SDK/pub.dev access in the environment this was written in, so
  the code was reviewed manually (import-path resolution, brace/paren
  balance, extension-import correctness) rather than compiler-verified.
  Please run `flutter analyze` after `flutter pub get` and share any
  errors that surface.
- Map screen uses a simple painted placeholder, not a real maps SDK/API
  key - swap in `google_maps_flutter` or `flutter_map` when ready.
- "Islom.uz" and "Radio" in the More grid are stubs (external link /
  snackbar placeholder) rather than a real webview or audio player.
- Hijri date conversion is an approximation, not a dedicated Hijri package.
