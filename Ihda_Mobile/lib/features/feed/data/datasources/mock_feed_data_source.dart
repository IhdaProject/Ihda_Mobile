import '../../domain/entities/feed_item.dart';
import 'feed_data_source.dart';

/// All mock copy below is original placeholder text written for this
/// preview, except the two short Hadith entries, which are classical,
/// widely-transmitted religious texts (public domain), quoted briefly
/// with their traditional source attribution.
class MockFeedDataSource implements FeedDataSource {
  @override
  Future<List<FeedItem>> getFeed(FeedCategory category) async {
    await Future.delayed(const Duration(milliseconds: 350));
    switch (category) {
      case FeedCategory.community:
        return _community;
      case FeedCategory.hadith:
        return _hadith;
      case FeedCategory.dua:
        return _dua;
      case FeedCategory.verse:
        return _verse;
      case FeedCategory.notificationDaily:
        return _notificationsDaily;
      case FeedCategory.notificationRecommended:
        return _notificationsRecommended;
    }
  }

  static final _community = [
    const FeedItem(
      id: 'c1',
      category: FeedCategory.community,
      authorName: 'Tariq Jamil',
      body: 'Har bir yopiq eshik ortida yangi bir imkoniyat yashiringan bo\'ladi. '
          'Ba\'zan biz tushunmagan narsa aslida bizni asrab qoladi.',
      timeLabel: '2 soat oldin',
      likeCount: 21,
      commentCount: 4,
      shareCount: 985,
    ),
    const FeedItem(
      id: 'c2',
      category: FeedCategory.community,
      authorName: 'Amina Yusupova',
      body: 'Bugun mahalla masjidida birgalikda iftor tashkil qildik. '
          'Kichik yaxshiliklar katta birdamlikka aylanadi.',
      timeLabel: '5 soat oldin',
      likeCount: 48,
      commentCount: 9,
      shareCount: 120,
    ),
    const FeedItem(
      id: 'c3',
      category: FeedCategory.community,
      authorName: 'Tariq Jamil',
      body: 'Sabr - bu passivlik emas, balki ichki kuch bilan kutishdir. '
          'Har bir qiyinchilik his-tuyg\'ularimizni tarbiyalaydi.',
      timeLabel: '1 kun oldin',
      likeCount: 33,
      commentCount: 6,
      shareCount: 410,
    ),
  ];

  static final _hadith = [
    const FeedItem(
      id: 'h1',
      category: FeedCategory.hadith,
      authorName: 'Sahih Muslim',
      title: 'Abu Hurayrah rivoyati (Alloh undan rozi bo\'lsin)',
      body: 'Alloh taqdirni yozib qo\'yganida, U kitobda shunday deb yozgan edi: '
          '"Mening rahmatim g\'azabimdan ustun keladi."',
      timeLabel: '3 soat oldin',
      likeCount: 21,
      commentCount: 1,
      shareCount: 985,
    ),
    const FeedItem(
      id: 'h2',
      category: FeedCategory.hadith,
      authorName: 'Sahih al-Bukhari',
      title: 'Anas ibn Malik rivoyati (Alloh undan rozi bo\'lsin)',
      body: 'Sizlardan hech biringiz o\'zi uchun yoqtirgan narsani birodari uchun '
          'ham yoqtirmagunicha, haqiqiy mo\'min bo\'lolmaydi.',
      timeLabel: '1 kun oldin',
      likeCount: 56,
      commentCount: 3,
      shareCount: 640,
    ),
  ];

  static final _dua = [
    const FeedItem(
      id: 'd1',
      category: FeedCategory.dua,
      authorName: 'Kunlik duo',
      title: 'Ish boshlashdan oldingi duo',
      body: 'Robbi yassir wa la tu\'assir, robbi tammim bil-khoyr.\n'
          '(Robbim, osonlashtirgin, qiyinlashtirmagin, yaxshilik bilan yakunla.)',
      timeLabel: 'Bugun',
      likeCount: 40,
      commentCount: 2,
      shareCount: 210,
    ),
  ];

  static final _verse = [
    const FeedItem(
      id: 'v1',
      category: FeedCategory.verse,
      authorName: 'Kunlik oyat',
      title: 'Baqara surasi, 286-oyat (mazmuni)',
      body: 'Alloh hech bir kishini toqatidan tashqari mas\'uliyat bilan yuklamaydi.',
      timeLabel: 'Bugun',
      likeCount: 62,
      commentCount: 5,
      shareCount: 300,
    ),
  ];

  static final _notificationsDaily = List.generate(
    6,
    (i) => FeedItem(
      id: 'nd$i',
      category: FeedCategory.notificationDaily,
      authorName: 'Namaz Timing',
      body: 'Islom besh ustun asosida quriladi.',
      timeLabel: '${5 + i * 3}m oldin',
      unread: i < 2,
    ),
  );

  static final _notificationsRecommended = List.generate(
    6,
    (i) => FeedItem(
      id: 'nr$i',
      category: FeedCategory.notificationRecommended,
      authorName: 'Namaz Timing',
      body: 'Islom besh ustun asosida quriladi.',
      timeLabel: '${1 + i}soat oldin',
      unread: i < 1,
    ),
  );
}
