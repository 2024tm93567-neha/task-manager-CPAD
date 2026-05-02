import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/task.dart';
import '../../providers/task_provider.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task; // null = create, non-null = edit

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late TaskPriority _priority;
  late TaskStatus _status;
  DateTime? _dueDate;
  bool _saving = false;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task?.title ?? '');
    _descCtrl = TextEditingController(text: widget.task?.description ?? '');
    _priority = widget.task?.priority ?? TaskPriority.medium;
    _status = widget.task?.status ?? TaskStatus.todo;
    _dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final provider = context.read<TaskProvider>();
    bool success;

    if (isEditing) {
      final updated = widget.task!.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        priority: _priority,
        status: _status,
        dueDate: _dueDate,
      );
      success = await provider.updateTask(updated);
    } else {
      final newTask = Task(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        priority: _priority,
        status: _status,
        dueDate: _dueDate,
      );
      success = await provider.addTask(newTask);
    }

    setState(() => _saving = false);

    if (!mounted) return;
    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Failed to update task' : 'Failed to create task'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(80, 36),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child:
                          CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(isEditing ? 'Update' : 'Save'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text('Task Title *', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'What needs to be done?',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              // Description
              Text('Description', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Add details about this task…',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 44),
                    child: Icon(Icons.notes_rounded),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),

              // Priority
              Text('Priority', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: TaskPriority.values.map((p) {
                  final selected = _priority == p;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => _priority = p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? p.color.withOpacity(0.15)
                                : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? p.color : Colors.grey.shade300,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(p.icon,
                                  color: selected ? p.color : Colors.grey,
                                  size: 20),
                              const SizedBox(height: 4),
                              Text(
                                p.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: selected ? p.color : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Status
              Text('Status', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: TaskStatus.values.map((s) {
                  final selected = _status == s;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => _status = s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? s.color.withOpacity(0.15)
                                : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? s.color : Colors.grey.shade300,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(s.icon,
                                  color: selected ? s.color : Colors.grey,
                                  size: 20),
                              const SizedBox(height: 4),
                              Text(
                                s.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: selected ? s.color : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Due Date
              Text('Due Date (optional)', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _pickDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 18,
                          color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      const SizedBox(width: 12),
                      Text(
                        _dueDate != null
                            ? DateFormat('EEEE, MMM d yyyy').format(_dueDate!)
                            : 'Select a due date',
                        style: TextStyle(
                          color: _dueDate != null
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                      const Spacer(),
                      if (_dueDate != null)
                        GestureDetector(
                          onTap: () => setState(() => _dueDate = null),
                          child: Icon(Icons.close_rounded,
                              size: 18, color: Colors.grey.shade500),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
