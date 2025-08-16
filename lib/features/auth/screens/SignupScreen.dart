import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:pakgo/core/constants/app_strings.dart';
import 'package:pakgo/features/auth/services/auth_service.dart';
import 'package:pakgo/routes/app_routes.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController =
      TextEditingController(); // New controller for phone number
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset:
          false, // Prevents the screen from resizing when the keyboard opens
      body: Stack(
        // Use Stack to layer the widgets
        children: [
          // Top section with welcome message and input fields
          Column(
            mainAxisAlignment:
                MainAxisAlignment.start, // Align content to the top
            children: [
              const SizedBox(height: 100), // Creates space from the top
              const Image(
                image: AssetImage('assets/images/courier-services.png'),
                height: 100.0,
                width: 100.0,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              const Text(
                "PakGo",
                style: TextStyle(color: Colors.white, fontSize: 40),
              ),
              const SizedBox(height: 40),
              _buildTextField(
                controller: fullNameController,
                icon: Icons.person_outline,
                hintText: "Full Name",
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: emailController,
                icon: Icons.email_outlined,
                hintText: "Email",
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: phoneController, // Phone number field
                icon: Icons.phone_android,
                hintText: "Phone",
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: passwordController,
                icon: Icons.lock_outline,
                hintText: "Password",
                isPassword: true,
              ),
            ],
          ),

          // Curved white bottom section with login button
          DraggableScrollableSheet(
            initialChildSize: 0.18, // starting height (15% of screen)
            minChildSize: 0.18,
            maxChildSize: 0.30, // Adjusted to accommodate more social buttons
            builder: (context, scrollController) {
              return Padding(
                // Add dynamic padding based on keyboard height
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Drag handle
                          Container(
                            width: 40,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),

                          // Sign-up button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                final fullName = fullNameController.text.trim();
                                final email = emailController.text.trim();
                                final phone = phoneController.text.trim();
                                final password = passwordController.text.trim();

                                if (fullName.isEmpty ||
                                    email.isEmpty ||
                                    phone.isEmpty ||
                                    password.isEmpty) {
                                  _showToast("All fields are required!", false);
                                  return;
                                }

                                final result = await AuthService.auth(
                                  fullName: fullName,
                                  email: email,
                                  phone: phone,
                                  password: password,
                                  isLogin : false
                                );

                                if (result["success"]) {
                                  _showToast(
                                    AppStrings.registrationSuccess,
                                    true,
                                  );
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.login,
                                  );
                                } else {
                                  _showToast(result["message"], false);
                                }
                              },
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // Login text
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.login,
                              );
                            },
                            child: const Text.rich(
                              TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Login",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Social login buttons (visible when scrolled up)
                          const SizedBox(height: 25),
                          const Divider(thickness: 1),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _socialLoginButton(Bootstrap.google, "Google"),
                              _socialLoginButton(Icons.facebook, "Facebook"),
                              _socialLoginButton(Icons.apple, "Apple"),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _socialLoginButton(IconData icon, String label) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {},
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          prefixIcon: Icon(icon, color: Colors.white70),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                )
              : null,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

void _showToast(String message, bool isSuccess) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.TOP,
    backgroundColor: isSuccess ? Colors.green : Colors.red,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
