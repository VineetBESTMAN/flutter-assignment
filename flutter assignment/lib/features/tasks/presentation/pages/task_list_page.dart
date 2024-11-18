import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/tasks/domain/entities/task.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:task_manager/features/tasks/presentation/widgets/task_item.dart';
import 'package:task_manager/features/tasks/presentation/pages/add_edit_task_page.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  TaskPriority? _priorityFilter;
  bool? _statusFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TasksLoaded) {
            final filteredTasks = _filterTasks(state.tasks);
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                return TaskItem(
                  task: filteredTasks[index],
                  onTap: () => _editTask(filteredTasks[index]),
                );
              },
            );
          } else if (state is TaskError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Task> _filterTasks(List<Task> tasks) {
    return tasks.where((task) {
      if (_priorityFilter != null && task.priority != _priorityFilter) {
        return false;
      }
      if (_statusFilter != null && task.isCompleted != _statusFilter) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Tasks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<TaskPriority?>(
              value: _priorityFilter,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...TaskPriority.values.map((priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(priority.name),
                    )),
              ],
              onChanged: (value) => setState(() => _priorityFilter = value),
            ),
            DropdownButtonFormField<bool?>(
              value: _statusFilter,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: null, child: Text('All')),
                DropdownMenuItem(value: true, child: Text('Completed')),
                DropdownMenuItem(value: false, child: Text('Incomplete')),
              ],
              onChanged: (value) => setState(() => _statusFilter = value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _priorityFilter = null;
                _statusFilter = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _addTask() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditTaskPage(),
      ),
    );
  }

  void _editTask(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTaskPage(task: task),
      ),
    );
  }
}