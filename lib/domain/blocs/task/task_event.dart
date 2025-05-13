import 'package:task_manager/domain/entities/task_entity.dart';

abstract class TaskEvent {}

class LoadTasks extends TaskEvent {
  final int page;
  final String? searchQuery;

  LoadTasks({required this.page, this.searchQuery});
}

class AddTask extends TaskEvent {
  final TaskEntity task;

  AddTask(this.task);
}

class UpdateTask extends TaskEvent {
  final TaskEntity task;

  UpdateTask(this.task);
}

class DeleteTask extends TaskEvent {
  final String taskId;

  DeleteTask(this.taskId);
}

class SortTasks extends TaskEvent {
  final String sortBy;

  SortTasks({required this.sortBy});
}

class FilterTasks extends TaskEvent {
  final String filterStatus;

  FilterTasks({required this.filterStatus});
}

class FilterByCategory extends TaskEvent {
  final String category;

  FilterByCategory({required this.category});
}

class SyncTasks extends TaskEvent {}

class UpdateTaskCompletion extends TaskEvent {
  final TaskEntity task;
  final int completionPercentage;

  UpdateTaskCompletion({
    required this.task,
    required this.completionPercentage,
  });
}

class UpdateTaskTags extends TaskEvent {
  final TaskEntity task;
  final List<String> tags;

  UpdateTaskTags({
    required this.task,
    required this.tags,
  });
}

class UpdateTaskDueDate extends TaskEvent {
  final TaskEntity task;
  final DateTime? dueDate;

  UpdateTaskDueDate({
    required this.task,
    required this.dueDate,
  });
}