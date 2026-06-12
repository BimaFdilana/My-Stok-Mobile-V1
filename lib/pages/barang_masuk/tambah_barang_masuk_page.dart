import 'package:flutter/material.dart';
import '../../services/barang_masuk_service.dart';
import '../../utils/app_theme.dart';

class TambahBarangMasukPage extends StatefulWidget {
  const TambahBarangMasukPage({super.key});

  @override
  State<TambahBarangMasukPage> createState() =>
      _TambahBarangMasukPageState();
}

class _TambahBarangMasukPageState
    extends State<TambahBarangMasukPage> {

  final jumlahController =
      TextEditingController();

  final tanggalController =
      TextEditingController();

  List ingredients = [];
  List categories = [];

  int? ingredientId;
  int? categoryId;

  String? satuan;

  bool loading = true;

@override
void initState() {
  super.initState();

  final now = DateTime.now();

  tanggalController.text =
      "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

  loadMasterData();
}

  Future loadMasterData() async {

    final ingredientData =
        await BarangMasukService.getIngredients();

    final categoryData =
        await BarangMasukService.getCategories();

    setState(() {

      ingredients = ingredientData;

      categories = categoryData;

      loading = false;
    });
  }

  Future simpan() async {

    if (ingredientId == null ||
        categoryId == null ||
        satuan == null ||
        jumlahController.text.isEmpty ||
        tanggalController.text.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Lengkapi data terlebih dahulu",
          ),
        ),
      );

      return;
    }

    bool berhasil =
        await BarangMasukService.addBarangMasuk(
      ingredientId: ingredientId!,
      categoryId: categoryId!,
      jumlah: jumlahController.text,
      tanggal: tanggalController.text,
      satuan: satuan!,
    );

    if (berhasil) {

      Navigator.pop(context);

    } else {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Gagal menyimpan data"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title:
            const Text("Tambah Barang Masuk"),
        backgroundColor: AppColors.barangMasuk,
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: ListView(

          children: [

            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: "Bahan",
              ),

              items: ingredients.map((item) {

                return DropdownMenuItem<int>(
                  value: item["id"],
                  child: Text(
                    "${item["nama"]} (${item["kode"]})",
                  ),
                );

              }).toList(),

              onChanged: (value) {
                ingredientId = value;
              },
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: "Kategori",
              ),

              items: categories.map((item) {

                return DropdownMenuItem<int>(
                  value: item["id"],
                  child: Text(
                    item["nama"],
                  ),
                );

              }).toList(),

              onChanged: (value) {
                categoryId = value;
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: jumlahController,
              keyboardType:
                  TextInputType.number,

              decoration:
                  const InputDecoration(
                labelText: "Jumlah",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
  controller: tanggalController,
  readOnly: true,
  decoration: const InputDecoration(
    labelText: "Tanggal",
    prefixIcon: Icon(Icons.calendar_today),
  ),
),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(

              decoration:
                  const InputDecoration(
                labelText: "Satuan",
              ),

              items: const [

                DropdownMenuItem(
                  value: "gram",
                  child: Text("gram"),
                ),

                DropdownMenuItem(
                  value: "ml",
                  child: Text("ml"),
                ),

                DropdownMenuItem(
                  
                  value: "pcs",
                  child: Text("pcs"),
                ),
              ],

              onChanged: (value) {
                satuan = value;
              },
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(

              onPressed: simpan,

              icon: const Icon(Icons.save),

              label:
                  const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }
}