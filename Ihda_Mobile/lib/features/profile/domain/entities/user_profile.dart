class UserProfile {
  final String name;
  final int hadithReadCount;
  final int followingCount;
  final int followersCount;

  const UserProfile({
    required this.name,
    required this.hadithReadCount,
    required this.followingCount,
    required this.followersCount,
  });
}
