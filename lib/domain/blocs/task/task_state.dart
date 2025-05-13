import 'package:task_manager/domain/entities/task_entity.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskSyncing extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskEntity> tasks;
  final bool hasMore;

  TaskLoaded({required this.tasks, required this.hasMore});
}

class TaskOperationSuccess extends TaskState {
  final String message;

  TaskOperationSuccess({required this.message});
}

class TaskError extends TaskState {
  final String message;

  TaskError({required this.message});
}

class TaskNetworkStatus extends TaskState {
  final bool isOnline;

  TaskNetworkStatus({required this.isOnline});
}