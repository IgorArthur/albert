import 'package:equatable/equatable.dart';

class WorkoutEvaluation extends Equatable {
  final String summary;
  final List<String> improvementTips;
  final int qualityScore; // e.g. 0-100

  const WorkoutEvaluation({
    required this.summary,
    required this.improvementTips,
    required this.qualityScore,
  });

  @override
  List<Object?> get props => [summary, improvementTips, qualityScore];
}
