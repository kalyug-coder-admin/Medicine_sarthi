import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes/route_names.dart';
import '../../../domain/entities/user_entity.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/common/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _ageController = TextEditingController();
  final _linkCodeController = TextEditingController();

  String _selectedGender = 'Male';
  UserRole _selectedRole = UserRole.elderly;

  final Color bg = const Color(0xFFFFFDFC);
  final Color accentBlue = const Color(0xFF2B65A8);
  final Color accentPink = const Color(0xFFE85A8A);
  final Color textGrey = const Color(0xFF8A8F9E);

  // Uploaded Krishna outline image path
  final String _topImagePath =
      '/mnt/data/ccabbe73-e011-49d8-9418-1d01b11d08e7.png';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _linkCodeController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        SignUpWithEmailEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          age: int.parse(_ageController.text.trim()),
          gender: _selectedGender,
          role: _selectedRole,
          linkedElderlyId: _selectedRole == UserRole.family &&
              _linkCodeController.text.isNotEmpty
              ? _linkCodeController.text.trim()
              : null,
        ),
      );
    }
  }

  BoxDecoration softBox() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
            color: Colors.pink.shade50,
            offset: const Offset(-3, -3),
            blurRadius: 6),
        BoxShadow(
            color: Colors.blue.shade50,
            offset: const Offset(3, 3),
            blurRadius: 6),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: accentBlue, size: 26),
          onPressed: () => context.go(RouteNames.login),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) context.go(RouteNames.home);
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ---------------- TITLE + IMAGE INLINE ----------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        Flexible(
                          child: Text(
                            "Radha Krishna CARE",
                            style: TextStyle(
                              fontSize: 26,          // reduced from 30
                              fontWeight: FontWeight.w700,
                              color: accentBlue,
                            ),
                            overflow: TextOverflow.visible,
                            softWrap: false,
                          ),
                        ),

                        const SizedBox(width: 8),

                        SizedBox(
                          height: 24,               // was 30
                          width: 24,
                          child: _buildTopImage(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ---------------- SUBTITLE ----------------
                    Text(
                      "Create your divine connection",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: accentPink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ---------------- INPUT FIELDS ----------------
                    _buildField("Your Name", _nameController,
                        Icons.person_outline),
                    const SizedBox(height: 18),

                    _buildField(
                        "Email", _emailController, Icons.email_outlined),
                    const SizedBox(height: 18),

                    _buildPasswordField("Password", _passwordController),
                    const SizedBox(height: 18),

                    _buildPasswordField(
                        "Confirm Password", _confirmPasswordController),
                    const SizedBox(height: 20),

                    // ---------------- AGE + GENDER ----------------
                    Row(
                      children: [
                        Expanded(
                          child: _buildField("Age", _ageController,
                              Icons.calendar_today,
                              isNumber: true),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Gender",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Container(
                                decoration: softBox(),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: Colors.white,       // popup menu
                                    focusColor: Colors.transparent,  // no focus color
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                  ),
                                  child: DropdownButtonFormField(
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isCollapsed: true,
                                      fillColor: Colors.white,     // removes gray background
                                      filled: true,
                                    ),

                                    dropdownColor: Colors.white,
                                    isDense: true,
                                    borderRadius: BorderRadius.circular(18),

                                    style: const TextStyle(
                                      color: Colors.black,     // text color
                                      fontSize: 15,
                                    ),

                                    value: _selectedGender,
                                    items: ["Male", "Female", "Other"]
                                        .map((g) => DropdownMenuItem(
                                      value: g,
                                      child: Text(g),
                                    ))
                                        .toList(),

                                    onChanged: (v) {
                                      setState(() => _selectedGender = v!);
                                    },
                                  ),
                                ),
                              )

                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 26),

                    // ---------------- ACCOUNT TYPE ----------------
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: softBox(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Account Type",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87)),
                          const SizedBox(height: 8),

                          RadioListTile<UserRole>(
                            value: UserRole.elderly,
                            groupValue: _selectedRole,
                            activeColor: accentBlue,
                            contentPadding: EdgeInsets.zero,
                            title: const Text("Elderly User"),
                            subtitle: Text("Primary account holder",
                                style: TextStyle(color: textGrey)),
                            onChanged: (value) =>
                                setState(() => _selectedRole = value!),
                          ),

                          RadioListTile<UserRole>(
                            value: UserRole.family,
                            groupValue: _selectedRole,
                            activeColor: accentBlue,
                            contentPadding: EdgeInsets.zero,
                            title: const Text("Family Member"),
                            subtitle: Text("Monitor elderly family member",
                                style: TextStyle(color: textGrey)),
                            onChanged: (value) =>
                                setState(() => _selectedRole = value!),
                          ),
                        ],
                      ),
                    ),

                    if (_selectedRole == UserRole.family) ...[
                      const SizedBox(height: 18),
                      _buildField("Family Link Code", _linkCodeController,
                          Icons.link),
                    ],

                    const SizedBox(height: 30),

                    // ---------------- BOTTOM FLUTE IMAGE ----------------
                    Center(
                      child: Image.asset(
                        "assets/icons/img.png",
                        height: 110,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---------------- CREATE ACCOUNT BUTTON ----------------
                    GestureDetector(
                      onTap: isLoading ? null : _handleRegister,
                      child: AnimatedContainer(
                        duration:
                        const Duration(milliseconds: 200),
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                              colors: [accentBlue, accentPink]),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                            color: Colors.white)
                            : const Text(
                          "Create Account",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ---------------- SIGN-IN LINK ----------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? ",
                            style: TextStyle(color: textGrey)),
                        TextButton(
                          onPressed: () =>
                              context.go(RouteNames.login),
                          child: Text("Sign In",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: accentBlue)),
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

  // ---------------- HELPERS ----------------

  Widget _buildTopImage() {
    try {
      final file = File(_topImagePath);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.contain);
      }
    } catch (_) {}
    return const SizedBox.shrink();
  }

  Widget _buildField(String label, TextEditingController controller,
      IconData icon,
      {bool isNumber = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: softBox(),
      child: CustomTextField(
        controller: controller,
        label: label,
        hint: label,
        prefixIcon: icon,
        keyboardType:
        isNumber ? TextInputType.number : TextInputType.text,
      ),
    );
  }

  Widget _buildPasswordField(
      String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: softBox(),
      child: CustomTextField(
        controller: controller,
        label: label,
        hint: label,
        prefixIcon: Icons.lock_outline,
        obscureText: true,
      ),
    );
  }
}
