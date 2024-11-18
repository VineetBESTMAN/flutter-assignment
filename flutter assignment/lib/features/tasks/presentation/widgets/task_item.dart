import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:task_manager/features/tasks/domain/entities/task.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskItem({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color getPriorityColor() {
      switch (task.priority) {
        case TaskPriority.high:
          return Colors.red;
        case TaskPriority.medium:
          return Colors.orange;
        case TaskPriority.low:
          return Colors.green;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) {
                context.read<TaskBloc>().add(DeleteTask(task.id));
              },
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Card(
          elevation: 2,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: getPriorityColor().withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          task.priority.name.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: getPriorityColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      task.description,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Due: ${DateFormat('MMM d, y').format(task.dueDate)}',
                        style: theme.textTheme.bodySmall,
                      ),
                      Checkbox(
                        value: task.isCompleted,
                        onChanged: (value) {
                          context.read<TaskBloc>().add(
                                UpdateTask(
                                  task.copyWith(isCompleted: value),
                                ),
                              );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}