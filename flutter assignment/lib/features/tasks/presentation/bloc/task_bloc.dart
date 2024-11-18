import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_manager/features/tasks/domain/entities/task.dart';
import 'package:task_manager/features/tasks/domain/repositories/task_repository.dart';

// Events
abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  final String userId;
  const LoadTasks(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateTask extends TaskEvent {
  final Task task;
  const CreateTask(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTask extends TaskEvent {
  final Task task;
  const UpdateTask(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String taskId;
  const DeleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

// State
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<Task> tasks;
  const TasksLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;

  TaskBloc(this.taskRepository) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<CreateTask>(_onCreateTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await taskRepository.getTasks(event.userId);
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onCreateTask(CreateTask event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.createTask(event.task);
      final tasks = await taskRepository.getTasks(event.task.userId);
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.updateTask(event.task);
      final tasks = await taskRepository.getTasks(event.task.userId);
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.deleteTask(event.taskId);
      if (state is TasksLoaded) {
        final currentTasks = (state as TasksLoaded).tasks;
        emit(TasksLoaded(currentTasks.where((task) => task.id != event.taskId).toList()));
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
}