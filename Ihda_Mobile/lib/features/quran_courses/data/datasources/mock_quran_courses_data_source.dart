import '../../domain/entities/quran_course_models.dart';

class MockQuranCoursesDataSource {
  static const List<String> countries = [
    "Barcha davlatlar",
    "O'zbekiston",
    "Qozog'iston",
    "Qirg'iziston",
  ];

  static const Map<String, List<String>> regionsByCountry = {
    "O'zbekiston": [
      "Barcha viloyatlar",
      "Toshkent shahri",
      "Andijon viloyati",
      "Samarqand viloyati",
      "Farg'ona viloyati",
      "Namangan viloyati",
      "Buxoro viloyati",
    ],
    "Qozog'iston": ["Barcha viloyatlar", "Olmaota shahri", "Ostona shahri"],
    "Qirg'iziston": ["Barcha viloyatlar", "Osh shahri", "Bishkek shahri"],
  };

  static const Map<String, List<String>> districtsByRegion = {
    "Toshkent shahri": [
      "Barcha tumanlar",
      "Yunusobod tumani",
      "Chilonzor tumani",
      "Shayxontohur tumani",
      "Olmazor tumani",
      "Mirobod tumani",
    ],
    "Andijon viloyati": ["Barcha tumanlar", "Andijon shahri", "Asaka tumani", "Shahrixon tumani"],
    "Samarqand viloyati": ["Barcha tumanlar", "Samarqand shahri", "Kattaqo'rg'on tumani", "Pastdarg'om tumani"],
    "Farg'ona viloyati": ["Barcha tumanlar", "Farg'ona shahri", "Marg'ilon shahri", "Qo'qon shahri"],
    "Namangan viloyati": ["Barcha tumanlar", "Namangan shahri", "Chust tumani", "Pop tumani"],
    "Buxoro viloyati": ["Barcha tumanlar", "Buxoro shahri", "G'ijduvon tumani"],
  };

  static final List<QuranCenter> centers = [
    QuranCenter(
      id: "center_1",
      name: "Imom Buxoriy Qur'on va Fonetika Markazi",
      type: "Erkaklar va Ayollar uchun (Oflayn / Onlayn)",
      country: "O'zbekiston",
      region: "Toshkent shahri",
      district: "Yunusobod tumani",
      address: "Yunusobod 11-mavze, Amir Temur ko'chasi 45-uy",
      imageUrl: "assets/app_icon.png",
      phone: "+998 71 200-11-22",
      rating: 4.9,
      courses: [
        QuranCourse(
          id: "course_101",
          centerId: "center_1",
          title: "Qur'on o'qish va Tajvid fonetikasi (Boshlang'ich)",
          description: "Harflar maxroji, to'g'ri talaffuz, qoidalar va tajvid asoslarini o'rgatuvchi bosqich.",
          format: "Oflayn va Onlayn",
          duration: "3 oy",
          schedule: "Haftada 3 kun (Dush, Chor, Juma)",
          applicationsCount: 142,
          totalSeats: 200,
        ),
        QuranCourse(
          id: "course_102",
          centerId: "center_1",
          title: "Tajvid va Tilovatni mukammallashtirish (Yuqori bosqich)",
          description: "Rivojlangan tajvid qoidalari va ravon o'qish tajribasi.",
          format: "Oflayn",
          duration: "4 oy",
          schedule: "Haftada 3 kun (Sesh, Pay, Shanba)",
          applicationsCount: 88,
          totalSeats: 120,
        ),
      ],
    ),
    QuranCenter(
      id: "center_2",
      name: "Al-Azhar Qur me'yori va San'at Markazi",
      type: "Ayollar va Qizlar uchun maxsus",
      country: "O'zbekiston",
      region: "Toshkent shahri",
      district: "Chilonzor tumani",
      address: "Chilonzor 7-mavze, Qatortol ko'chasi 18-uy",
      imageUrl: "assets/app_icon.png",
      phone: "+998 71 230-44-55",
      rating: 4.8,
      courses: [
        QuranCourse(
          id: "course_201",
          centerId: "center_2",
          title: "Qur'oniy Fonetika va Savodxonlik",
          description: "Ayol va qizlar uchun qulay va sokin muhitda Qur'on ta'limi.",
          format: "Oflayn",
          duration: "3 oy",
          schedule: "Haftada 3 kun (Erta tong / Tushdan keyin)",
          applicationsCount: 95,
          totalSeats: 150,
        ),
      ],
    ),
    QuranCenter(
      id: "center_3",
      name: "Andijon Mintaqaviy Qur'on va Tajvid Akademiyasi",
      type: "Barcha yoshdagilar uchun",
      country: "O'zbekiston",
      region: "Andijon viloyati",
      district: "Andijon shahri",
      address: "Andijon sh., Navoiy shoh ko'chasi 12-uy",
      imageUrl: "assets/app_icon.png",
      phone: "+998 74 222-33-44",
      rating: 4.9,
      courses: [
        QuranCourse(
          id: "course_301",
          centerId: "center_3",
          title: "Qur'on Fonetikasi va Ma'xroj Darslari",
          description: "Harf tovushlarini to'g'ri chiqarish va tajvid darslari.",
          format: "Oflayn",
          duration: "3 oy",
          schedule: "Haftada 3 kun",
          applicationsCount: 110,
          totalSeats: 180,
        ),
      ],
    ),
    QuranCenter(
      id: "center_4",
      name: "Samarqand Ilm va Tajvid Ziyo Markazi",
      type: "Aholining keng qatlami uchun",
      country: "O'zbekiston",
      region: "Samarqand viloyati",
      district: "Samarqand shahri",
      address: "Samarqand sh., Dagbitskaya ko'chasi 5-uy",
      imageUrl: "assets/app_icon.png",
      phone: "+998 66 233-55-66",
      rating: 4.7,
      courses: [
        QuranCourse(
          id: "course_401",
          centerId: "center_4",
          title: "Boshlang'ich Qur'on O'qish Kursi",
          description: "Noldan boshlab ravon o'qish darajasigacha ta'lim.",
          format: "Oflayn / Onlayn",
          duration: "3 oy",
          schedule: "Haftada 3 kun",
          applicationsCount: 76,
          totalSeats: 100,
        ),
      ],
    ),
  ];

  // Initial demo submitted application for quick testing
  static final List<CourseApplication> sampleApplications = [
    CourseApplication(
      applicationNumber: "QR-2025-100101",
      centerId: "center_1",
      centerName: "Imom Buxoriy Qur'on va Fonetika Markazi",
      courseId: "course_101",
      courseTitle: "Qur'on o'qish va Tajvid fonetikasi (Boshlang'ich)",
      firstName: "Ahmad",
      lastName: "Aliyev",
      middleName: "Valiyevich",
      birthYear: "1995",
      gender: "Erkak",
      passportSeries: "AA1234567",
      pinfl: "30102030405060",
      passportImagePath: "passport_image_sample.jpg",
      photo3x4Path: "photo_3x4_sample.jpg",
      status: "Qabul qilindi (Suhbat belgilandi)",
      estimatedTime: "Boshlanish sanasi: 1-Aprel, 2025-yil",
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
}
