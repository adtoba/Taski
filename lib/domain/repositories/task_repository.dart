import 'package:dartz/dartz.dart';
import 'package:taski/domain/dto/create_task_dto.dart';
import 'package:taski/domain/models/failure.dart';
import 'package:taski/domain/models/task_model.dart';

abstract class TaskRepository {
  Future<Either<Failure, void>> createTask({required CreateTaskDto task});
  Future<Either<Failure, void>> updateTask({required String taskId, required CreateTaskDto task});
  Future<Either<Failure, void>> deleteTask({required String taskId});
  Future<Either<Failure, List<TaskModel>>> getTasks();
  Future<Either<Failure, TaskModel>> getTask(String taskId);
  Future<Either<Failure, void>> markAsCompleted(String taskId);
}