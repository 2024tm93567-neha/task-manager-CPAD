import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/task_card.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String _userEmail = '';
  bool _themeToggled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
      _loadUser();
    });
  }

  Future<void> _loadUser() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user != null && mounted) {
      setState(() => _userEmail = user.username ?? '');
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await AuthService().logout();
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Future<void> _openForm([Task? task]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
    if (result == true && mounted) {
      context.read<TaskProvider>().loadTasks();
    }
  }

  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Task'),
        content: Text('Delete "${task.title}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && task.objectId != null) {
      await context.read<TaskProvider>().deleteTask(task.objectId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<TaskProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Task Manager',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            if (_userEmail.isNotEmpty)
              Text(
                _userEmail,
                style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.5)),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Stats Header ──────────────────────────────────────────────────
          Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                // Stats row
                Row(
                  children: [
                    _StatBox(
                        label: 'Total',
                        count: provider.totalCount,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    _StatBox(
                        label: 'To Do',
                        count: provider.todoCount,
                        color: const Color(0xFF5C6BC0)),
                    const SizedBox(width: 8),
                    _StatBox(
                        label: 'Doing',
                        count: provider.inProgressCount,
                        color: const Color(0xFFFB8C00)),
                    const SizedBox(width: 8),
                    _StatBox(
                        label: 'Done',
                        count: provider.doneCount,
                        color: const Color(0xFF43A047)),
                    if (provider.overdueCount > 0) ...[
                      const SizedBox(width: 8),
                      _StatBox(
                          label: 'Overdue',
                          count: provider.overdueCount,
                          color: Colors.red),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Search bar
                TextField(
                  controller: _searchCtrl,
                  onChanged: provider.setSearch,
                  decoration: InputDecoration(
                    hintText: 'Search tasks…',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              provider.setSearch('');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 8),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: provider.filterStatus == null &&
                            provider.filterPriority == null,
                        onTap: provider.clearFilters,
                      ),
                      const SizedBox(width: 6),
                      ...TaskStatus.values.map((s) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _FilterChip(
                              label: s.label,
                              selected: provider.filterStatus == s,
                              color: s.color,
                              onTap: () => provider.setFilterStatus(
                                  provider.filterStatus == s ? null : s),
                            ),
                          )),
                      ...TaskPriority.values.map((p) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _FilterChip(
                              label: p.label,
                              selected: provider.filterPriority == p,
                              color: p.color,
                              onTap: () => provider.setFilterPriority(
                                  provider.filterPriority == p ? null : p),
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Task List ─────────────────────────────────────────────────────
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.tasks.isEmpty
                    ? _EmptyState(
                        hasFilter: provider.filterStatus != null ||
                            provider.filterPriority != null ||
                            provider.searchQuery.isNotEmpty,
                        onClear: provider.clearFilters,
                        onCreate: () => _openForm(),
                      )
                    : RefreshIndicator(
                        onRefresh: provider.loadTasks,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: provider.tasks.length,
                          itemBuilder: (context, index) {
                            final task = provider.tasks[index];
                            return TaskCard(
                              task: task,
                              index: index,
                              onEdit: () => _openForm(task),
                              onDelete: () => _deleteTask(task),
                              onStatusCycle: () =>
                                  provider.cycleStatus(task),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Task'),
      ).animate().scale(delay: 300.ms, curve: Curves.elasticOut),
    );
  }
}

// ── Stat Box ────────────────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatBox(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            Text(label,
                style: TextStyle(fontSize: 10, color: color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}

// ── Filter Chip ─────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label,
      required this.selected,
      this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? c.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? c : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? c : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

// ── Empty State ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  final VoidCallback onClear;
  final VoidCallback onCreate;

  const _EmptyState(
      {required this.hasFilter,
      required this.onClear,
      required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilter
                  ? Icons.filter_list_off_rounded
                  : Icons.check_circle_outline_rounded,
              size: 72,
              color: theme.colorScheme.onSurface.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilter ? 'No matching tasks' : 'No tasks yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'Try clearing the filters'
                  : 'Tap + to create your first task',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 20),
            if (hasFilter)
              OutlinedButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
                label: const Text('Clear filters'),
              )
            else
              FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Task'),
              ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }
}
