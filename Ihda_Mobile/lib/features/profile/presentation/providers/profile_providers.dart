import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/profile_data_source.dart';
import '../../domain/entities/user_profile.dart';

final profileDataSourceProvider = Provider<ProfileDataSource>((ref) => MockProfileDataSource());

final userProfileProvider = FutureProvider.autoDispose<UserProfile>((ref) {
  return ref.watch(profileDataSourceProvider).getProfile();
});
