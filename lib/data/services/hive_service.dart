import 'package:hive/hive.dart';
import 'package:task_manager/data/models/task_model.dart';
import 'package:task_manager/utils/logger.dart';

class HiveService {
  final Box<TaskModel> _taskBox;
  final Box _syncQueue;

  HiveService(this._taskBox, this._syncQueue);

  Future<void> saveTask(TaskModel task) async {
    try {
      await _taskBox.put(task.id, task);
      logger.i('Task saved to local storage: ${task.title}');
    } catch (e) {
      logger.e('Error saving task to local storage: $e');
      rethrow;
    }
  }

  Future<List<TaskModel>> getTasks() async {
    try {
      return _taskBox.values.toList();
    } catch (e) {
      logger.e('Error getting tasks from local storage: $e');
      return [];
    }
  }

  Future<TaskModel?> getTaskById(String taskId) async {
    try {
      return _taskBox.get(taskId);
    } catch (e) {
      logger.e('Error getting task by ID from local storage: $e');
      return null;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _taskBox.delete(taskId);
      logger.i('Task deleted from local storage: $taskId');
    } catch (e) {
      logger.e('Error deleting task from local storage: $e');
      rethrow;
    }
  }

  Future<void> queueOperation(String operation, dynamic data) async {
    try {
      await _syncQueue.add({'operation': operation, 'data': data, 'timestamp': DateTime.now().toIso8601String()});
      logger.i('Operation queued: $operation');
    } catch (e) {
      logger.e('Error queueing operation: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getQueuedOperations() async {
    try {
      return _syncQueue.values.cast<Map<String, dynamic>>().toList();
    } catch (e) {
      logger.e('Error getting queued operations: $e');
      return [];
    }
  }
  
  Future<void> removeQueuedOperation(Map<String, dynamic> operation) async {
    try {
      final index = _syncQueue.values.toList().indexOf(operation);
      if (index != -1) {
        await _syncQueue.deleteAt(index);
        logger.i('Queued operation removed');
      }
    } catch (e) {
      logger.e('Error removing queued operation: $e');
      rethrow;
    }
  }
  
  Future<void> clearAllTasks() async {
    try {
      await _taskBox.clear();
      logger.i('All tasks cleared from local storage');
    } catch (e) {
      logger.e('Error clearing tasks from local storage: $e');
      rethrow;
    }
  }
  
  Future<int> getTaskCount() async {
    return _taskBox.length;
  }
}