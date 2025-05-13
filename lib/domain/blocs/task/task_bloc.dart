import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/data/repositories/task_repository.dart';
import 'package:task_manager/domain/entities/task_entity.dart';
import 'package:task_manager/utils/logger.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;
  String _currentSortBy = 'createdDate';
  String _currentFilterStatus = 'all';
  String _currentCategory = 'all';
  Timer? _syncTimer;

  TaskBloc(this.repository) : super(TaskInitial()) {
    on<LoadTasks>((event, emit) async {
      emit(TaskLoading());
      try {
        final tasks = await repository.getTasks(event.page, event.searchQuery);
        var filteredTasks = tasks;
        
        // Apply status filter
        if (_currentFilterStatus != 'all') {
          filteredTasks = filteredTasks.where((task) => task.status == _currentFilterStatus).toList();
        }
        
        // Apply category filter
        if (_currentCategory != 'all') {
          filteredTasks = filteredTasks.where((task) => task.category == _currentCategory).toList();
        }
        
        // Apply sorting
        filteredTasks.sort((a, b) {
          switch (_currentSortBy) {
            case 'createdDate':
              return b.createdDate.compareTo(a.createdDate);
            case 'priority':
              return _getPriorityValue(a.priority).compareTo(_getPriorityValue(b.priority));
            case 'dueDate':
              if (a.dueDate == null && b.dueDate == null) return 0;
              if (a.dueDate == null) return 1;
              if (b.dueDate == null) return -1;
              return a.dueDate!.compareTo(b.dueDate!);
            case 'completion':
              return b.completionPercentage.compareTo(a.completionPercentage);
            default:
              return b.createdDate.compareTo(a.createdDate);
          }
        });
        
        emit(TaskLoaded(tasks: filteredTasks, hasMore: tasks.length == 10));
      } catch (e) {
        logger.e('Error loading tasks: $e');
        emit(TaskError(message: 'Failed to load tasks: $e'));
      }
    });

    on<AddTask>((event, emit) async {
      try {
        await repository.addTask(event.task);
        emit(TaskOperationSuccess(message: 'Task added successfully'));
        add(LoadTasks(page: 1));
      } catch (e) {
        logger.e('Error adding task: $e');
        emit(TaskError(message: 'Failed to add task: $e'));
      }
    });

    on<UpdateTask>((event, emit) async {
      try {
        await repository.updateTask(event.task);
        emit(TaskOperationSuccess(message: 'Task updated successfully'));
        add(LoadTasks(page: 1));
      } catch (e) {
        logger.e('Error updating task: $e');
        emit(TaskError(message: 'Failed to update task: $e'));
      }
    });

    on<DeleteTask>((event, emit) async {
      try {
        await repository.deleteTask(event.taskId);
        emit(TaskOperationSuccess(message: 'Task deleted successfully'));
        add(LoadTasks(page: 1));
      } catch (e) {
        logger.e('Error deleting task: $e');
        emit(TaskError(message: 'Failed to delete task: $e'));
      }
    });

    on<SortTasks>((event, emit) async {
      _currentSortBy = event.sortBy;
      add(LoadTasks(page: 1));
    });

    on<FilterTasks>((event, emit) async {
      _currentFilterStatus = event.filterStatus;
      add(LoadTasks(page: 1));
    });
    
    on<FilterByCategory>((event, emit) async {
      _currentCategory = event.category;
      add(LoadTasks(page: 1));
    });
    
    on<SyncTasks>((event, emit) async {
      try {
        emit(TaskSyncing());
        await repository.syncQueuedOperations();
        emit(TaskOperationSuccess(message: 'Tasks synced successfully'));
        add(LoadTasks(page: 1));
      } catch (e) {
        logger.e('Error syncing tasks: $e');
        emit(TaskError(message: 'Failed to sync tasks: $e'));
      }
    });
    
    on<UpdateTaskCompletion>((event, emit) async {
      try {
        final updatedTask = event.task.copyWith(
          completionPercentage: event.completionPercentage,
          status: event.completionPercentage == 100 ? 'completed' : 'in-progress',
        );
        await repository.updateTask(updatedTask);
        emit(TaskOperationSuccess(message: 'Task progress updated'));
        add(LoadTasks(page: 1));
      } catch (e) {
        logger.e('Error updating task completion: $e');
        emit(TaskError(message: 'Failed to update task progress: $e'));
      }
    });
    
    // Start periodic sync
    _startPeriodicSync();
  }
  
  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      add(SyncTasks());
    });
  }
  
  int _getPriorityValue(String priority) {
    switch (priority.toLowerCase()) {
      case 'low': return 0;
      case 'medium': return 1;
      case 'high': return 2;
      case 'critical': return 3;
      default: return 0;
    }
  }
  
  @override
  Future<void> close() {
    _syncTimer?.cancel();
    return super.close();
  }
}