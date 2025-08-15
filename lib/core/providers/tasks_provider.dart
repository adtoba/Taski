import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;


class TasksProvider extends ChangeNotifier {

  List<Map<String, dynamic>> tasks = [];
  bool isLoadingTasks = false;

  Future<void> getTasks() async {
    isLoadingTasks = true;
    notifyListeners();

    try {
      final supabase = Supabase.instance.client;

      final tasks = await supabase.from("tasks")
        .select()
        .eq("user_id", supabase.auth.currentUser?.id ?? "");
        
      log(tasks.toString());
      this.tasks = tasks;
    } catch (e) {
      log(e.toString());
    } finally {
      isLoadingTasks = false;
      notifyListeners();
    }
  }

  bool isUpdatingTaskLoading = false;
  Future<void> updateTask(int taskId, Map<String, dynamic> data) async {
    isUpdatingTaskLoading = true;
    notifyListeners();

    try {
      final supabase = Supabase.instance.client;
      await supabase.from("tasks").update(data).eq("id", taskId);

      // refresh the tasks
      getTasks();
    } catch (e) {
      log(e.toString());
    } finally {
      isUpdatingTaskLoading = false;
      notifyListeners();
    }
  }

  bool isDeletingTaskLoading = false;
  Future<void> deleteTask(int taskId) async {
    isDeletingTaskLoading = true;
    notifyListeners();
    
    try {
      final supabase = Supabase.instance.client;
      await supabase.from("tasks").delete().eq("id", taskId);

      // refresh the tasks
      getTasks();
    } catch (e) {
      log(e.toString());
    } finally {
      isDeletingTaskLoading = false;
      notifyListeners();
    }
  }

  bool isMarkAsCompletedLoading = false;
  Future<void> markAsCompleted(int taskId) async {
    isMarkAsCompletedLoading = true;
    notifyListeners();

    try {
      final supabase = Supabase.instance.client;
      await supabase.from("tasks").update({
        "status": "completed"
      }).eq("id", taskId);

      // refresh the tasks
      getTasks();

    } catch (e) {
      log(e.toString());
    } finally {
      isMarkAsCompletedLoading = false;
      notifyListeners();
    }
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


final tasksProvider = ChangeNotifierProvider<TasksProvider>((ref) {
  return TasksProvider();
});