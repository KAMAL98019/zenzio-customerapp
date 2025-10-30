import 'package:customer_app/core/constants/appcolors.dart';
import 'package:customer_app/core/constants/appdimensions.dart';
import 'package:customer_app/core/constants/appstrings.dart';
import 'package:customer_app/core/theme/app_theme.dart';
import 'package:customer_app/screens/auth/login.dart';
import 'package:customer_app/services/Authservices.dart';
import 'package:customer_app/widgets/buttonwidget.dart';
import 'package:customer_app/widgets/custominputfield.dart';
import 'package:customer_app/widgets/dateselectfield.dart';
import 'package:customer_app/widgets/passwordinputfield.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  String? _selectedBirthday;
  String? _selectedAnniversary;

  // Flutter Toast (copied from login.dart for consistency)
  void showToast(String msg, {ToastType type = ToastType.success}) {
    Color bgColor;
    switch (type) {
      case ToastType.success:
        bgColor = Colors.green;
        break;
      case ToastType.error:
        bgColor = Colors.red;
        break;
      case ToastType.warning:
        bgColor = Colors.orange;
        break;
      case ToastType.info:
        bgColor = AppColors.primary;
        break;
    }
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: bgColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    try {
      await AuthService.registerUser(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        mobile: _mobileController.text,
        birthday: _selectedBirthday,
        anniversary: _selectedAnniversary,
      );
      // Registration successful, navigate to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPageState()),
      );
      showToast("Registration Successful! Please login.", type: ToastType.success);
    } catch (e) {
      // Handle registration error
      showToast("Registration Failed: ${e.toString().replaceFirst('Exception: ', '')}", type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: AppColors.primary),
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text(
          AppStrings.appName,
          style: TextStyle(
            fontSize: 18,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 73),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.createaccount,
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.marginLarge),
              Padding(
                padding: EdgeInsetsGeometry.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      hintText: "Enter The Name",
                      labelText: "Name",
                    ),
                    SizedBox(height: AppDimensions.marginLarge),
                    CustomTextField(
                      controller: _emailController,
                      hintText: "Enter The Email",
                      labelText: "Email",
                    ),
                    SizedBox(height: AppDimensions.marginLarge),
                    PasswordInputField(
                      hintText: "Enter the Password",
                      controller: _passwordController,
                      labelText: "Password",
                    ),
                    SizedBox(height: AppDimensions.marginLarge),
                    CustomTextField(
                      controller: _mobileController,
                      hintText: "Enter The PhoneNumber",
                      labelText: "PhoneNumber",
                    ),
                    SizedBox(height: AppDimensions.marginLarge),
                    DateSelectField(
                      labelText: "Birthday",
                      hintText: "Select your birthday",
                      onDateSelected: (DateTime? date) {
                        setState(() {
                          _selectedBirthday = date?.toIso8601String().split('T').first;
                        });
                      },
                    ),
                    SizedBox(height: AppDimensions.marginLarge),
                    DateSelectField(
                      labelText: "Anniversary",
                      hintText: "Select your anniversary (Optional)",
                      onDateSelected: (DateTime? date) {
                        setState(() {
                          _selectedAnniversary = date?.toIso8601String().split('T').first;
                        });
                      },
                    ),
                    SizedBox(height: AppDimensions.marginXLarge),
                    ButtonWidget(onPressed: _registerUser, text: "Sign Up"),
                    SizedBox(height: AppDimensions.marginXLarge),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(fontSize: 16),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to SignUp page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPageState(),
                              ),
                            );
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.primary, // clickable link color
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
