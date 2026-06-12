import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool hidePassword = true;

  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();
  }

  Future<void> login() async {
    setState(() => isLoading = true);
    try {
      final data = await AuthService.login(
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (!mounted) return;
      setState(() => isLoading = false);

      if (data['success'] == true) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showSnack(data['message'] ?? data['error'] ?? "Login gagal", AppColors.danger);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showSnack("Error: $e", AppColors.danger);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    usernameController.dispose();
    passwordController.dispose();
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
                constraints: const BoxConstraints(maxWidth: 440),
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Column(
                      children: [
                        // Brand
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: AppShadow.md,
                          ),
                          child: const Icon(Icons.storefront,
                              size: 44, color: AppColors.primary),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "MyStok",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Masuk untuk melanjutkan",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Form card
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            boxShadow: AppShadow.md,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Username",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: usernameController,
                                decoration: const InputDecoration(
                                  hintText: "Masukkan username",
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text("Kata Sandi",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: passwordController,
                                obscureText: hidePassword,
                                onSubmitted: (_) => login(),
                                decoration: InputDecoration(
                                  hintText: "Masukkan kata sandi",
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(hidePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined),
                                    onPressed: () => setState(
                                        () => hidePassword = !hidePassword),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              AppButton(
                                label: "Masuk",
                                icon: Icons.login,
                                loading: isLoading,
                                onPressed: login,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     Text("Belum punya akun? ",
                        //         style: TextStyle(
                        //             color: Colors.white.withValues(alpha: 0.9))),
                        //     GestureDetector(
                        //       onTap: () =>
                        //           Navigator.pushNamed(context, '/register'),
                        //       child: const Text(
                        //         "Daftar",
                        //         style: TextStyle(
                        //           color: Colors.white,
                        //           fontWeight: FontWeight.w700,
                        //           decoration: TextDecoration.underline,
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
