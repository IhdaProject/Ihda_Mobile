import '../../domain/entities/user_profile.dart';

abstract class ProfileDataSource {
  Future<UserProfile> getProfile();
}

class MockProfileDataSource implements ProfileDataSource {
  @override
  Future<UserProfile> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return const UserProfile(
      name: 'Musa',
      hadithReadCount: 47,
      followingCount: 27,
      followersCount: 686,
    );
  }
}
