import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/coach_message.dart';
import '../repositories/coach_repository.dart';

class AskCoachQuestion implements UseCase<CoachMessage, AskCoachQuestionParams> {
  final CoachRepository repository;
  AskCoachQuestion(this.repository);

  @override
  Future<Either<Failure, CoachMessage>> call(AskCoachQuestionParams params) =>
      repository.askQuestion(question: params.question, history: params.history);
}

class AskCoachQuestionParams {
  final String question;
  final List<CoachMessage> history;
  const AskCoachQuestionParams({required this.question, required this.history});
}
