import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:taski/core/providers/tasks_provider.dart';
import 'package:taski/core/services/supabase_service.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';

class EditTaskScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> task;

  const EditTaskScreen({
    super.key,
    required this.task,
  });

  @override
  ConsumerState<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedPriority;
  late String _selectedStatus;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  
  bool _isLoading = false;
  bool _hasChanges = false;

  final List<String> _priorityOptions = ['Low', 'Medium', 'High'];
  final List<String> _statusOptions = ['Pending', 'Completed'];
  
  // Helper method to safely get priority value
  String _getSafePriorityValue(String? storedValue) {
    if (storedValue == null) return 'Medium';
    return _priorityOptions.firstWhere(
      (option) => option.toLowerCase() == storedValue.toLowerCase(),
      orElse: () => 'Medium',
    );
  }
  
  // Helper method to safely get status value
  String _getSafeStatusValue(String? storedValue) {
    if (storedValue == null) return 'Pending';
    return _statusOptions.firstWhere(
      (option) => option.toLowerCase() == storedValue.toLowerCase(),
      orElse: () => 'Pending',
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.task['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.task['description'] ?? '');
    
    // Handle priority with proper case matching
    _selectedPriority = _getSafePriorityValue(widget.task['priority']);
    
    // Handle status with proper case matching
    _selectedStatus = _getSafeStatusValue(widget.task['status']);
    
    // Parse the due date
    try {
      final dueDate = DateTime.parse(widget.task['due_date'] ?? DateTime.now().toIso8601String());
      _selectedDate = dueDate;
      _selectedTime = TimeOfDay.fromDateTime(dueDate);
    } catch (e) {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }

    // Listen for changes
    _titleController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.blue.shade600,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _hasChanges = true;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.blue.shade600,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task title is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Combine date and time
      final combinedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final updatedTask = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'priority': _selectedPriority.toLowerCase(),
        'status': _selectedStatus.toLowerCase(),
        'due_date': combinedDateTime.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await ref.read(tasksProvider.notifier).updateTask(widget.task['id'], updatedTask);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate successful update
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red.shade500;
      case 'medium':
        return Colors.orange.shade500;
      case 'low':
        return Colors.green.shade500;
      default:
        return Colors.grey.shade500;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green.shade500;
      case 'pending':
        return Colors.blue.shade500;
      default:
        return Colors.grey.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        title: Text(
          'Edit Task',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isLoading ? null : _saveTask,
              child: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? Colors.white : Colors.blue.shade600,
                        ),
                      ),
                    )
                  : Text(
                      'Save',
                      style: textTheme.titleMedium?.copyWith(
                        color: isDark ? Colors.white : Colors.blue.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(config.sw(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Title Field
            Text(
              'Task Title',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            YMargin(8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _titleController,
                style: textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter task title',
                  hintStyle: textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(config.sw(16)),
                ),
              ),
            ),
            
            YMargin(24),
            
            // Task Description Field
            Text(
              'Description',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            YMargin(8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: 4,
                style: textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter task description',
                  hintStyle: textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(config.sw(16)),
                ),
              ),
            ),
            
            YMargin(24),
            
            // Priority and Status Row
            Row(
              children: [
                // Priority Dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Priority',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      YMargin(8),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedPriority,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: config.sw(16),
                              vertical: config.sh(12),
                            ),
                          ),
                          dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                          style: textTheme.bodyLarge?.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          items: _priorityOptions.map((String priority) {
                            return DropdownMenuItem<String>(
                              value: priority,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getPriorityColor(priority),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  XMargin(8),
                                  Text(priority),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedPriority = newValue;
                                _hasChanges = true;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                XMargin(16),
                
                // Status Dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      YMargin(8),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: config.sw(16),
                              vertical: config.sh(12),
                            ),
                          ),
                          dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                          style: textTheme.bodyLarge?.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          items: _statusOptions.map((String status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  XMargin(8),
                                  Text(status),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedStatus = newValue;
                                _hasChanges = true;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            YMargin(24),
            
            // Due Date Section
            Text(
              'Due Date & Time',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            YMargin(16),
            
            // Date and Time Selection
            Row(
              children: [
                // Date Picker
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: EdgeInsets.all(config.sw(16)),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.blue.shade600,
                            size: 20,
                          ),
                          XMargin(12),
                          Expanded(
                            child: Text(
                              DateFormat('MMM dd, yyyy').format(_selectedDate),
                              style: textTheme.bodyLarge?.copyWith(
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                XMargin(16),
                
                // Time Picker
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(context),
                    child: Container(
                      padding: EdgeInsets.all(config.sw(16)),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.blue.shade600,
                            size: 20,
                          ),
                          XMargin(12),
                          Expanded(
                            child: Text(
                              _selectedTime.format(context),
                              style: textTheme.bodyLarge?.copyWith(
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            YMargin(32),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _hasChanges && !_isLoading ? _saveTask : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasChanges ? Colors.blue.shade600 : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: config.sh(16)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Save Changes',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: config.sp(16),
                        ),
                      ),
              ),
            ),
            
            YMargin(16),
            
            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : Colors.black87,
                  side: BorderSide(
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                  padding: EdgeInsets.symmetric(vertical: config.sh(16)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: config.sp(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 