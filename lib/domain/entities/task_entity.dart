import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final DateTime createdDate;
  final String category;
  final DateTime? dueDate;
  final int completionPercentage;
  final List<String> tags;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdDate,
    required this.category,
    this.dueDate,
    this.completionPercentage = 0,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [
        id, 
        title, 
        description, 
        status, 
        priority, 
        createdDate, 
        category, 
        dueDate, 
        completionPercentage, 
        tags
      ];
      
  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? priority,
    DateTime? createdDate,
    String? category,
    DateTime? dueDate,
    int? completionPercentage,
    List<String>? tags,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdDate: createdDate ?? this.createdDate,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      tags: tags ?? this.tags,
    );
  }
}