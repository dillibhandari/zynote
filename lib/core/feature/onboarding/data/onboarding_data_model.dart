import 'package:equatable/equatable.dart';

class OnboardingData extends Equatable {
  final String title;
  final String description;
  final String iconName;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.iconName,
  });

  @override
  List<Object?> get props => [title, description, iconName];
}
