import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:task_manager/domain/blocs/task/task_bloc.dart';
import 'package:task_manager/domain/blocs/task/task_state.dart';
import 'package:task_manager/domain/entities/task_entity.dart';
import 'package:task_manager/presentation/screens/home_screen.dart';

class MockTaskBloc extends Mock implements TaskBloc {}

void main() {
  late MockTaskBloc mockTaskBloc;

  setUp(() {
    mockTaskBloc = MockTaskBloc();
  });

  testWidgets('HomeScreen displays loading indicator when TaskLoading', (WidgetTester tester) async {
    when(mockTaskBloc.state).thenReturn(TaskLoading());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TaskBloc>(
          create: (_) => mockTaskBloc,
          child: const HomeScreen(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('HomeScreen displays tasks when TaskLoaded', (WidgetTester tester) async {
    final task = TaskEntity(
      id: '1',
      title: 'Test Task',
      description: 'Description',
      status: 'pending',
      priority: 'low',
      createdDate: DateTime.now(),
      category: 'work',
    );
    when(mockTaskBloc.state).thenReturn(TaskLoaded(tasks: [task], hasMore: false));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TaskBloc>(
          create: (_) => mockTaskBloc,
          child: const HomeScreen(),
        ),
      ),
    );

    expect(find.text('Test Task'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
  });
}