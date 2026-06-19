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
  String? errorMessage; 

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
    setState(() {
      isLoading = true;
      errorMessage = null; 
    });

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
        setState(() {
          errorMessage = data['message'] ?? data['error'] ?? "Login gagal";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = "Error: $e";
      });
    }
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
                        // 1. BRAND SECTION 
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: AppShadow.md,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/img/logo4.png', 
                              fit: BoxFit.scaleDown,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.storefront, size: 40, color: AppColors.primary);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "MyStock", 
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Kelola stok, transaksi, dan laporan usaha Anda dengan mudah dan cepat.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.85), // Perbaikan: menggunakan .withOpacity
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 2. FORM CARD PANEL 
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            boxShadow: AppShadow.md,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Selamat Datang",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Masuk ke akun Anda untuk melanjutkan",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // ERROR ALERT (Perbaikan: Format Hex Color yang valid)
                              if (errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2), // Soft red (0xFF + Hex)
                                    border: Border.all(color: const Color(0xFFFCA5A5)), // Light red border
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline, color: Color(0xFFB91C1C), size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          errorMessage!,
                                          style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // FIELD USERNAME
                              const Text(
                                "Username",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: usernameController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  hintText: "Masukkan username",
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // FIELD KATA SANDI
                              const Text(
                                "Kata Sandi",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
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
                              const SizedBox(height: 28),

                              // TOMBOL MASUK
                              AppButton(
                                label: "Masuk",
                                icon: Icons.login,
                                loading: isLoading,
                                onPressed: login,
                              ),
                            ],
                          ),
                        ),
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