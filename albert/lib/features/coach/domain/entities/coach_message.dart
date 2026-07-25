import 'package:equatable/equatable.dart';

enum MessageSender { user, coach }

class CoachMessage extends Equatable {
  final String text;
  final MessageSender sender;
  final DateTime timestamp;

  const CoachMessage({required this.text, required this.sender, required this.timestamp});

  @override
  List<Object?> get props => [text, sender, timestamp];
}
