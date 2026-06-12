import '../../utils/app_theme.dart';
import '../../utils/currency.dart';
import 'package:flutter/material.dart';
import '../../models/kasir_model.dart';
import '../../services/kasir_service.dart';
import '../../services/qris_service.dart';
import '../../utils/responsive.dart';
import '../../config/api.dart';
import 'receipt_page.dart';

class PembayaranPage extends StatefulWidget {
  final List<KasirItem> items;
  final int total;

  const PembayaranPage({
    super.key,
    required this.items,
    required this.total,
  });

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  String selectedMethod = 'cash';
  final TextEditingController _nominalController = TextEditingController();
  bool isProcessing = false;
  Map<String, dynamic>? qrisData;
  bool loadingQris = false;

  @override
  void initState() {
    super.initState();
    _nominalController.text = widget.total.toString();
    _nominalController.addListener(_onNominalChanged);
  }

  int get _kembalian {
    final amount = int.tryParse(_nominalController.text) ?? 0;
    return amount - widget.total;
  }

  void _onNominalChanged() => setState(() {});

  void _showQrFullScreen(String imageUrl) {
    final size = MediaQuery.of(context).size;
    final maxImg = (size.height < size.width ? size.height : size.width) * 0.78;
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.pop(ctx),
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: GestureDetector(
                  onTap: () {}, // prevent inner tap from closing
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (qrisData?['nama_merchant'] != null) ...[
                            Text(
                              qrisData!['nama_merchant'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: maxImg,
                              maxHeight: maxImg,
                            ),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Padding(
                                padding: EdgeInsets.all(40),
                                child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadQris() async {
    setState(() => loadingQris = true);
    final data = await QrisService.getActiveQris();
    setState(() {
      qrisData = data;
      loadingQris = false;
    });
  }

  Future<void> processPayment() async {
    final amount = int.tryParse(_nominalController.text) ?? 0;

    if (selectedMethod == 'cash' && amount < widget.total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal kurang dari total')),
      );
      return;
    }

    setState(() => isProcessing = true);

    final result = await KasirService.checkout(
      items: widget.items,
      paymentMethod: selectedMethod,
      paymentAmount: selectedMethod == 'qris' ? widget.total : amount,
    );

    setState(() => isProcessing = false);

    if (result['success'] == true) {
      if (mounted) {
        final change = (result['change'] is num)
            ? (result['change'] as num).toInt()
            : int.tryParse(result['change'].toString()) ?? 0;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ReceiptPage(
              transactionId: result['transaction_id'],
              total: widget.total,
              paymentMethod: selectedMethod,
              paymentAmount: selectedMethod == 'qris' ? widget.total : amount,
              change: change,
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal checkout')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pembayaran', style: TextStyle(fontSize: responsive.appBarFontSize)),
        backgroundColor: AppColors.kasir,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: responsive.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 18)),
                    Text(
                      formatRupiah(widget.total),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.kasir,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Metode Pembayaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedMethod = 'cash'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedMethod == 'cash'
                              ? AppColors.kasir
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: selectedMethod == 'cash'
                            ? AppColors.kasir.withValues(alpha: 0.05)
                            : null,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.money,
                            size: 36,
                            color: selectedMethod == 'cash'
                                ? AppColors.kasir
                                : Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tunai',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedMethod == 'cash'
                                  ? AppColors.kasir
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => selectedMethod = 'qris');
                      if (qrisData == null) loadQris();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedMethod == 'qris'
                              ? AppColors.kasir
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: selectedMethod == 'qris'
                            ? AppColors.kasir.withValues(alpha: 0.05)
                            : null,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.qr_code,
                            size: 36,
                            color: selectedMethod == 'qris'
                                ? AppColors.kasir
                                : Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'QRIS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedMethod == 'qris'
                                  ? AppColors.kasir
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (selectedMethod == 'cash') ...[
              const Text(
                'Nominal Bayar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nominalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _kembalian >= 0
                      ? AppColors.success.withValues(alpha: 0.08)
                      : AppColors.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _kembalian >= 0 ? AppColors.success : AppColors.danger,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _kembalian >= 0 ? 'Kembalian' : 'Kurang',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _kembalian >= 0 ? AppColors.success : AppColors.danger,
                      ),
                    ),
                    Text(
                      formatRupiah(_kembalian.abs()),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _kembalian >= 0 ? AppColors.success : AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (selectedMethod == 'qris') ...[
              const SizedBox(height: 10),
              if (loadingQris)
                const Center(child: CircularProgressIndicator())
              else if (qrisData != null)
                Center(
                  child: Column(
                    children: [
                      Text(
                        qrisData!['nama_merchant'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showQrFullScreen(
                          Api.storageUrl(qrisData!['foto']) ?? '',
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            Api.storageUrl(qrisData!['foto']) ?? '',
                            width: 250,
                            height: 250,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Icon(Icons.broken_image, size: 60, color: AppColors.textMuted),
                                  SizedBox(height: 8),
                                  Text('Gagal memuat QR'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.zoom_in, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Ketuk QR untuk memperbesar',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                      if (qrisData!['keterangan'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          qrisData!['keterangan'],
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                )
              else
                const Center(
                  child: Text('Tidak ada QRIS aktif. Hubungi admin.'),
                ),
            ],
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isProcessing ? null : processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kasir,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Proses Pembayaran',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }
}
