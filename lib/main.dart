import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_manager/data/models/task_model.dart';
import 'package:task_manager/di/injection.dart';
import 'package:task_manager/domain/blocs/task/task_bloc.dart';
import 'package:task_manager/domain/blocs/theme/theme_bloc.dart';
import 'package:task_manager/presentation/screens/home_screen.dart';
import 'package:task_manager/presentation/theme/app_theme.dart';
import 'package:task_manager/data/repositories/task_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskModelAdapter());
  await Hive.openBox<TaskModel>('tasks');
  await Hive.openBox('settings');
  await Hive.openBox('sync_queue');
  await setupLocator();
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsBox = Hive.box('settings');
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => TaskBloc(locator<TaskRepository>())),
        BlocProvider(create: (context) {
          final themeBloc = ThemeBloc(settingsBox);
          themeBloc.add(InitThemeEvent());
          return themeBloc;
        }),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Task Manager',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            debugShowCheckedModeBanner: false,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}