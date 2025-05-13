import 'package:dio/dio.dart';
import 'package:task_manager/data/models/task_model.dart';
import 'package:task_manager/utils/logger.dart';
import 'package:uuid/uuid.dart';

class ApiService {
  final Dio _dio;
  final String _baseUrl = 'https://jsonplaceholder.typicode.com';

  ApiService(this._dio) {
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
    _dio.options.headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  Future<List<TaskModel>> getTasks(int page) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/todos',
        queryParameters: {'_page': page, '_limit': 10},
      );
      logger.i('Fetched tasks: ${response.data}');
      return (response.data as List).map((json) => TaskModel.fromJson({
        'id': json['id'].toString(),
        'title': json['title'],
        'description': 'Task description for ${json['title']}',
        'status': json['completed'] ? 'completed' : 'pending',
        'priority': _getRandomPriority(),
        'createdDate': DateTime.now().subtract(Duration(days: _getRandomInt(30))).toIso8601String(),
        'category': _getRandomCategory(),
        'dueDate': DateTime.now().add(Duration(days: _getRandomInt(14))).toIso8601String(),
        'completionPercentage': json['completed'] ? 100 : _getRandomInt(100),
        'tags': _getRandomTags(),
      })).toList();
    } catch (e) {
      logger.e('Error fetching tasks: $e');
      rethrow;
    }
  }

  Future<void> addTask(TaskModel task) async {
    try {
      await _dio.post('$_baseUrl/todos', data: task.toJson());
      logger.i('Task added: ${task.title}');
    } catch (e) {
      logger.e('Error adding task: $e');
      rethrow;
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await _dio.put('$_baseUrl/todos/${task.id}', data: task.toJson());
      logger.i('Task updated: ${task.title}');
    } catch (e) {
      logger.e('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _dio.delete('$_baseUrl/todos/$taskId');
      logger.i('Task deleted: $taskId');
    } catch (e) {
      logger.e('Error deleting task: $e');
      rethrow;
    }
  }
  
  // Helper methods for generating random data
  String _getRandomPriority() {
    final priorities = ['low', 'medium', 'high', 'critical'];
    return priorities[_getRandomInt(priorities.length)];
  }
  
  String _getRandomCategory() {
    final categories = ['work', 'personal', 'shopping', 'health', 'education'];
    return categories[_getRandomInt(categories.length)];
  }
  
  List<String> _getRandomTags() {
    final allTags = ['urgent', 'important', 'can-wait', 'meeting', 'call', 'email', 'report'];
    final tagCount = _getRandomInt(3) + 1; // 1 to 3 tags
    final selectedTags = <String>[];
    
    for (var i = 0; i < tagCount; i++) {
      final tag = allTags[_getRandomInt(allTags.length)];
      if (!selectedTags.contains(tag)) {
        selectedTags.add(tag);
      }
    }
    
    return selectedTags;
  }
  
  int _getRandomInt(int max) {
    final uuid = Uuid();
    return uuid.v4().hashCode.abs() % max;
  }
}