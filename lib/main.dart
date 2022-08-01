import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_pof/services/todo_service.dart';
import 'package:sqflite_pof/services/user_service.dart';

import 'routes/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TodoService(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserService(),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: RouteManager.loginPage,
        onGenerateRoute: RouteManager.generateRoute,
      ),
    );
  }
}
