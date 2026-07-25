import 'package:albert/features/utils/hive/files/boxes.dart';
import 'package:albert/features/workouts/data/hive/exercise.dart';
import 'package:albert/features/workouts/data/hive/workout_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum SessionFilterOption { last7Days, last14Days, last28Days, custom }

class DailyProgress {
  final DateTime date;
  final String dayLabel;
  final String dateNum;
  final int sets;
  final int volume;

  DailyProgress({
    required this.date,
    required this.dayLabel,
    required this.dateNum,
    required this.sets,
    required this.volume,
  });
}

class ProgressController extends GetxController {
  static ProgressController get to => Get.find();

  // ── Firestore Reference ───────────────────────────────────────────────────

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _progressDoc {
    final uid = _userId;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('progress')
        .doc('stats');
  }

  // ── Observables ───────────────────────────────────────────────────────────

  final RxInt level = 1.obs;
  final RxInt currentXp = 0.obs;
  final RxInt xpToNextLevel = 250.obs;

  final RxInt streakDays = 0.obs;
  final RxInt totalSessions = 0.obs;
  final RxInt totalSets = 0.obs;
  final RxInt totalVolume = 0.obs;
  final RxInt totalTimeSeconds = 0.obs;

  final RxList<DailyProgress> last14DaysData = <DailyProgress>[].obs;
  final RxList<WorkoutSession> sessionsList = <WorkoutSession>[].obs;

  final Rx<SessionFilterOption> selectedFilter =
      SessionFilterOption.last7Days.obs;
  final Rx<DateTimeRange?> customDateRange = Rx<DateTimeRange?>(null);
  final RxBool isLoadingSessions = false.obs;

  String get customRangeLabel {
    final range = customDateRange.value;
    if (range == null) return 'Custom';
    final s = range.start;
    final e = range.end;
    return '${s.day.toString().padLeft(2, '0')}/${s.month.toString().padLeft(2, '0')} - ${e.day.toString().padLeft(2, '0')}/${e.month.toString().padLeft(2, '0')}';
  }

  int get maxSetsIn14Days =>
      last14DaysData.fold(0, (max, d) => d.sets > max ? d.sets : max);

  int get totalSetsIn14Days =>
      last14DaysData.fold(0, (sum, d) => sum + d.sets);

  String get formattedTotalTime {
    final seconds = totalTimeSeconds.value;
    if (seconds <= 0) return '0s';
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) {
      final mins = seconds ~/ 60;
      final secs = seconds % 60;
      return secs > 0 ? '${mins}m ${secs}s' : '${mins}m';
    }
    final hours = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }

  String get formattedTotalVolume {
    final vol = totalVolume.value;
    if (vol <= 0) return '0 kg';
    final str = vol.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return '${buffer.toString()} kg';
  }

  @override
  void onInit() {
    super.onInit();
    _calculateStats();
    fetchFilteredSessionsFromRemote();
    // Re-calculate if the box changes (e.g., a new session is finished)
    boxWorkoutSessions.listenable().addListener(() {
      _calculateStats();
      fetchFilteredSessionsFromRemote();
    });
  }

  void setFilter(SessionFilterOption filter) {
    if (selectedFilter.value == filter && filter != SessionFilterOption.custom) {
      return;
    }
    selectedFilter.value = filter;
    fetchFilteredSessionsFromRemote();
  }

  void setCustomFilter(DateTimeRange range) {
    customDateRange.value = range;
    selectedFilter.value = SessionFilterOption.custom;
    fetchFilteredSessionsFromRemote();
  }

  /// Query Firestore for filtered sessions based on selectedFilter / date range.
  Future<void> fetchFilteredSessionsFromRemote() async {
    final uid = _userId;
    isLoadingSessions.value = true;

    DateTime startDate;
    final now = DateTime.now();
    DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (selectedFilter.value) {
      case SessionFilterOption.last7Days:
        startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
        break;
      case SessionFilterOption.last14Days:
        startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 14));
        break;
      case SessionFilterOption.last28Days:
        startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 28));
        break;
      case SessionFilterOption.custom:
        if (customDateRange.value != null) {
          startDate = DateTime(
            customDateRange.value!.start.year,
            customDateRange.value!.start.month,
            customDateRange.value!.start.day,
            0, 0, 0,
          );
          endDate = DateTime(
            customDateRange.value!.end.year,
            customDateRange.value!.end.month,
            customDateRange.value!.end.day,
            23, 59, 59,
          );
        } else {
          startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
        }
        break;
    }

    try {
      if (uid != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('sessions')
            .get(const GetOptions(source: Source.server));

        final List<WorkoutSession> remoteSessions = [];

        for (final doc in snapshot.docs) {
          final data = doc.data();
          final session = _sessionFromMap(data);
          if (session.startedAt.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
              session.startedAt.isBefore(endDate.add(const Duration(seconds: 1)))) {
            remoteSessions.add(session);
          }
        }

        remoteSessions.sort((a, b) => (b.finishedAt ?? b.startedAt)
            .compareTo(a.finishedAt ?? a.startedAt));

        sessionsList.assignAll(remoteSessions);
        debugPrint(
            'Fetched ${remoteSessions.length} sessions from Firestore server query for filter ${selectedFilter.value}');
      } else {
        _filterLocalSessions(startDate, endDate);
      }
    } catch (e) {
      debugPrint(
          'Error querying sessions from Firestore server: $e. Falling back to local storage.');
      _filterLocalSessions(startDate, endDate);
    } finally {
      isLoadingSessions.value = false;
    }
  }

  void _filterLocalSessions(DateTime startDate, DateTime endDate) {
    final localSessions = boxWorkoutSessions.values
        .whereType<WorkoutSession>()
        .where((s) =>
            s.startedAt.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
            s.startedAt.isBefore(endDate.add(const Duration(seconds: 1))))
        .toList();

    localSessions.sort((a, b) =>
        (b.finishedAt ?? b.startedAt).compareTo(a.finishedAt ?? a.startedAt));

    sessionsList.assignAll(localSessions);
  }

  WorkoutSession _sessionFromMap(Map<String, dynamic> data) {
    final exercisesData = data['exercises'] as List<dynamic>? ?? [];
    final exercises = exercisesData.map((e) {
      final map = e as Map<String, dynamic>;
      return Exercise(
        name: map['name'] as String? ?? '',
        sets: (map['sets'] as num? ?? 0).toInt(),
        reps: (map['reps'] as num? ?? 0).toInt(),
        kg: (map['kg'] as num? ?? 0).toDouble(),
      );
    }).toList();

    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return WorkoutSession(
      id: data['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      routineId: data['routineId'] as String? ?? '',
      routineName: data['routineName'] as String? ?? '',
      startedAt: parseDate(data['startedAt']),
      finishedAt: data['finishedAt'] != null ? parseDate(data['finishedAt']) : null,
      exercises: exercises,
    );
  }

  void _calculateStats() {
    final allSessions = boxWorkoutSessions.values
        .whereType<WorkoutSession>()
        .toList();

    final finishedSessions = allSessions
        .where((s) => s.finishedAt != null)
        .toList();

    allSessions.sort((a, b) => (b.finishedAt ?? b.startedAt)
        .compareTo(a.finishedAt ?? a.startedAt)); // newest first

    sessionsList.assignAll(allSessions);

    finishedSessions.sort((a, b) => b.finishedAt!.compareTo(a.finishedAt!)); // newest first

    totalSessions.value = finishedSessions.length;

    int sets = 0;
    double volume = 0;
    int seconds = 0;

    for (final session in allSessions) {
      if (session.finishedAt != null) {
        seconds += session.finishedAt!.difference(session.startedAt).inSeconds;
      } else {
        seconds += DateTime.now().difference(session.startedAt).inSeconds;
      }
      for (final ex in session.exercises) {
        sets += ex.sets;
        volume += (ex.sets * ex.reps * ex.kg);
      }
    }

    totalSets.value = sets;
    totalVolume.value = volume.toInt();
    totalTimeSeconds.value = seconds;

    // XP calculation: 50 XP per session + 1 XP per 100 kg volume
    final computedXp = (finishedSessions.length * 50) + (volume ~/ 100);
    currentXp.value = computedXp;
    
    // Level calculation (Level 1 = 0-249 XP, Level 2 = 250-499, etc.)
    final calculatedLevel = (computedXp ~/ 250) + 1;
    level.value = calculatedLevel;
    
    // XP to next level
    final nextLevelThreshold = calculatedLevel * 250;
    xpToNextLevel.value = nextLevelThreshold - computedXp;

    // Streak calculation
    streakDays.value = _calculateStreak(finishedSessions);

    // Calculate last 14 days stats
    final List<DailyProgress> dailyList = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    const weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    for (int i = 13; i >= 0; i--) {
      final targetDate = today.subtract(Duration(days: i));
      int daySets = 0;
      double dayVol = 0;

      for (final s in finishedSessions) {
        if (s.finishedAt != null) {
          final sDate =
              DateTime(s.finishedAt!.year, s.finishedAt!.month, s.finishedAt!.day);
          if (sDate.isAtSameMomentAs(targetDate)) {
            for (final ex in s.exercises) {
              daySets += ex.sets;
              dayVol += (ex.sets * ex.reps * ex.kg);
            }
          }
        }
      }

      dailyList.add(DailyProgress(
        date: targetDate,
        dayLabel: weekDays[targetDate.weekday - 1],
        dateNum: targetDate.day.toString(),
        sets: daySets,
        volume: dayVol.toInt(),
      ));
    }

    last14DaysData.assignAll(dailyList);

    // Sync progress stats to Firestore remotely
    syncProgressToFirestore();
  }

  /// Sync calculated progress stats to Firestore under `users/{uid}/progress/stats`.
  Future<void> syncProgressToFirestore() async {
    final doc = _progressDoc;
    if (doc == null) return;

    final data = {
      'level': level.value,
      'currentXp': currentXp.value,
      'xpToNextLevel': xpToNextLevel.value,
      'streakDays': streakDays.value,
      'totalSessions': totalSessions.value,
      'totalSets': totalSets.value,
      'totalVolume': totalVolume.value,
      'totalTimeSeconds': totalTimeSeconds.value,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      await doc.set(data, SetOptions(merge: true));
      debugPrint('User progress stats synced to Firestore: users/$_userId/progress/stats');
    } catch (e) {
      debugPrint('Error syncing progress stats to Firestore: $e');
      _showLocalOnlyNotice();
    }
  }

  /// Hydrate user progress stats from Firestore.
  Future<void> fetchProgressFromRemote() async {
    final doc = _progressDoc;
    if (doc == null) return;

    try {
      final snapshot = await doc.get();
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        level.value = data['level'] as int? ?? level.value;
        currentXp.value = data['currentXp'] as int? ?? currentXp.value;
        xpToNextLevel.value = data['xpToNextLevel'] as int? ?? xpToNextLevel.value;
        streakDays.value = data['streakDays'] as int? ?? streakDays.value;
        totalSessions.value = data['totalSessions'] as int? ?? totalSessions.value;
        totalSets.value = data['totalSets'] as int? ?? totalSets.value;
        totalVolume.value = data['totalVolume'] as int? ?? totalVolume.value;
        totalTimeSeconds.value = data['totalTimeSeconds'] as int? ?? totalTimeSeconds.value;
        debugPrint('Successfully fetched user progress stats from Firestore for $_userId');
      }
    } catch (e) {
      debugPrint('Error loading progress stats from Firestore: $e');
    }
  }

  void _showLocalOnlyNotice() {
    Get.snackbar(
      'workouts_remote_save_error_title'.tr,
      'workouts_remote_save_error'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.withValues(alpha: 0.9),
      colorText: Colors.white,
    );
  }

  int _calculateStreak(List<WorkoutSession> sortedSessions) {
    if (sortedSessions.isEmpty) return 0;

    int streak = 0;
    DateTime now = DateTime.now();
    DateTime currentDate = DateTime(now.year, now.month, now.day);
    
    // Extract unique dates of sessions (midnight normalized)
    final sessionDates = sortedSessions.map((s) {
      return DateTime(s.finishedAt!.year, s.finishedAt!.month, s.finishedAt!.day);
    }).toSet().toList();
    
    sessionDates.sort((a, b) => b.compareTo(a)); // newest first

    // Check if the most recent session was today or yesterday
    if (sessionDates.isEmpty) return 0;
    
    final difference = currentDate.difference(sessionDates.first).inDays;
    if (difference > 1) {
      return 0; // Streak lost
    }

    DateTime checkDate = sessionDates.first;
    streak = 1;

    for (int i = 1; i < sessionDates.length; i++) {
      final prevDate = sessionDates[i];
      if (checkDate.difference(prevDate).inDays == 1) {
        streak++;
        checkDate = prevDate;
      } else {
        break;
      }
    }

    return streak;
  }
}
