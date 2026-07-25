import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/hive/files/boxes.dart';
import 'package:albert/features/workouts/data/hive/exercise.dart';
import 'package:albert/features/workouts/data/hive/routine.dart';
import 'package:albert/features/workouts/presentation/pages/add_workout_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkoutsController extends GetxController {
  static WorkoutsController get to => Get.find();

  final RxList<Routine> routines = <Routine>[].obs;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _routinesCollection {
    final uid = _userId;
    if (uid == null || uid.isEmpty) {
      return FirebaseFirestore.instance.collection('routines');
    }
    return FirebaseFirestore.instance.collection('users').doc(uid).collection('routines');
  }

  void refreshRoutines() {
    _loadRoutines();
  }

  // New/edit routine builder draft state
  final TextEditingController newRoutineNameController = TextEditingController();
  final RxString newRoutineIcon = '🔥'.obs;
  final RxList<Exercise> newRoutineExercises = <Exercise>[].obs;
  final List<String> draftIcons = ['🔥', '⚡', '🦵', '💪', '🏋️', '🥊', '🏃', '🧘'];

  // Tracks the id of the routine being edited (null = creating new)
  String? editingRoutineId;
  
  // Stores a routine that should be opened in the edit sheet as soon as the Workouts tab mounts
  Routine? _pendingEditRoutine;

  // ── Biset state ───────────────────────────────────────────────────────────

  /// Index of the card that initiated the biset picking flow (null = not picking).
  final RxnInt pickingBisetIndex = RxnInt();

  /// Maps secondary-exercise index → primary-exercise index.
  final RxMap<int, int> bisetLinks = <int, int>{}.obs;

  // ─── Getters ──────────────────────────────────────────────────────────────

  bool get isEditingMode => editingRoutineId != null;

  String get sheetTitle =>
      isEditingMode ? 'workouts_edit_routine'.tr : 'workouts_new_routine'.tr;

  String get saveButtonLabel =>
      isEditingMode ? 'workouts_save_changes'.tr : 'workouts_save_routine'.tr;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadRoutines();
  }

  @override
  void onClose() {
    newRoutineNameController.dispose();
    super.onClose();
  }

  // ─── Sheet actions ────────────────────────────────────────────────────────

  void showAddSheet(BuildContext context) {
    resetNewRoutineDraft();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddWorkoutSheet(),
    );
  }

  void setPendingEditRoutine(Routine routine) {
    _pendingEditRoutine = routine;
  }

  void handlePendingEditSheet(BuildContext context) {
    if (_pendingEditRoutine != null) {
      final routine = _pendingEditRoutine!;
      _pendingEditRoutine = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showEditSheet(context, routine);
      });
    }
  }

  void showEditSheet(BuildContext context, Routine routine) {
    loadRoutineForEdit(routine);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddWorkoutSheet(),
    );
  }

  // ─── Delete confirmation ──────────────────────────────────────────────────

  void confirmDelete(BuildContext context, Routine routine) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'workouts_delete_title'.tr,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'workouts_delete_body'.trParams({'name': routine.name}),
          style: const TextStyle(color: AppColors.neutral60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('workouts_cancel'.tr,
                style: const TextStyle(color: AppColors.neutral60)),
          ),
          TextButton(
            onPressed: () {
              deleteRoutine(routine.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'workouts_deleted_body'.trParams({'name': routine.name}),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    ),
                  ),
                  backgroundColor: Theme.of(context).cardColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'workouts_delete'.tr,
              style: const TextStyle(
                  color: AppColors.error100, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Draft management ─────────────────────────────────────────────────────

  void resetNewRoutineDraft() {
    editingRoutineId = null;
    newRoutineNameController.clear();
    newRoutineIcon.value = '🔥';
    newRoutineExercises.assignAll([
      Exercise(name: '', sets: 3, reps: 10, kg: 0),
    ]);
    _resetBisetState();
  }

  void loadRoutineForEdit(Routine routine) {
    editingRoutineId = routine.id;
    newRoutineNameController.text = routine.name;
    newRoutineIcon.value = routine.icon;
    newRoutineExercises.assignAll(
      routine.exercises
          .map((e) => Exercise(name: e.name, sets: e.sets, reps: e.reps, kg: e.kg))
          .toList(),
    );
  }

  void addExerciseToDraft() {
    newRoutineExercises.add(Exercise(name: '', sets: 3, reps: 10, kg: 0));
  }

  void removeExerciseFromDraft(int index) {
    if (newRoutineExercises.length > 1) {
      newRoutineExercises.removeAt(index);
      _resetBisetState(); // indices shift on removal — safest to reset
    }
  }

  // ── Biset actions ─────────────────────────────────────────────────────────

  void startPickingBiset(int fromIndex) {
    pickingBisetIndex.value = fromIndex;
  }

  void cancelBisetPicking() {
    pickingBisetIndex.value = null;
  }

  void linkBiset(int toIndex) {
    final from = pickingBisetIndex.value;
    if (from == null || from == toIndex) return;
    bisetLinks[toIndex] = from;
    pickingBisetIndex.value = null;
  }

  void unlinkBiset(int secondaryIndex) {
    bisetLinks.remove(secondaryIndex);
  }

  void _resetBisetState() {
    pickingBisetIndex.value = null;
    bisetLinks.clear();
  }

  void selectIconForDraft(String icon) {
    newRoutineIcon.value = icon;
  }

  // ─── Save / Update ────────────────────────────────────────────────────────

  bool saveRoutine([BuildContext? context]) {
    final name = newRoutineNameController.text.trim();
    final validationError = validateRoutine(name, newRoutineExercises);
    if (validationError != null) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationError),
            backgroundColor: AppColors.error100,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        Get.snackbar(
          'workouts_validation_error'.tr,
          validationError,
          backgroundColor: AppColors.error100,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return false;
    }

    if (isEditingMode) {
      _updateRoutine(editingRoutineId!, name);
    } else {
      final newRoutine = Routine(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        icon: newRoutineIcon.value,
        createdAt: DateTime.now(),
        exercises: List<Exercise>.from(newRoutineExercises),
      );
      addRoutine(newRoutine);
    }
    return true;
  }

  void _updateRoutine(String id, String name) async {
    final index = routines.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final updated = Routine(
      id: id,
      name: name,
      icon: newRoutineIcon.value,
      createdAt: routines[index].createdAt,
      exercises: List<Exercise>.from(newRoutineExercises),
    );

    boxRoutines.put(id, updated);
    routines[index] = updated;

    try {
      final col = _routinesCollection;
      await col.doc(id).set(_routineToJson(updated));
      debugPrint('Routine updated in Firestore at path: ${col.path}/$id (User UID: $_userId)');
    } catch (e) {
      debugPrint('Error syncing updated routine: $e');
      _showLocalOnlyNotice();
    }
  }

  void _showLocalOnlyNotice() {
    try {
      Get.snackbar(
        'workouts_remote_save_error_title'.tr,
        'workouts_remote_save_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surfaceCard,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      debugPrint('Could not show snackbar: $e');
    }
  }

  // ─── Validation ───────────────────────────────────────────────────────────

  String? validateRoutine(String name, List<Exercise> exercises) {
    if (name.trim().isEmpty) return 'workouts_validation_name'.tr;
    if (exercises.isEmpty) return 'workouts_validation_one_exercise'.tr;
    for (var i = 0; i < exercises.length; i++) {
      final exercise = exercises[i];
      if (exercise.name.trim().isEmpty) {
        return 'workouts_validation_exercise_name'
            .trParams({'index': '${i + 1}'});
      }
      if (exercise.sets <= 0) {
        return 'workouts_validation_sets'.trParams({'name': exercise.name});
      }
      if (exercise.reps <= 0) {
        return 'workouts_validation_reps'.trParams({'name': exercise.name});
      }
      if (exercise.kg < 0) {
        return 'workouts_validation_weight'.trParams({'name': exercise.name});
      }
    }
    return null;
  }

  // ─── CRUD ─────────────────────────────────────────────────────────────────

  void addRoutine(Routine routine) async {
    boxRoutines.put(routine.id, routine);
    routines.add(routine);

    try {
      final col = _routinesCollection;
      await col.doc(routine.id).set(_routineToJson(routine));
      debugPrint('Routine synced to Firestore at path: ${col.path}/${routine.id} (User UID: $_userId)');
    } catch (e) {
      debugPrint('Error syncing added routine: $e');
      _showLocalOnlyNotice();
    }
  }

  void deleteRoutine(String id) async {
    boxRoutines.delete(id);
    routines.removeWhere((r) => r.id == id);

    try {
      final col = _routinesCollection;
      await col.doc(id).delete();
      debugPrint('Routine deleted from Firestore: $id');
    } catch (e) {
      debugPrint('Error syncing deleted routine: $e');
      _showLocalOnlyNotice();
    }
  }

  // ─── Session ──────────────────────────────────────────────────────────────
  // Session lifecycle is now handled by SessionController.

  // ─── Load ─────────────────────────────────────────────────────────────────

  void _loadRoutines() async {
    routines.assignAll(boxRoutines.values.toList().cast<Routine>());

    try {
      final col = _routinesCollection;
      final snapshot = await col.get();
      if (snapshot.docs.isNotEmpty) {
        await boxRoutines.clear();
        final List<Routine> remoteRoutines = [];
        for (final doc in snapshot.docs) {
          final r = _routineFromJson(doc.data());
          remoteRoutines.add(r);
          await boxRoutines.put(r.id, r);
        }
        remoteRoutines.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        routines.assignAll(remoteRoutines);
        debugPrint('Successfully hydrated ${remoteRoutines.length} routines from Firestore');
      }
    } catch (e) {
      debugPrint('Error loading routines from Firestore: $e');
    }
  }
}

// ─── JSON helpers ───────────────────────────────────────────────────────────

Map<String, dynamic> _exerciseToJson(Exercise e) => {
      'name': e.name,
      'sets': e.sets,
      'reps': e.reps,
      'kg': e.kg,
    };

Exercise _exerciseFromJson(Map<String, dynamic> json) => Exercise(
      name: json['name'] as String? ?? '',
      sets: json['sets'] as int? ?? 0,
      reps: json['reps'] as int? ?? 0,
      kg: (json['kg'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _routineToJson(Routine r) => {
      'id': r.id,
      'name': r.name,
      'icon': r.icon,
      'createdAt': r.createdAt.toIso8601String(),
      'exercises': r.exercises.map(_exerciseToJson).toList(),
    };

Routine _routineFromJson(Map<String, dynamic> json) => Routine(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => _exerciseFromJson(e as Map<String, dynamic>))
          .toList(),
    );
