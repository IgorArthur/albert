import 'package:albert/features/utils/hive/files/boxes.dart';
import 'package:albert/features/workouts/data/hive/workout_session.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProgressController extends GetxController {
  static ProgressController get to => Get.find();

  // ── Observables ───────────────────────────────────────────────────────────

  final RxInt level = 1.obs;
  final RxInt currentXp = 0.obs;
  final RxInt xpToNextLevel = 250.obs;

  final RxInt streakDays = 0.obs;
  final RxInt totalSessions = 0.obs;
  final RxInt totalSets = 0.obs;
  final RxInt totalVolume = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _calculateStats();
    // Re-calculate if the box changes (e.g., a new session is finished)
    boxWorkoutSessions.listenable().addListener(_calculateStats);
  }

  void _calculateStats() {
    final sessions = boxWorkoutSessions.values
        .whereType<WorkoutSession>()
        .where((s) => s.finishedAt != null)
        .toList();

    sessions.sort((a, b) => b.finishedAt!.compareTo(a.finishedAt!)); // newest first

    totalSessions.value = sessions.length;

    int sets = 0;
    double volume = 0;

    for (final session in sessions) {
      for (final ex in session.exercises) {
        sets += ex.sets;
        volume += (ex.sets * ex.reps * ex.kg);
      }
    }

    totalSets.value = sets;
    totalVolume.value = volume.toInt();

    // XP calculation: 50 XP per session + 1 XP per 100 kg volume
    final computedXp = (sessions.length * 50) + (volume ~/ 100);
    currentXp.value = computedXp;
    
    // Level calculation (Level 1 = 0-249 XP, Level 2 = 250-499, etc.)
    final calculatedLevel = (computedXp ~/ 250) + 1;
    level.value = calculatedLevel;
    
    // XP to next level
    final nextLevelThreshold = calculatedLevel * 250;
    xpToNextLevel.value = nextLevelThreshold - computedXp;

    // Streak calculation
    streakDays.value = _calculateStreak(sessions);
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
