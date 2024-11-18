import 'package:task_manager/features/tasks/domain/entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks(String userId);
  Future<Task> createTask(Task task);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(String taskId);
  Stream<List<Task>> watchTasks(String userId);
}