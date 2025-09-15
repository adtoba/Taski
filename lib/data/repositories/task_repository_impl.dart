import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:taski/core/services/firestore_service.dart';
import 'package:taski/domain/dto/create_task_dto.dart';
import 'package:taski/domain/models/failure.dart';
import 'package:taski/domain/models/task_model.dart';
import 'package:taski/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  @override
  Future<Either<Failure, void>> createTask({required CreateTaskDto task}) async {
    try {
      await FirestoreService.tasks().add(task.toJson());

      log("Task created");
      return right(null);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask({required String taskId}) async {
    try {
      await FirestoreService.tasks().doc(taskId.toString()).delete();
      log("Task deleted");
      return right(null);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TaskModel>>> getTasks() async {
    try {
      final tasks = await FirestoreService.tasks().get();
      var tasksList = tasks.docs.map((doc) => TaskModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
      log("Tasks fetched");
      return right(tasksList);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsCompleted(String taskId) async {
    log("Marking task as completed: $taskId");
    try {
      await FirestoreService.tasks().where("id", isEqualTo: taskId).get().then((value) {
        for (var doc in value.docs) {
          doc.reference.update({
            'status': 'completed',
          });
        }
      });
      log("Task marked as completed");
      return right(null);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTask({required String taskId, required CreateTaskDto task}) async {
    try {
      await FirestoreService.tasks().doc(taskId).update(task.toJson());
      log("Task updated");
      return right(null);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskModel>> getTask(String taskId) async {
    try {
      final task = await FirestoreService.tasks().doc(taskId).get();
      log("Task fetched");
      return right(TaskModel.fromJson(task.data() as Map<String, dynamic>));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

}