import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes/route_names.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/common/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _passwordVisible = false;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Enter email';
    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    if (!RegExp(pattern).hasMatch(value)) return 'Invalid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter password';
    if (value.length < 6) return 'Min 6 characters';
    return null;
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        SignInWithEmailEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  void _handleGoogleSignIn() {
    context.read<AuthBloc>().add(SignInWithGoogleEvent());
  }

  // Neumorphic box but neutral (keeps depth)
  BoxDecoration neuBox({
    bool isPressed = false,
    double radius = 20,
    Color color = const Color(0xFFEDECF3),
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: isPressed
          ? [
        const BoxShadow(
          color: Colors.white,
          offset: Offset(-3, -3),
          blurRadius: 6,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.10),
          offset: const Offset(3, 3),
          blurRadius: 6,
        ),
      ]
          : [
        const BoxShadow(
          color: Colors.white,
          offset: Offset(-6, -6),
          blurRadius: 12,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.10),
          offset: const Offset(6, 6),
          blurRadius: 12,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFEDECF3);
    final accentStart = Colors.indigo.shade400; // accent only
    final accentEnd = Colors.blue.shade400;

    return Scaffold(
      backgroundColor: bg,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go(RouteNames.home);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // logo plate (neutral icon color)
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: neuBox(radius: 80),
                      child: Icon(
                        Icons.medication_rounded,
                        size: 70,
                        color: Colors.grey.shade800, // neutral icon
                      ),
                    ),

                    const SizedBox(height: 30),

                    // title (neutral)
                    Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade900,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Sign in to your account",
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),

                    const SizedBox(height: 36),

                    // EMAIL
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),

                      decoration: neuBox(),
                      child: CustomTextField(
                        controller: _emailController,
                        label: "Email",
                        hint: "Enter email",
                        prefixIcon: Icons.mail_outline,
                        validator: _validateEmail,
                        filled: true,
                        fillColor: bg,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // PASSWORD
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),

                      decoration: neuBox(),
                      child: CustomTextField(
                        controller: _passwordController,
                        label: "Password",
                        hint: "Enter password",
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                        validator: _validatePassword,
                        filled: true,
                        fillColor: bg,
                        // keep the local toggle but neutral icon color is applied by CustomTextField
                        suffixIcon: IconButton(
                          icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey.shade600),
                          onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // SIGN IN BUTTON — accent only
                    GestureDetector(
                      onTap: isLoading ? null : _handleLogin,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        height: 54,
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(colors: [accentStart, accentEnd]),
                          boxShadow: [
                            BoxShadow(
                              color: accentEnd.withOpacity(0.18),
                              offset: const Offset(4, 4),
                              blurRadius: 10,
                            ),
                            const BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 10),
                          ],
                        ),
                        child: isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2))
                            : Text("Sign In", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text("OR", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),

                    const SizedBox(height: 18),

                    // Google button neutral
                    GestureDetector(
                      onTap: isLoading ? null : _handleGoogleSignIn,
                      child: Container(
                        height: 52,
                        decoration: neuBox(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/icons/google.png", height: 22),
                            const SizedBox(width: 12),
                            Text("Sign in with Google", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ", style: TextStyle(color: Colors.grey.shade700)),
                        TextButton(
                          onPressed: () => context.go(RouteNames.register),
                          child: Text("Sign Up", style: TextStyle(fontWeight: FontWeight.bold, color: accentStart)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
