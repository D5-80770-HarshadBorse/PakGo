import 'package:flutter/material.dart';
import 'package:pakgo/features/profile/screen/change_password_screen.dart';
import 'package:provider/provider.dart';
import 'package:pakgo/data/models/user.dart';
import 'package:pakgo/data/providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _resetControllers() {
    final user = context.read<UserProvider>().user;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final originalUser = context.read<UserProvider>().user!;
    final Map<String, dynamic> updateData = {};

    if (_nameController.text.trim() != originalUser.name) {
      updateData['name'] = _nameController.text.trim();
    }
    if (_emailController.text.trim() != originalUser.email) {
      updateData['email'] = _emailController.text.trim();
    }
    if (_phoneController.text.trim() != (originalUser.phone ?? '')) {
      updateData['phone'] = _phoneController.text.trim();
    }

    if (updateData.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No changes were made.')));
      setState(() => _isEditing = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<UserProvider>().updateUserProfile(updateData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile Updated Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.grey[900],
            expandedHeight: 250.0,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: _buildHeader(user),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 150),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ProfileInfoTile(
                        icon: Icons.person_outline,
                        title: 'Full Name',
                        value: user.name,
                        controller: _nameController,
                        isEditing: _isEditing,
                        validator: (value) =>
                            value!.isEmpty ? 'Name cannot be empty' : null,
                      ),
                      const SizedBox(height: 15),
                      _ProfileInfoTile(
                        icon: Icons.email_outlined,
                        title: 'Email Address',
                        value: user.email,
                        controller: _emailController,
                        isEditing: _isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email cannot be empty';
                          }
                          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      _ProfileInfoTile(
                        icon: Icons.phone_outlined,
                        title: 'Phone Number',
                        value: user.phone ?? 'Not set',
                        controller: _phoneController,
                        isEditing: _isEditing,
                      ),
                      const SizedBox(height: 30),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.lock_outline, size: 20),
                label: const Text('CHANGE PASSWORD'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, size: 20),
                label: const Text('LOGOUT'),
                onPressed: () => context.read<UserProvider>().logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (rest of the ProfileScreen code is unchanged)

  Widget _buildActionButtons() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.save_alt_outlined, size: 20),
            label: const Text('SAVE CHANGES'),
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              setState(() {
                _isEditing = false;
                _resetControllers();
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
          ),
        ],
      );
    } else {
      return ElevatedButton.icon(
        icon: const Icon(Icons.edit_outlined, size: 20),
        label: const Text('EDIT PROFILE'),
        onPressed: () => setState(() => _isEditing = true),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white24,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Widget _buildHeader(User user) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.grey[900]),
        const Center(
          child: CircleAvatar(
            radius: 55,
            backgroundColor: Colors.black,
            child: CircleAvatar(
              radius: 52,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isEditing;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;

  const _ProfileInfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.isEditing,
    this.controller,
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
            child: isEditing && controller != null
                ? TextFormField(
                    controller: controller,
                    validator: validator,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: title,
                      labelStyle: const TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
