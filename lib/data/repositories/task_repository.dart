import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:task_manager/data/models/task_model.dart';
import 'package:task_manager/domain/entities/task_entity.dart';
import 'package:task_manager/data/services/api_service.dart';
import 'package:task_manager/data/services/hive_service.dart';
import 'package:task_manager/utils/logger.dart';
import 'package:task_manager/utils/connectivity_checker.dart';

class TaskRepository {
  final ApiService apiService;
  final HiveService hiveService;
  final ConnectivityChecker connectivityChecker;

  TaskRepository(this.apiService, this.hiveService, this.connectivityChecker);

  Future<List<TaskEntity>> getTasks(int page, String? searchQuery) async {
    try {
      // Check if we're online
      final isOnline = await connectivityChecker.isConnected();
      
      if (isOnline) {
        logger.i('Online: Fetching tasks from API');
        final tasks = await apiService.getTasks(page);
        // Cache tasks locally
        for (var task in tasks) {
          await hiveService.saveTask(task);
        }
        return _filterAndMapTasks(tasks, searchQuery);
      } else {
        logger.i('Offline: Fetching tasks from local storage');
        return _filterAndMapTasks(await hiveService.getTasks(), searchQuery);
      }
    } catch (e) {
      logger.e('Error fetching tasks: $e');
      // Fallback to local cache
      return _filterAndMapTasks(await hiveService.getTasks(), searchQuery);
    }
  }

  List<TaskEntity> _filterAndMapTasks(List<TaskModel> tasks, String? searchQuery) {
    return tasks
        .where((task) => 
            searchQuery == null || 
            task.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            task.description.toLowerCase().contains(searchQuery.toLowerCase()))
        .map((task) => task.toEntity())
        .toList();
  }

  Future<void> addTask(TaskEntity task) async {
    final taskModel = _mapEntityToModel(task);
    
    // Always save locally first for offline-first experience
    await hiveService.saveTask(taskModel);
    
    try {
      final isOnline = await connectivityChecker.isConnected();
      if (isOnline) {
        await apiService.addTask(taskModel);
        logger.i('Task added to API: ${task.title}');
      } else {
        // Queue for sync when online
        await hiveService.queueOperation('add', taskModel);
        logger.i('Task queued for sync: ${task.title}');
      }
    } catch (e) {
      logger.e('Error adding task to API: $e');
      // Queue for sync when online
      await hiveService.queueOperation('add', taskModel);
    }
  }

  Future<void> updateTask(TaskEntity task) async {
    final taskModel = _mapEntityToModel(task);
    
    // Always update locally first
    await hiveService.saveTask(taskModel);
    
    try {
      final isOnline = await connectivityChecker.isConnected();
      if (isOnline) {
        await apiService.updateTask(taskModel);
        logger.i('Task updated in API: ${task.title}');
      } else {
        // Queue for sync
        await hiveService.queueOperation('update', taskModel);
        logger.i('Task update queued for sync: ${task.title}');
      }
    } catch (e) {
      logger.e('Error updating task in API: $e');
      // Queue for sync
      await hiveService.queueOperation('update', taskModel);
    }
  }

  Future<void> deleteTask(String taskId) async {
    // Delete locally first
    await hiveService.deleteTask(taskId);
    
    try {
      final isOnline = await connectivityChecker.isConnected();
      if (isOnline) {
        await apiService.deleteTask(taskId);
        logger.i('Task deleted from API: $taskId');
      } else {
        // Queue for sync
        await hiveService.queueOperation('delete', taskId);
        logger.i('Task deletion queued for sync: $taskId');
      }
    } catch (e) {
      logger.e('Error deleting task from API: $e');
      // Queue for sync
      await hiveService.queueOperation('delete', taskId);
    }
  }
  
  Future<void> syncQueuedOperations() async {
    if (!await connectivityChecker.isConnected()) {
      logger.i('Cannot sync: Device is offline');
      return;
    }
    
    final operations = await hiveService.getQueuedOperations();
    logger.i('Syncing ${operations.length} queued operations');
    
    for (var operation in operations) {
      try {
        final type = operation['operation'] as String;
        final data = operation['data'];
        
        switch (type) {
          case 'add':
            await apiService.addTask(data as TaskModel);
            break;
          case 'update':
            await apiService.updateTask(data as TaskModel);
            break;
          case 'delete':
            await apiService.deleteTask(data as String);
            break;
        }
        
        await hiveService.removeQueuedOperation(operation);
        logger.i('Successfully synced operation: $type');
      } catch (e) {
        logger.e('Failed to sync operation: $e');
        // Leave in queue for next sync attempt
      }
    }
  }
  
  TaskModel _mapEntityToModel(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      status: entity.status,
      priority: entity.priority,
      createdDate: entity.createdDate,
      category: entity.category,
      dueDate: entity.dueDate,
      completionPercentage: entity.completionPercentage,
      tags: entity.tags,
    );
  }
}

extension TaskModelExtension on TaskModel {
  TaskEntity toEntity() => TaskEntity(
        id: id,
        title: title,
        description: description,
        status: status,
        priority: priority,
        createdDate: createdDate,
        category: category,
        dueDate: dueDate,
        completionPercentage: completionPercentage,
        tags: tags,
      );
}