class QuranCenter {
  final String id;
  final String name;
  final String type; // e.g. "Erkaklar va Ayollar uchun", "Ixtisoslashgan Markaz"
  final String country;
  final String region;
  final String district;
  final String address;
  final String imageUrl;
  final String phone;
  final double rating;
  final List<QuranCourse> courses;

  const QuranCenter({
    required this.id,
    required this.name,
    required this.type,
    required this.country,
    required this.region,
    required this.district,
    required this.address,
    required this.imageUrl,
    required this.phone,
    required this.rating,
    required this.courses,
  });
}

class QuranCourse {
  final String id;
  final String centerId;
  final String title;
  final String description;
  final String format; // "Oflayn", "Onlayn"
  final String duration; // "3 oy", "6 oy"
  final String schedule; // "Haftada 3 kun"
  final int applicationsCount;
  final int totalSeats;

  const QuranCourse({
    required this.id,
    required this.centerId,
    required this.title,
    required this.description,
    required this.format,
    required this.duration,
    required this.schedule,
    required this.applicationsCount,
    required this.totalSeats,
  });
}

class CourseApplication {
  final String applicationNumber; // e.g. "QR-2025-784912"
  final String centerId;
  final String centerName;
  final String courseId;
  final String courseTitle;
  final String firstName;
  final String lastName;
  final String middleName;
  final String birthYear;
  final String gender; // "Erkak", "Ayol"
  final String passportSeries; // e.g. "AA1234567"
  final String pinfl; // 14-digit
  final String passportImagePath;
  final String photo3x4Path;
  final String status; // "Ko'rib chiqilmoqda", "Qabul qilindi", "Suhbat belgilandi"
  final String estimatedTime; // "2-3 kun ichida"
  final DateTime createdAt;

  const CourseApplication({
    required this.applicationNumber,
    required this.centerId,
    required this.centerName,
    required this.courseId,
    required this.courseTitle,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.birthYear,
    required this.gender,
    required this.passportSeries,
    required this.pinfl,
    required this.passportImagePath,
    required this.photo3x4Path,
    required this.status,
    required this.estimatedTime,
    required this.createdAt,
  });
}
