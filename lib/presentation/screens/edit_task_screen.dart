import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/domain/blocs/task/task_bloc.dart';
import 'package:task_manager/domain/blocs/task/task_event.dart';
import 'package:task_manager/domain/entities/task_entity.dart';
import 'package:task_manager/presentation/widgets/custom_button.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskEntity task;

  const EditTaskScreen({Key? key, required this.task}) : super(key: key);

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _priority;
  late String _status;
  late String _category;
  late DateTime? _dueDate;
  late int _completionPercentage;
  late List<String> _selectedTags;
  final List<String> _availableTags = [
    'urgent', 'important', 'can-wait', 'meeting', 'call', 'email', 'report'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _priority = widget.task.priority;
    _status = widget.task.status;
    _category = widget.task.category;
    _dueDate = widget.task.dueDate;
    _completionPercentage = widget.task.completionPercentage;
    _selectedTags = List<String>.from(widget.task.tags);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Priority',
                value: _priority,
                items: const ['low', 'medium', 'high', 'critical'],
                onChanged: (value) {
                  setState(() {
                    _priority = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Status',
                value: _status,
                items: const ['pending', 'in-progress', 'completed'],
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                    if (value == 'completed') {
                      _completionPercentage = 100;
                    } else if (value == 'pending' && _completionPercentage == 100) {
                      _completionPercentage = 0;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Category',
                value: _category,
                items: const ['work', 'personal', 'shopping', 'health', 'education'],
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDatePicker(context),
              const SizedBox(height: 16),
              _buildCompletionSlider(),
              const SizedBox(height: 16),
              _buildTagSelector(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _updateTask,
                  child: const Text('Update Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Due Date',
        border: OutlineInputBorder(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _dueDate == null ? 'No due date' : dateFormat.format(_dueDate!),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _dueDate = date;
                    });
                  }
                },
              ),
              if (_dueDate != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _dueDate = null;
                    });
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Completion: $_completionPercentage%', style: const TextStyle(fontSize: 16)),
        Slider(
          value: _completionPercentage.toDouble(),
          min: 0,
          max: 100,
          divisions: 10,
          label: '$_completionPercentage%',
          onChanged: (value) {
            setState(() {
              _completionPercentage = value.toInt();
              if (_completionPercentage == 100) {
                _status = 'completed';
              } else if (_completionPercentage > 0 && _status == 'pending') {
                _status = 'in-progress';
              } else if (_completionPercentage == 0) {
                _status = 'pending';
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildTagSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tags', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _availableTags.map((tag) {
            final selected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: selected,
              onSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _updateTask() {
    if (_formKey.currentState!.validate()) {
      final updatedTask = TaskEntity(
        id: widget.task.id,
        title: _titleController.text,
        description: _descriptionController.text,
        status: _status,
        priority: _priority,
        createdDate: widget.task.createdDate,
        category: _category,
        dueDate: _dueDate,
        completionPercentage: _completionPercentage,
        tags: _selectedTags,
      );
      context.read<TaskBloc>().add(UpdateTask(updatedTask));
      Navigator.pop(context);
    }
  }
}