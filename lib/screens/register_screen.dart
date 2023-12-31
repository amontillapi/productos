import 'package:flutter/material.dart';
import 'package:productos/providers/login_form_provider.dart';
import 'package:productos/ui/input_decorations.dart';
import 'package:productos/widgets/widgets.dart';
import 'package:provider/provider.dart';

import '../services/services.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 250),
              CardContainer(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Register',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    const SizedBox(height: 20),
                    ChangeNotifierProvider(
                      create: (_) => LoginFormProvider(),
                      child: const _LoginForm(),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 50),
              TextButton(
                style: ButtonStyle(
                  overlayColor: MaterialStatePropertyAll(
                    (Colors.amber[600])!.withOpacity(0.1),
                  ),
                  shape: const MaterialStatePropertyAll(
                    StadiumBorder(),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('login');
                },
                child: const Text(
                  'Already have an account?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);
    return Form(
      key: loginForm.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          TextFormField(
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecorations.authInputDecoration(
              hintText: 'john.doe@gmail.com',
              labelText: 'Email address',
              prefixIcon: Icons.alternate_email,
            ),
            onChanged: (value) => loginForm.email = value,
            validator: (value) {
              String pattern =
                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

              RegExp regExp = RegExp(pattern);

              return regExp.hasMatch(value ?? '')
                  ? null
                  : 'Enter a valid email';
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            autocorrect: false,
            obscureText: true,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecorations.authInputDecoration(
              hintText: '**********',
              labelText: 'Password',
              prefixIcon: Icons.password,
            ),
            onChanged: (value) => loginForm.password = value,
            validator: (value) {
              return value != null && value.length >= 6
                  ? null
                  : 'This password doesn´t have minimum characters';
            },
          ),
          const SizedBox(height: 30),
          MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            disabledColor: Colors.grey,
            elevation: 0,
            color: Colors.deepPurple,
            onPressed: loginForm.isLoading
                ? null
                : () async {
                    FocusScope.of(context).unfocus();
                    final authService =
                        Provider.of<AuthService>(context, listen: false);
                    if (!loginForm.isValidForm()) return;
                    loginForm.isLoading = true;
                    await Future.delayed(const Duration(seconds: 2));
                    final String? errorMessage = await authService.createUser(
                      loginForm.email,
                      loginForm.password,
                    );
                    if (errorMessage == null) {
                      Future.microtask(
                        () => Navigator.pushReplacementNamed(context, 'home'),
                      );
                    } else {
                      loginForm.isLoading = false;
                    }
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
              child: Text(
                loginForm.isLoading ? 'Loading...' : 'Enter',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
