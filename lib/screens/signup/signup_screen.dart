import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instaclone/repositories/repositories.dart';
import 'package:instaclone/screens/signup/cubit/signup_cubit.dart';
import 'package:instaclone/widgets/widgets.dart';

class SignupScreen extends StatelessWidget {
  static const String routeName = '/signup';
  SignupScreen({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => BlocProvider<SignupCubit>(
          create: (_) => SignupCubit(
                authRepository: context.read<AuthRepository>(),
              ),
          child: SignupScreen()),
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: BlocConsumer<SignupCubit, SignupState>(
          listener: (context, state) {
            if (state.status == SignupStatus.error) {
              showDialog(
                context: context,
                builder: (context) => ErrorDialog(
                  content: state.failure.message,
                ),
              );
            }
          },
          builder: (context, state) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Instagram",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12),
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Username',
                                ),
                                onChanged: (value) => context
                                    .read<SignupCubit>()
                                    .usernameChanged(value),
                                validator: (value) => value!.trim().isEmpty
                                    ? 'Please enter a valid Username'
                                    : null,
                              ),
                              SizedBox(height: 12),
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                ),
                                onChanged: (value) => context
                                    .read<SignupCubit>()
                                    .emailChanged(value),
                                validator: (value) =>
                                    !(value?.contains('@') ?? false)
                                        ? "Please enter valid email"
                                        : null,
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                ),
                                onChanged: (value) => context
                                    .read<SignupCubit>()
                                    .passwordChanged(value),
                                obscureText: true,
                                validator: (value) => value!.length < 6
                                    ? 'Must be at least 6 characters'
                                    : null,
                              ),
                              SizedBox(height: 28),
                              MaterialButton(
                                onPressed: () => _submitForm(
                                  context,
                                  state.status == SignupStatus.submitting,
                                ),
                                elevation: 1,
                                color: Theme.of(context).primaryColor,
                                textColor: Colors.white,
                                child: Text('Signup'),
                              ),
                              SizedBox(height: 12),
                              MaterialButton(
                                onPressed: () => Navigator.of(context).pop(),
                                elevation: 1,
                                color: Colors.grey.shade200,
                                textColor: Colors.black,
                                child: Text('Back to Login'),
                              ),
                            ],
                          ),
                        ),
                      )),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _submitForm(BuildContext context, bool isSubmitting) {
    if (_formKey.currentState!.validate() && !isSubmitting) {
      context.read<SignupCubit>().signUpWithCredentials();
    }
  }
}
