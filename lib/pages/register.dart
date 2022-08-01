import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_pof/models/user.dart';
import 'package:sqflite_pof/services/user_service.dart';
import 'package:sqflite_pof/widgets/dialogs.dart';

import '../widgets/app_textfield.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late TextEditingController usernameController;
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    nameController = TextEditingController();
  }

  @override
  void dispose() {
    usernameController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 30.0),
                      child: Text(
                        'Register User',
                        style: TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w200,
                            color: Colors.white),
                      ),
                    ),
                    Focus(
                      onFocusChange: (value) async {
                        if (!value) {
                          String result = await context
                              .read<UserService>()
                              .checkIfUserExist(usernameController.text.trim());
                          if (result == 'OK') {
                            if (!mounted) return;
                            context.read<UserService>().userExists = true;
                          } else {
                            if (!mounted) return;
                            context.read<UserService>().userExists = false;
                            if (!result.contains(
                                'The user does not exist in the database. Please register first.')) {
                              showSnackBar(context, 'Username Available');
                            }
                          }
                        }
                      },
                      child: AppTextField(
                        controller: usernameController,
                        labelText: 'Please enter your username',
                      ),
                    ),
                    Selector<UserService, bool>(
                      selector: (p0, p1) => p1.userExists,
                      builder: (context, value, child) {
                        return value
                            ? const Text(
                                'username exists, please choose another',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w800),
                              )
                            : Container();
                      },
                    ),
                    AppTextField(
                      controller: nameController,
                      labelText: 'Please enter your name',
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.purple,
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ))),
                        onPressed: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          //to take the focus away from the keyboard
                          if (usernameController.text.isEmpty ||
                              nameController.text.isEmpty) {
                            showSnackBar(context, 'Please enter all fields');
                          } else {
                            //trim method remove white spaces
                            User user = User(
                                username: usernameController.text.trim(),
                                name: nameController.text.trim());
                            String result = await context
                                .read<UserService>()
                                .createUser(user);
                            if (result != 'Ok') {
                              //When a BuildContext is used from a StatefulWidget,
                              // the mounted property must be checked after an asynchronous gap.
                              if (!mounted) return;
                              showSnackBar(context, result);
                            } else {
                              if (!mounted) return;
                              showSnackBar(
                                  context, 'New user successfully created!');
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: const Text('Register'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 30,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
          Selector<UserService, bool>(
            selector: (p0, p1) => p1.busyCreate,
            builder: (context, value, child) {
              return value ? const AppProgressIndicator() : Container();
            },
          )
        ],
      ),
    );
  }
}

class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.white.withOpacity(0.5),
      child: const Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.purple,
          ),
        ),
      ),
    );
  }
}
