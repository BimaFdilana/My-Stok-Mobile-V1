import '../../utils/app_theme.dart';
import '../../utils/currency.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/laporan_service.dart';
import '../../utils/responsive.dart';

class LaporanTransaksiPage extends StatefulWidget {
  const LaporanTransaksiPage({super.key});

  @override
  State<LaporanTransaksiPage> createState() => _LaporanTransaksiPageState();
}

class _LaporanTransaksiPageState extends State<LaporanTransaksiPage> {
  DateTime tanggal = DateTime.now();
  Map<String, dynamic>? laporan;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      final result = await LaporanService.getTransaksi(
        tanggal: DateFormat('yyyy-MM-dd').format(tanggal),
      );
      setState(() {
        laporan = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => tanggal = picked);
      loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cf = NumberFormat('#,###', 'id_ID');
    final df = DateFormat('dd MMM yyyy');
    final responsive = Responsive(context);

    final summary = laporan?['summary'] ?? {};
    final data = (laporan?['data'] ?? []) as List;

    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan Transaksi', style: TextStyle(fontSize: responsive.appBarFontSize)),
        backgroundColor: AppColors.transaksi,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(responsive.horizontalPadding),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text('Tanggal: ${df.format(tanggal)}'),
                  onPressed: pickDate,
                ),
              ),
              if (laporan != null && !isLoading)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _summaryCard('Tunai', formatRupiah(summary['total_tunai'] ?? 0), Colors.green, Icons.money),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _summaryCard('QRIS', formatRupiah(summary['total_qris'] ?? 0), Colors.blue, Icons.qr_code),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _summaryCard(
                        'Total Pemasukan (${summary['jumlah_transaksi'] ?? 0} transaksi)',
                        formatRupiah(summary['grand_total'] ?? 0),
                        AppColors.transaksi,
                        Icons.account_balance_wallet,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : data.isEmpty
                        ? const Center(child: Text('Tidak ada transaksi'))
                        : responsive.isTablet
                            ? _buildGridList(data, cf, responsive)
                            : _buildListView(data, cf, responsive),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView(List data, NumberFormat cf, Responsive responsive) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
      itemCount: data.length,
      itemBuilder: (context, index) => _buildTrxCard(data[index], cf),
    );
  }

  Widget _buildGridList(List data, NumberFormat cf, Responsive responsive) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) => _buildTrxCard(data[index], cf),
    );
  }

  Widget _buildTrxCard(Map<String, dynamic> trx, NumberFormat cf) {
    final method = trx['payment_method'] ?? '-';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: method == 'qris' ? Colors.blue : Colors.green,
          child: Icon(method == 'qris' ? Icons.qr_code : Icons.money, color: Colors.white, size: 20),
        ),
        title: Text('Trx #${trx['id']} - ${trx['waktu']}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${(trx['items'] as List).length} item - ${method.toUpperCase()}'),
        trailing: Text(formatRupiah(trx['total']),
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.transaksi)),
      ),
    );
  }

  Widget _summaryCard(String label, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
