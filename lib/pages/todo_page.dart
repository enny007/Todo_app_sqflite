import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_pof/models/user.dart';
import 'package:sqflite_pof/services/todo_service.dart';
import 'package:sqflite_pof/services/user_service.dart';
import 'package:sqflite_pof/widgets/dialogs.dart';

import '../models/todo.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({Key? key}) : super(key: key);

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  late TextEditingController todoController;

  @override
  void initState() {
    super.initState();
    todoController = TextEditingController();
  }

  @override
  void dispose() {
    todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple,
              Colors.blue,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text('Create a new TODO'),
                              content: TextField(
                                decoration: const InputDecoration(
                                    hintText: 'Please enter TODO'),
                                controller: todoController,
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                TextButton(
                                  child: const Text('Save'),
                                  onPressed: () async {
                                    if (todoController.text.isEmpty) {
                                      showSnackBar(
                                          context, 'Please enter a todo first');
                                      // the todo textfield can't be empty
                                    } else {
                                      String username = context
                                          .read<UserService>()
                                          .currentUser
                                          .username;
                                      Todo todo = Todo(
                                          //content of the Todo object inputed in the textfield
                                          username: username,
                                          created: DateTime.now(),
                                          title: todoController.text.trim());
                                      if (!mounted) return;
                                      //To test for duplicate in the TodoList
                                      if (context
                                          .read<TodoService>()
                                          .todos
                                          .contains(todo)) {
                                        showSnackBar(context,
                                            'Duplicate value, please check your entry');
                                      } else {
                                        //If it there are no duplicate, then create a new Todo
                                        String result = await context
                                            .read<TodoService>()
                                            .createTodo(todo);
                                        if (!mounted) return;
                                        if (result == 'Ok') {
                                          showSnackBar(context,
                                              'New todo successfully added!');
                                          //This relation is to refresh the content of the
                                          //textfield before inputing a new todo
                                          todoController.text = '';
                                        } else {
                                          showSnackBar(context, result);
                                        }
                                        Navigator.pop(context);
                                      }
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.exit_to_app,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Selector<UserService, User>(
                  //watching for a change in a particular value
                  selector: (p0, p1) => p1.currentUser,
                  builder: (context, value, child) {
                    return Text(
                      '${value.name}\'s Todo list',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.w200,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
                  child: Consumer<TodoService>(
                    builder: (context, value, child) {
                      return ListView.builder(
                        itemCount: value.todos.length,
                        itemBuilder: (context, index) {
                          return TodoCard(
                            todo: value.todos[index],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TodoCard extends StatelessWidget {
  const TodoCard({
    Key? key,
    required this.todo,
  }) : super(key: key);

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.purple.shade300,
      child: Slidable(
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          children: [
            SlidableAction(
              onPressed: (context) async {
                String result =
                    await context.read<TodoService>().deleteTodos(todo);
                if (result != 'OK') {
                  // ignore: use_build_context_synchronously
                  showSnackBar(context, 'Successfully deleted');
                } else {
                  // ignore: use_build_context_synchronously
                  showSnackBar(context, result);
                }
              },
              label: 'Delete',
              backgroundColor: Colors.purple.shade600,
              icon: Icons.delete,
            ),
          ],
        ),
        child: CheckboxListTile(
          checkColor: Colors.purple,
          activeColor: Colors.purple[100],
          value: todo.done,
          onChanged: (value) async {
            await context.read<TodoService>().toggleTodoDone(todo);
          },
          subtitle: Text(
            '${todo.created.day}/${todo.created.month}/${todo.created.year}',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              color: Colors.white,
              decoration:
                  todo.done ? TextDecoration.lineThrough : TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}
