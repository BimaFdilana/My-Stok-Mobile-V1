import 'package:flutter/material.dart';
import '../../services/session_service.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final data = await SessionService.getUser();
    if (!mounted) return;
    setState(() {
      user = data;
      isLoading = false;
    });
  }

  Future<void> logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final avatarRadius = r.value<double>(mobile: 48, tablet: 58, desktop: 66);

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.profile))
          : RefreshIndicator(
              color: AppColors.profile,
              onRefresh: loadUser,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: Column(
                  children: [
                    // Header gradient
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 56, bottom: 30),
                      decoration: BoxDecoration(
                        gradient: AppGradients.of(AppColors.profile),
                        boxShadow: AppShadow.colored(AppColors.profile),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: avatarRadius,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  user?['foto'] != null ? NetworkImage(user!['foto']) : null,
                              child: user?['foto'] == null
                                  ? Icon(Icons.person, size: avatarRadius, color: AppColors.profile)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            user?['name'] ?? '-',
                            style: TextStyle(
                              fontSize: r.cardFontTitle + 4,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '@${user?['username'] ?? '-'}',
                            style: TextStyle(
                              fontSize: r.cardFontBody,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Padding(
                          padding: EdgeInsets.all(r.horizontalPadding),
                          child: Column(
                            children: [
                              _infoCard(),
                              const SizedBox(height: 24),
                              AppButton(
                                label: 'Keluar',
                                icon: Icons.logout,
                                variant: AppBtnVariant.danger,
                                onPressed: logout,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _infoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadow.sm,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          _infoRow(Icons.store_rounded, 'Nama Pemilik', user?['nama_pemilik'] ?? '-', AppColors.barangMasuk),
          const Divider(height: 1),
          _infoRow(Icons.email_rounded, 'Email', user?['email'] ?? '-', AppColors.info),
          const Divider(height: 1),
          _infoRow(Icons.account_circle_rounded, 'Username', user?['username'] ?? '-', AppColors.barang),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
