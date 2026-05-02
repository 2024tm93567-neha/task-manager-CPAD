import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _service = TaskService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  TaskStatus? _filterStatus;
  TaskPriority? _filterPriority;

  List<Task> get tasks => _filteredTasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  TaskStatus? get filterStatus => _filterStatus;
  TaskPriority? get filterPriority => _filterPriority;

  // ── Stats ────────────────────────────────────────────────────────────────
  int get totalCount => _tasks.length;
  int get todoCount =>
      _tasks.where((t) => t.status == TaskStatus.todo).length;
  int get inProgressCount =>
      _tasks.where((t) => t.status == TaskStatus.inProgress).length;
  int get doneCount =>
      _tasks.where((t) => t.status == TaskStatus.done).length;
  int get overdueCount => _tasks.where((t) => t.isOverdue).length;

  // ── Filtered list ────────────────────────────────────────────────────────
  List<Task> get _filteredTasks {
    return _tasks.where((task) {
      final matchesSearch = _searchQuery.isEmpty ||
          task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus =
          _filterStatus == null || task.status == _filterStatus;
      final matchesPriority =
          _filterPriority == null || task.priority == _filterPriority;
      return matchesSearch && matchesStatus && matchesPriority;
    }).toList();
  }

  // ── Actions ──────────────────────────────────────────────────────────────
  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterStatus(TaskStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setFilterPriority(TaskPriority? priority) {
    _filterPriority = priority;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterStatus = null;
    _filterPriority = null;
    notifyListeners();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _service.fetchTasks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTask(Task task) async {
    final success = await _service.createTask(task);
    if (success) await loadTasks();
    return success;
  }

  Future<bool> updateTask(Task task) async {
    final success = await _service.updateTask(task);
    if (success) await loadTasks();
    return success;
  }

  Future<bool> deleteTask(String objectId) async {
    final success = await _service.deleteTask(objectId);
    if (success) {
      _tasks.removeWhere((t) => t.objectId == objectId);
      notifyListeners();
    }
    return success;
  }

  /// Quick status cycle: Todo → In Progress → Done → Todo
  Future<void> cycleStatus(Task task) async {
    final nextStatus = {
      TaskStatus.todo: TaskStatus.inProgress,
      TaskStatus.inProgress: TaskStatus.done,
      TaskStatus.done: TaskStatus.todo,
    }[task.status]!;
    await updateTask(task.copyWith(status: nextStatus));
  }
}
