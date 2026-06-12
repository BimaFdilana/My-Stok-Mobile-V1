import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_button.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final namaPemilikController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  Future register() async {
    if (passwordController.text != confirmPasswordController.text) {
      _showSnack("Password tidak sama", AppColors.danger);
      return;
    }

    setState(() => isLoading = true);

    try {
      final data = await AuthService.register(
        name: nameController.text,
        namaPemilik: namaPemilikController.text,
        username: usernameController.text,
        email: emailController.text,
        password: passwordController.text,
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      _showSnack(
        data['message'] ?? 'Registrasi selesai',
        data['success'] == true ? AppColors.success : AppColors.danger,
      );

      if (data['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showSnack(e.toString(), AppColors.danger);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    namaPemilikController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.primary),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppShadow.md,
                      ),
                      child: const Icon(Icons.person_add_alt_1,
                          size: 38, color: AppColors.primary),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "Buat Akun",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Daftarkan usaha Anda",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.85)),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: AppShadow.md,
                      ),
                      child: Column(
                        children: [
                          _field(nameController, "Nama Usaha", Icons.store_outlined),
                          const SizedBox(height: 14),
                          _field(namaPemilikController, "Nama Pemilik", Icons.person_outline),
                          const SizedBox(height: 14),
                          _field(usernameController, "Username", Icons.alternate_email),
                          const SizedBox(height: 14),
                          _field(emailController, "Email", Icons.email_outlined,
                              keyboard: TextInputType.emailAddress),
                          const SizedBox(height: 14),
                          _passField(passwordController, "Password", hidePassword,
                              () => setState(() => hidePassword = !hidePassword)),
                          const SizedBox(height: 14),
                          _passField(confirmPasswordController, "Konfirmasi Password",
                              hideConfirmPassword,
                              () => setState(() =>
                                  hideConfirmPassword = !hideConfirmPassword)),
                          const SizedBox(height: 24),
                          AppButton(
                            label: "Daftar",
                            icon: Icons.person_add,
                            loading: isLoading,
                            onPressed: register,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Sudah punya akun? ",
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9))),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                          ),
                          child: const Text(
                            "Masuk",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon,
      {TextInputType? keyboard}) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _passField(TextEditingController c, String hint, bool hidden,
      VoidCallback toggle) {
    return TextField(
      controller: c,
      obscureText: hidden,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(hidden
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined),
          onPressed: toggle,
        ),
      ),
    );
  }
}
