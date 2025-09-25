import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taski/core/providers/task_provider.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/domain/dto/create_task_dto.dart';
import 'package:taski/main.dart';
import 'package:taski/presentation/features/tasks/widgets/task_widget.dart';
import 'package:taski/presentation/widgets/base_screen.dart';
import 'package:taski/presentation/widgets/dual_input_widget.dart';
import 'package:taski/presentation/features/tasks/screens/task_detail_screen.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final Set<int> _selectedTaskIndices = {};
  

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(taskProvider).getTasks();
    });
  } 

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _toggleTaskSelection(int index) {
    setState(() {
      if (_selectedTaskIndices.contains(index)) {
        _selectedTaskIndices.remove(index);
      } else {
        _selectedTaskIndices.add(index);
      }
    });
  }

  void _navigateToTaskDetail(int index, bool isCompleted) {
    var tasks = ref.watch(taskProvider).tasks;
    var completedTasks = tasks.where((task) => task.status == 'completed').toList();
    var pendingTasks = tasks.where((task) => task.status == 'pending').toList();

    final task = isCompleted ? completedTasks[index] : pendingTasks[index];
    
    // Navigate to task detail page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(
          task: task,
          description: task.description,
          scheduledTime: task.dueDate.toIso8601String(),
          isCompleted: task.status == 'completed',
        ),
      ),
    );
  }

  void _markSelectedAsCompleted() {
    var tasks = ref.watch(taskProvider).tasks;
    var pendingTasks = tasks.where((task) => task.status == 'pending').toList();
    var completedTasks = tasks.where((task) => task.status == 'completed').toList();
    
    setState(() {
      // Get selected tasks in reverse order to avoid index issues
      final selectedIndices = _selectedTaskIndices.toList()..sort((a, b) => b.compareTo(a));
      
      for (final index in selectedIndices) {
        ref.read(taskProvider).markAsCompleted(pendingTasks[index].id);
        // ref.read(tasksProvider.notifier).getTasks();
        // final task = pendingTasks[index];
        // task['isCompleted'] = true;
        // completedTasks.add(task);
        // pendingTasks.removeAt(index);
      }
      
      _selectedTaskIndices.clear();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    var tasks = ref.watch(taskProvider).tasks;
    var isLoadingTasks = ref.watch(taskProvider).isLoadingTasks;
    var pendingTasks = tasks.where((task) => task.status == 'pending').toList();
    var completedTasks = tasks.where((task) => task.status == 'completed').toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    
    return BaseScreen(
      child: Column(
        children: [
          // Enhanced Header with better styling
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  YMargin(20),
                  // Enhanced Tab Bar
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: config.sw(20)),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelStyle: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: config.sp(14),
                      ),
                      unselectedLabelStyle: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: config.sp(14),
                      ),
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pending_actions, size: 18),
                              XMargin(6),
                              Text("Pending"),
                              XMargin(4),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${pendingTasks.length}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 18),
                              XMargin(6),
                              Text("Completed"),
                              XMargin(4),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${completedTasks.length}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  YMargin(16),
                ],
              ),
            ),
          ),
          
          // Content Area
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pending Tasks
                Stack(
                  children: [
                    pendingTasks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(config.sw(24)),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 20,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.task_alt_rounded,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                YMargin(24),
                                Text(
                                  "No pending tasks",
                                  style: textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                YMargin(8),
                                Text(
                                  "You're all caught up! 🎉",
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  ),
                                ),
                                YMargin(16),
                                InkWell(
                                  onTap: () {
                                    var task = CreateTaskDto(
                                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                                      title: 'Testing Tasks', 
                                      description: 'Testing Tasks Description', 
                                      priority: 'high', 
                                      status: 'completed', 
                                      dueDate: DateTime.now()
                                    );

                                    ref.read(taskProvider).createTask(task);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: config.sw(16),
                                      vertical: config.sh(8),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "Add a new task to get started",
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: Colors.blue.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.only(
                              top: config.sh(16),
                              left: config.sw(20),
                              right: config.sw(20),
                              bottom: config.sh(180),
                            ),
                            separatorBuilder: (context, index) => YMargin(12),
                            itemCount: pendingTasks.length,
                            itemBuilder: (context, index) {
                              final task = pendingTasks[index];
                              final isSelected = _selectedTaskIndices.contains(index);
                              return TaskWidget(
                                description: task.title,
                                scheduledTime: task.dueDate.toIso8601String(),
                                isCompleted: task.status == 'completed',
                                isSelected: isSelected,
                                onSelectionToggle: () => _toggleTaskSelection(index),
                                onTap: () => _navigateToTaskDetail(index, false),
                              );
                            },
                          ),                    
                  ],
                ),
                
                // Completed Tasks (Read-only)
                completedTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(config.sw(24)),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check_circle_outline,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            YMargin(24),
                            Text(
                              "No completed tasks",
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            YMargin(8),
                            Text(
                              "Complete some tasks to see them here",
                              style: textTheme.bodyLarge?.copyWith(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                            YMargin(16),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: config.sw(16),
                                vertical: config.sh(8),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "Switch to Pending tab to add tasks",
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.green.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Stack(
                      children: [
                        ListView.separated(
                          padding: EdgeInsets.only(
                            top: config.sh(16),
                            left: config.sw(20),
                            right: config.sw(20),
                            bottom: config.sh(120),
                          ),
                          separatorBuilder: (context, index) => YMargin(12),
                          itemCount: completedTasks.length,
                          itemBuilder: (context, index) {
                            final task = completedTasks[index];
                            return TaskWidget(
                              description: task.title,
                              scheduledTime: task.dueDate.toIso8601String(),
                              isCompleted: task.status == 'completed',
                              isSelected: false,
                              onSelectionToggle: null, // No selection for completed tasks
                              onTap: () => _navigateToTaskDetail(index, true),
                            );
                          },
                        ),
                      ],
                    ),
              ],
            ),
          )
        ],
      ),
    );
  }
}