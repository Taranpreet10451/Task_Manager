import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:task_manager/data/models/task_model.dart';
import 'package:task_manager/data/repositories/task_repository.dart';
import 'package:task_manager/data/services/api_service.dart';
import 'package:task_manager/data/services/hive_service.dart';
import 'package:task_manager/utils/connectivity_checker.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // Services
  locator.registerSingleton<Dio>(Dio());
  locator.registerSingleton<HiveService>(HiveService(
    Hive.box<TaskModel>('tasks'),
    Hive.box('sync_queue'),
  ));
  locator.registerSingleton<ApiService>(ApiService(locator<Dio>()));
  locator.registerSingleton<ConnectivityChecker>(ConnectivityChecker());

  // Repositories
  locator.registerSingleton<TaskRepository>(TaskRepository(
    locator<ApiService>(),
    locator<HiveService>(),
    locator<ConnectivityChecker>(),
  ));
}