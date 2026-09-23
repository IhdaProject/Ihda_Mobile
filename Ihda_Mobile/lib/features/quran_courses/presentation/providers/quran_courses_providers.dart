import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/mock_quran_courses_data_source.dart';
import '../../domain/entities/quran_course_models.dart';

final selectedCountryProvider = StateProvider<String>((ref) => "O'zbekiston");
final selectedRegionProvider = StateProvider<String>((ref) => "Barcha viloyatlar");
final selectedDistrictProvider = StateProvider<String>((ref) => "Barcha tumanlar");
final courseSearchQueryProvider = StateProvider<String>((ref) => "");

final filteredQuranCentersProvider = Provider<List<QuranCenter>>((ref) {
  final country = ref.watch(selectedCountryProvider);
  final region = ref.watch(selectedRegionProvider);
  final district = ref.watch(selectedDistrictProvider);
  final query = ref.watch(courseSearchQueryProvider).trim().toLowerCase();

  return MockQuranCoursesDataSource.centers.where((center) {
    if (country != "Barcha davlatlar" && center.country != country) return false;
    if (region != "Barcha viloyatlar" && center.region != region) return false;
    if (district != "Barcha tumanlar" && center.district != district) return false;

    if (query.isNotEmpty) {
      final matchesCenter = center.name.toLowerCase().contains(query) ||
          center.address.toLowerCase().contains(query) ||
          center.type.toLowerCase().contains(query);
      final matchesCourse = center.courses.any((c) =>
          c.title.toLowerCase().contains(query) ||
          c.description.toLowerCase().contains(query));
      return matchesCenter || matchesCourse;
    }
    return true;
  }).toList();
});

class ApplicationsNotifier extends StateNotifier<List<CourseApplication>> {
  ApplicationsNotifier() : super(MockQuranCoursesDataSource.sampleApplications);

  String submitApplication({
    required QuranCenter center,
    required QuranCourse course,
    required String firstName,
    required String lastName,
    required String middleName,
    required String birthYear,
    required String gender,
    required String passportSeries,
    required String pinfl,
    required String passportImagePath,
    required String photo3x4Path,
  }) {
    final randomNum = Random().nextInt(900000) + 100000;
    final appNumber = "QR-2025-$randomNum";

    final newApplication = CourseApplication(
      applicationNumber: appNumber,
      centerId: center.id,
      centerName: center.name,
      courseId: course.id,
      courseTitle: course.title,
      firstName: firstName,
      lastName: lastName,
      middleName: middleName,
      birthYear: birthYear,
      gender: gender,
      passportSeries: passportSeries.toUpperCase().replaceAll(' ', ''),
      pinfl: pinfl.trim(),
      passportImagePath: passportImagePath,
      photo3x4Path: photo3x4Path,
      status: "Ariza qabul qilindi (Ko'rib chiqilmoqda)",
      estimatedTime: "Taxminiy javob vaqti: 1-2 ish kuni ichida",
      createdAt: DateTime.now(),
    );

    state = [newApplication, ...state];
    return appNumber;
  }

  CourseApplication? findByAppNumberAndPinfl(String appNumber, String pinfl) {
    final cleanApp = appNumber.trim().toUpperCase();
    final cleanPinfl = pinfl.trim();
    return state.firstWhere(
      (a) =>
          a.applicationNumber.toUpperCase() == cleanApp &&
          a.pinfl == cleanPinfl,
      orElse: () => throw Exception('Ariza topilmadi'),
    );
  }

  CourseApplication? findByPassportAndPinfl(String passport, String pinfl) {
    final cleanPass = passport.trim().toUpperCase().replaceAll(' ', '');
    final cleanPinfl = pinfl.trim();
    return state.firstWhere(
      (a) =>
          a.passportSeries.toUpperCase().replaceAll(' ', '') == cleanPass &&
          a.pinfl == cleanPinfl,
      orElse: () => throw Exception('Ariza topilmadi'),
    );
  }
}

final applicationsProvider =
    StateNotifierProvider<ApplicationsNotifier, List<CourseApplication>>((ref) {
  return ApplicationsNotifier();
});
