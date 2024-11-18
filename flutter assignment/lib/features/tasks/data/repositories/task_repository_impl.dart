import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:task_manager/features/tasks/domain/entities/task.dart';
import 'package:task_manager/features/tasks/domain/repositories/task_repository.dart';

@Injectable(as: TaskRepository)
class TaskRepositoryImpl implements TaskRepository {
  final FirebaseFirestore _firestore;

  TaskRepositoryImpl() : _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Task>> getTasks(String userId) async {
    final snapshot = await _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) => _convertToTask(doc)).toList();
  }

  @override
  Future<Task> createTask(Task task) async {
    final docRef = await _firestore.collection('tasks').add({
      'userId': task.userId,
      'title': task.title,
      'description': task.description,
      'dueDate': task.dueDate.toIso8601String(),
      'priority': task.priority.name,
      'isCompleted': task.isCompleted,
      'createdAt': task.createdAt.toIso8601String(),
    });

    return task.copyWith(id: docRef.id);
  }

  @override
  Future<Task> updateTask(Task task) async {
    await _firestore.collection('tasks').doc(task.id).update({
      'title': task.title,
      'description': task.description,
      'dueDate': task.dueDate.toIso8601String(),
      'priority': task.priority.name,
      'isCompleted': task.isCompleted,
    });

    return task;
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  @override
  Stream<List<Task>> watchTasks(String userId) {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_convertToTask).toList());
  }

  Task _convertToTask(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      userId: data['userId'],
      title: data['title'],
      description: data['description'],
      dueDate: DateTime.parse(data['dueDate']),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => TaskPriority.medium,
      ),
      isCompleted: data['isCompleted'],
      createdAt: DateTime.parse(data['createdAt']),
    );
  }
}