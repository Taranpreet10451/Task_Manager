import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:task_manager/data/models/task_model.dart';
import 'package:task_manager/data/repositories/task_repository.dart';
import 'package:task_manager/data/services/api_service.dart';
import 'package:task_manager/data/services/hive_service.dart';

class MockDio extends Mock implements Dio {}

class MockApiService extends Mock implements ApiService {}

class MockHiveService extends Mock implements HiveService {}

void main() {
  late TaskRepository repository;
  late MockApiService mockApiService;
  late MockHiveService mockHiveService;

  setUp(() async {
    mockApiService = MockApiService();
    mockHiveService = MockHiveService();
    repository = TaskRepository(mockApiService, mockHiveService);
  });

  test('getTasks returns tasks from API', () async {
    final taskModel = TaskModel(
      id: '1',
      title: 'Test Task',
      description: 'Description',
      status: 'pending',
      priority: 'low',
      createdDate: DateTime.now(),
      category: 'work',
    );
    when(mockApiService.getTasks(any)).thenAnswer((_) async => [taskModel]);

    final tasks = await repository.getTasks(1, null);

    expect(tasks, isNotEmpty);
    expect(tasks.first.title, 'Test Task');
    verify(mockHiveService.saveTask(taskModel)).called(1);
  });

  test('addTask stores task locally and remotely', () async {
    final task = TaskEntity(
      id: '1',
      title: 'New Task',
      description: 'Description',
      status: 'pending',
      priority: 'low',
      createdDate: DateTime.now(),
      category: 'work',
    );
    final taskModel = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      createdDate: task.createdDate,
      category: task.category,
    );

    await repository.addTask(task);

    verify(mockHiveService.saveTask(taskModel)).called(1);
    verify(mockApiService.addTask(taskModel)).called(1);
  });
}