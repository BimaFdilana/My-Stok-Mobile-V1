import '../../utils/app_theme.dart';
import '../../utils/currency.dart';
import 'package:flutter/material.dart';
import '../../services/kasir_service.dart';
import '../../utils/responsive.dart';

class ReceiptPage extends StatefulWidget {
  final int transactionId;
  final int total;
  final String paymentMethod;
  final int paymentAmount;
  final int change;

  const ReceiptPage({
    super.key,
    required this.transactionId,
    required this.total,
    required this.paymentMethod,
    required this.paymentAmount,
    required this.change,
  });

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  Map<String, dynamic>? receiptData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReceipt();
  }

  Future<void> loadReceipt() async {
    try {
      final data = await KasirService.getReceipt(widget.transactionId);
      setState(() {
        receiptData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Struk Pembayaran', style: TextStyle(fontSize: responsive.appBarFontSize)),
        backgroundColor: AppColors.kasir,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: SingleChildScrollView(
                  padding: responsive.pagePadding,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 60,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Pembayaran Berhasil!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#${widget.transactionId}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const Divider(height: 30),
                      if (receiptData != null && receiptData!['items'] != null)
                        ...List.generate(
                          (receiptData!['items'] as List).length,
                          (i) {
                            final item = receiptData!['items'][i];
                            final totalPrice = num.tryParse(item['total_price'].toString()) ?? 0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item['nama']} x${item['quantity']}',
                                    ),
                                  ),
                                  Text(
                                    formatRupiah(totalPrice),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      const Divider(height: 30),
                      _buildRow('Total', formatRupiah(widget.total)),
                      const SizedBox(height: 6),
                      _buildRow(
                        'Metode',
                        widget.paymentMethod == 'cash' ? 'Tunai' : 'QRIS',
                      ),
                      const SizedBox(height: 6),
                      _buildRow(
                        'Bayar',
                        formatRupiah(widget.paymentAmount),
                      ),
                      if (widget.paymentMethod == 'cash') ...[
                        const SizedBox(height: 6),
                        _buildRow(
                          'Kembalian',
                          formatRupiah(widget.change),
                        ),
                      ],
                      const SizedBox(height: 6),
                      if (receiptData != null && receiptData!['tanggal'] != null)
                        _buildRow('Waktu', receiptData!['tanggal']),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.popUntil(context, (route) => route.isFirst);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.kasir,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Kembali ke Menu',
                            style: TextStyle(color: Colors.white, fontSize: 16),
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
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
