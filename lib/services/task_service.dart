import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../models/task.dart';

class TaskService {
  /// Create a new task in Back4App
  Future<bool> createTask(Task task) async {
    final parseObj = task.toParseObject();

    // Associate with the current user (ACL)
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user != null) {
      final acl = ParseACL();
      acl.setReadAccess(userId: user.objectId!, allowed: true);
      acl.setWriteAccess(userId: user.objectId!, allowed: true);
      parseObj.setACL(acl);
    }

    final response = await parseObj.save();
    return response.success;
  }

  /// Fetch all tasks for the current user, newest first
  Future<List<Task>> fetchTasks() async {
    final query = QueryBuilder<ParseObject>(ParseObject('Task'))
      ..orderByDescending('createdAt')
      ..setLimit(200);

    final response = await query.query();
    if (!response.success || response.results == null) return [];

    return response.results!
        .map((e) => Task.fromParseObject(e as ParseObject))
        .toList();
  }

  /// Update an existing task
  Future<bool> updateTask(Task task) async {
    if (task.objectId == null) return false;
    final parseObj = task.toParseObject();
    final response = await parseObj.save();
    return response.success;
  }

  /// Delete a task by objectId
  Future<bool> deleteTask(String objectId) async {
    final parseObj = ParseObject('Task')..objectId = objectId;
    final response = await parseObj.delete();
    return response.success;
  }
}
