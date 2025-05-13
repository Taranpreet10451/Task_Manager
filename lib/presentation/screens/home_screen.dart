import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/domain/blocs/task/task_bloc.dart';
import 'package:task_manager/domain/blocs/task/task_event.dart';
import 'package:task_manager/domain/blocs/task/task_state.dart';
import 'package:task_manager/presentation/screens/add_task_screen.dart';
import 'package:task_manager/presentation/screens/edit_task_screen.dart';
import 'package:task_manager/presentation/screens/settings_screen.dart';
import 'package:task_manager/presentation/widgets/task_card.dart';
import 'package:task_manager/presentation/widgets/loading_indicator.dart';
import 'package:task_manager/utils/logger.dart';
import 'package:task_manager/utils/connectivity_checker.dart';
import 'package:task_manager/di/injection.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  String? _searchQuery;
  String _sortBy = 'createdDate';
  String _filterStatus = 'all';
  String _filterCategory = 'all';
  Timer? _debounce;
  List<String> _categories = ['all', 'work', 'personal', 'shopping', 'health', 'education'];

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasks(page: 1));
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      final state = context.read<TaskBloc>().state;
      if (state is TaskLoaded && state.hasMore) {
        context.read<TaskBloc>().add(LoadTasks(page: state.tasks.length ~/ 10 + 1, searchQuery: _searchQuery));
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() => _searchQuery = query.isEmpty ? null : query);
      context.read<TaskBloc>().add(LoadTasks(page: 1, searchQuery: _searchQuery));
    });
  }

  void _onProgressChanged(int newPercentage, task) {
    context.read<TaskBloc>().add(UpdateTaskCompletion(
          task: task,
          completionPercentage: newPercentage,
        ));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Task Manager'),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => context.read<TaskBloc>().add(SyncTasks()),
            tooltip: 'Sync Tasks',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Tasks',
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'All',
                    selected: _filterStatus == 'all',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _filterStatus = 'all');
                        context.read<TaskBloc>().add(FilterTasks(filterStatus: 'all'));
                      }
                    },
                  ),
                  _buildFilterChip(
                    label: 'Pending',
                    selected: _filterStatus == 'pending',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _filterStatus = 'pending');
                        context.read<TaskBloc>().add(FilterTasks(filterStatus: 'pending'));
                      }
                    },
                  ),
                  _buildFilterChip(
                    label: 'In Progress',
                    selected: _filterStatus == 'in-progress',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _filterStatus = 'in-progress');
                        context.read<TaskBloc>().add(FilterTasks(filterStatus: 'in-progress'));
                      }
                    },
                  ),
                  _buildFilterChip(
                    label: 'Completed',
                    selected: _filterStatus == 'completed',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _filterStatus = 'completed');
                        context.read<TaskBloc>().add(FilterTasks(filterStatus: 'completed'));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sort by:',
                  style: theme.textTheme.bodyLarge,
                ),
                _buildSortDropdown(),
                const SizedBox(width: 16),
                Text(
                  'Category:',
                  style: theme.textTheme.bodyLarge,
                ),
                _buildCategoryDropdown(),
              ],
            ),
          ),
          Expanded(
            child: BlocConsumer<TaskBloc, TaskState>(
              listener: (context, state) {
                if (state is TaskOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.all(10),
                  ));
                } else if (state is TaskError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.all(10),
                  ));
                }
              },
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const LoadingIndicator();
                }
                if (state is TaskSyncing) {
                  return const Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Syncing tasks...'),
                    ],
                  ));
                }
                if (state is TaskLoaded) {
                  if (state.tasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt, size: 80, color: theme.colorScheme.primary.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks found',
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add a new task to get started',
                            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context.read<TaskBloc>().add(LoadTasks(page: 1));
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: state.tasks.length + (state.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == state.tasks.length) return const LoadingIndicator();
                          final task = state.tasks[index];
                          return TaskCard(
                            task: task,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => EditTaskScreen(task: task)),
                            ),
                            onDelete: () => _confirmDelete(task.id),
                            onProgressChanged: (percentage) => _onProgressChanged(percentage, task),
                          );
                        },
                      ),
                    ),
                  );
                }
                return const Center(child: Text('No tasks found'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTaskScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
        tooltip: 'Add Task',
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButton<String>(
      value: _sortBy,
      items: const [
        DropdownMenuItem(value: 'createdDate', child: Text('Date')),
        DropdownMenuItem(value: 'priority', child: Text('Priority')),
        DropdownMenuItem(value: 'dueDate', child: Text('Due Date')),
        DropdownMenuItem(value: 'completion', child: Text('Completion')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _sortBy = value);
          context.read<TaskBloc>().add(SortTasks(sortBy: value));
        }
      },
      underline: Container(),
      borderRadius: BorderRadius.circular(8),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButton<String>(
      value: _filterCategory,
      items: _categories
          .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category == 'all' ? 'All' : category),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _filterCategory = value);
          context.read<TaskBloc>().add(FilterByCategory(category: value));
        }
      },
      underline: Container(),
      borderRadius: BorderRadius.circular(8),
    );
  }

  Future<void> _confirmDelete(String taskId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      context.read<TaskBloc>().add(DeleteTask(taskId));
    }
  }
}