import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pakgo/data/providers/user_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final Map<String, dynamic> passwordData = {
      'currentPassword': _currentPasswordController.text.trim(),
      'password': _newPasswordController.text.trim(),
    };

    try {
      await context.read<UserProvider>().updateUserProfile(passwordData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _passwordValidator(String? value, {bool isConfirm = false}) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }
    if (!isConfirm) {
      if (value.length < 8) {
        return 'Password must be at least 8 characters';
      }
      if (!RegExp(r'[A-Z]').hasMatch(value)) {
        return 'Include at least 1 uppercase letter';
      }
      if (!RegExp(r'[0-9]').hasMatch(value)) {
        return 'Include at least 1 number';
      }
    } else {
      if (value != _newPasswordController.text) {
        return 'Passwords do not match';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Change Password',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, // 👈 stops expanding
              children: [
                _PasswordFieldTile(
                  icon: Icons.lock_outline,
                  title: 'Current Password',
                  controller: _currentPasswordController,
                  isObscure: _obscureCurrent,
                  toggleObscure: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                  validator: (value) =>
                  value!.isEmpty ? 'Enter your current password' : null,
                ),
                const SizedBox(height: 15),
                _PasswordFieldTile(
                  icon: Icons.lock_reset_outlined,
                  title: 'New Password',
                  controller: _newPasswordController,
                  isObscure: _obscureNew,
                  toggleObscure: () =>
                      setState(() => _obscureNew = !_obscureNew),
                  validator: (value) => _passwordValidator(value),
                ),
                const SizedBox(height: 15),
                _PasswordFieldTile(
                  icon: Icons.verified_user_outlined,
                  title: 'Confirm Password',
                  controller: _confirmPasswordController,
                  isObscure: _obscureConfirm,
                  toggleObscure: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (value) =>
                      _passwordValidator(value, isConfirm: true),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Colors.white),
        )
            : SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save_alt_outlined, size: 20),
            label: const Text('UPDATE PASSWORD'),
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordFieldTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final TextEditingController controller;
  final bool isObscure;
  final VoidCallback toggleObscure;
  final FormFieldValidator<String>? validator;

  const _PasswordFieldTile({
    required this.icon,
    required this.title,
    required this.controller,
    required this.isObscure,
    required this.toggleObscure,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: controller,
              validator: validator,
              obscureText: isObscure,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                labelText: title,
                labelStyle: const TextStyle(color: Colors.white54),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                suffixIcon: IconButton(
                  icon: Icon(
                    isObscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white54,
                  ),
                  onPressed: toggleObscure,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
