import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:taski/data/repositories/task_repository_impl.dart';
import 'package:taski/domain/dto/create_task_dto.dart';
import 'package:taski/domain/models/task_model.dart';
import 'package:taski/domain/repositories/task_repository.dart';
import 'package:timeago/timeago.dart' as timeago;

class TaskProvider extends ChangeNotifier {
  final TaskRepository taskRepository;
  
  TaskProvider({required this.taskRepository});


  List<TaskModel> _tasks = [];
  List<TaskModel> get tasks => _tasks;

  bool _isLoadingTasks = false;
  bool get isLoadingTasks => _isLoadingTasks;

  bool _isCreatingTask = false;
  bool get isCreatingTask => _isCreatingTask;

  bool _isUpdatingTask = false;
  bool get isUpdatingTask => _isUpdatingTask;

  bool _isDeletingTask = false;
  bool get isDeletingTask => _isDeletingTask;

  bool _isMarkingAsCompleted = false;
  bool get isMarkingAsCompleted => _isMarkingAsCompleted;

  bool _isLoadingTask = false;
  bool get isLoadingTask => _isLoadingTask;
  

  Future<void> createTask(CreateTaskDto task) async {
    _isCreatingTask = true;
    notifyListeners();

    final result = await taskRepository.createTask(task: task);
    result.fold((failure) {
      _isCreatingTask = false;
      notifyListeners();
      
    }, (success) {
      notifyListeners();
    });
  }

  Future<void> getTasks() async {
    log("Getting tasks");
    _isLoadingTasks = true;
    notifyListeners();

    final result = await taskRepository.getTasks();
    result.fold((failure) {
      _isLoadingTasks = false;
      notifyListeners();

      log(failure.message.toString());
      
    }, (success) {
      _tasks = success;
      log(success.toString());
      _isLoadingTasks = false;
      notifyListeners();
    });
  }

  Future<void> updateTask(String taskId, CreateTaskDto task) async {
    _isUpdatingTask = true;
    notifyListeners();

    final result = await taskRepository.updateTask(taskId: taskId, task: task);
    result.fold((failure) {
      _isUpdatingTask = false;
      notifyListeners();
    }, (success) {
      _isUpdatingTask = false;
      notifyListeners();
    });
  }

  Future<void> deleteTask(String taskId) async {
    _isDeletingTask = true;
    notifyListeners();

    final result = await taskRepository.deleteTask(taskId: taskId);
    result.fold((failure) {
      _isDeletingTask = false;
      notifyListeners();
    }, (success) {
      _isDeletingTask = false;
      notifyListeners();
    });
  }

  Future<void> markAsCompleted(String taskId) async {
    log("Marking task as completed");
    _isMarkingAsCompleted = true;
    notifyListeners();

    final result = await taskRepository.markAsCompleted(taskId);
    result.fold((failure) {
      _isMarkingAsCompleted = false;
      notifyListeners();
      log(failure.message.toString());
    }, (success) {
      _isMarkingAsCompleted = false;
      notifyListeners();
    });
  }

  Future<void> getTask(String taskId) async {
    _isLoadingTask = true;
    notifyListeners();

    final result = await taskRepository.getTask(taskId);
    result.fold((failure) {
      _isLoadingTask = false;
      notifyListeners();
    }, (success) {
      _isLoadingTask = false;
      notifyListeners();
    });
  }

  String formatDateTime(String dateString, String scheduledTime) {
    try {
      
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final taskDate = DateTime(date.year, date.month, date.day);
      
      String datePrefix;
      if (taskDate.isAtSameMomentAs(today)) {
        datePrefix = 'Today';
      } else if (taskDate.isAtSameMomentAs(tomorrow)) {
        datePrefix = 'Tomorrow';
      } else if (taskDate.isBefore(today)) {
        final difference = today.difference(taskDate).inDays;
        if (difference == 1) {
          datePrefix = 'Yesterday';
        } else if (difference <= 7) {
          datePrefix = DateFormat('EEEE').format(date); // Day name
        } else {
          datePrefix = DateFormat('MMM dd').format(date); // Month day
        }
      } else {
        final difference = taskDate.difference(today).inDays;
        if (difference <= 7) {
          datePrefix = DateFormat('EEEE').format(date); // Day name
        } else {
          datePrefix = DateFormat('MMM dd').format(date); // Month day
        }
      }
      
      // Format time
      final timeString = DateFormat('h:mm a').format(date); // 10:00 AM format

      if(taskDate.isBefore(today)) {
        return timeago.format(date);
      }
      
      return '$datePrefix, $timeString';
    } catch (e) {
      return scheduledTime; // Fallback to original string if parsing fails
    }
  }
}


final taskProvider = ChangeNotifierProvider<TaskProvider>((ref) {
  return TaskProvider(taskRepository: TaskRepositoryImpl());
});