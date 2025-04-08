import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app_for_class/model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Todo App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TodoHomePage(),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  @override
  _TodoHomePageState createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  List<TodoModel> _todos = [];
  int _nextId = 1;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  void _addOrUpdateTodo({TodoModel? existingTodo}) {
    final titleController = TextEditingController(text: existingTodo?.title);
    final descController = TextEditingController(text: existingTodo?.desc);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existingTodo == null ? 'Add Todo' : 'Update Todo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
              minLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text(existingTodo == null ? 'Add' : 'Update'),
            onPressed: () {
              final title = titleController.text.trim();
              final desc = descController.text.trim();
              if (title.isEmpty) return;

              setState(() {
                if (existingTodo == null) {
                  _todos.add(TodoModel(id: _nextId++, title: title, desc: desc));
                } else {
                  existingTodo.title = title;
                  existingTodo.desc = desc;
                }
                _saveTodos();
              });

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _deleteTodo(TodoModel todo) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this todo?'),
        actions: [
          TextButton(
            child: Text('No'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Yes'),
            onPressed: () {
              setState(() {
                _todos.removeWhere((t) => t.id == todo.id);
              });
              Navigator.pop(context);
              _saveTodos();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosJson = prefs.getString('todos');
    if (todosJson != null) {
      final List decoded = json.decode(todosJson);
      setState(() {
        _todos = decoded.map((e) => TodoModel.fromJson(e)).toList();
        _nextId = _todos.isNotEmpty ? (_todos.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1) : 1;
        _saveTodos();
      });
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String todosJson = json.encode(_todos.map((e) => e.toJson()).toList());
    await prefs.setString('todos', todosJson);
  }

  void _toggleDone(TodoModel todo) {
    setState(() {
      todo.isDone = !todo.isDone;
      _saveTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Todo List'),
      ),
      body: _todos.isEmpty
          ? Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
                ClipRRect(
                  child: Image.asset(
                    "sad_girl.jpg",
                    width: 140,
                    height: 140,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                SizedBox(
                  height: 20,
                ),
                Text('No todos yet!',style: TextStyle(fontWeight: FontWeight.bold),),
              ],
      ))
          : ListView.separated(
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          final todo = _todos[index];
          return TodoItemView(
            todo: todo,
            onToggle: () => _toggleDone(todo),
            onEdit: () => _addOrUpdateTodo(existingTodo: todo),
            onDelete: () => _deleteTodo(todo),
          );
        },
        separatorBuilder: (context, index) => Divider(
          thickness: 1,
          height: 1,
          color: Colors.grey[300],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateTodo(),
        child: Icon(Icons.add),
      ),
    );
  }
}

class TodoItemView extends StatelessWidget {
  final TodoModel todo;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TodoItemView({
    Key? key,
    required this.todo,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          Checkbox(
            value: todo.isDone,
            onChanged: (_) => onToggle(),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration:
                    todo.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  todo.desc,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, size: 20),
                onPressed: onEdit,
              ),
              IconButton(
                icon: Icon(Icons.delete, size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
