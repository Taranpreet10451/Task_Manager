import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class TaskModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final String status;
  @HiveField(4)
  final String priority;
  @HiveField(5)
  final DateTime createdDate;
  @HiveField(6)
  final String category;
  @HiveField(7)
  final DateTime? dueDate;
  @HiveField(8)
  final int completionPercentage;
  @HiveField(9)
  final List<String> tags;

  TaskModel({
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

  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);
  
  TaskModel copyWith({
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
    return TaskModel(
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