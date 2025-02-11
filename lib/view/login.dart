import 'package:dupepro/bottomBar.dart';
import 'package:dupepro/controller/auth_controller.dart';
import 'package:dupepro/view/forgotpass.dart';
import 'package:dupepro/view/registration.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}
class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
 final AuthController _authController=AuthController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String email =_emailController.text.trim();
      String password=_passwordController.text.trim();
      String? result = await _authController.loginUser(email, password);

      if(result==null)
        {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BottomBarScreen()),
      );
    } else
      {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result)),
        );
      }
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF380230),
        toolbarHeight: 150,
        title: const Text(
          "𝐹𝒶𝒾𝓇𝓎𝒯𝓊𝓃𝑒𝓈",
          style: TextStyle(color: Colors.white, fontSize: 45),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),
              Text(
                'LOGIN NOW ! ',
                style:
                TextStyle(color: Color(0xFF380230), fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  final emailRegex = RegExp(r'^[^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email (e.g., user@gmail.com)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your password';
                  }
                  final passwordRegex = RegExp(
                      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@\\$!%*?&])[A-Za-z\d@\\$!%*?&]{6,}$');
                  if (!passwordRegex.hasMatch(value)) {
                    return 'Password must have at least 6 characters, including an uppercase letter, a lowercase letter, a number, and a special character';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                  );
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Color(0xFF380230)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xFF380230)),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Not a member yet?',
                style: TextStyle(color: Color(0xFF380230)),
                textAlign: TextAlign.center,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
                child: const Text(
                  'Sign up now!',
                  style: TextStyle(color: Color(0xFF380230)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BottomBarScreen()),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xFF380230)),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                child: const Text('home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
