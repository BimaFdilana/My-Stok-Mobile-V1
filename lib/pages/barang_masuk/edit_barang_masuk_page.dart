import 'package:flutter/material.dart';
import '../../services/barang_masuk_service.dart';
import '../../utils/app_theme.dart';

class EditBarangMasukPage extends StatefulWidget {

  final int stockId;

  const EditBarangMasukPage({
    super.key,
    required this.stockId,
  });

  @override
  State<EditBarangMasukPage> createState() =>
      _EditBarangMasukPageState();
}

class _EditBarangMasukPageState
    extends State<EditBarangMasukPage> {

  List ingredients = [];
  List categories = [];

  int? ingredientId;
  int? categoryId;

  String? satuan;

  bool loading = true;

  final jumlahController =
      TextEditingController();

  final tanggalController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async {

    final ingredientData =
        await BarangMasukService.getIngredients();

    final categoryData =
        await BarangMasukService.getCategories();

    final stock =
        await BarangMasukService.getBarangMasukDetail(
      widget.stockId,
    );

    setState(() {

      ingredients = ingredientData;
      categories = categoryData;

      ingredientId =
          stock["ingredient_id"];

      categoryId =
          stock["category_id"];

      satuan =
          stock["satuan"];

      jumlahController.text =
          stock["jumlah"].toString();

      tanggalController.text =
          stock["tanggal"]
              .toString()
              .substring(0, 10);

      loading = false;
    });
  }

  Future simpan() async {

    bool berhasil =
        await BarangMasukService.updateBarangMasuk(
      id: widget.stockId,
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
          content: Text(
            "Gagal update data",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {

      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title:
            const Text("Edit Barang Masuk"),
        backgroundColor: AppColors.barangMasuk,
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(16),

        child: ListView(
          children: [

            DropdownButtonFormField<int>(
              value: ingredientId,

              decoration:
                  const InputDecoration(
                labelText: "Bahan",
              ),

              items: ingredients.map<DropdownMenuItem<int>>((item) {

  return DropdownMenuItem<int>(
    value: item["id"] as int,
    child: Text(
      item["nama"].toString(),
    ),
  );

}).toList(),

              onChanged: (value) {
                ingredientId = value;
              },
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<int>(
              value: categoryId,

              decoration:
                  const InputDecoration(
                labelText: "Kategori",
              ),

              items: categories.map<DropdownMenuItem<int>>((item) {

  return DropdownMenuItem<int>(
    value: item["id"] as int,
    child: Text(
      item["nama"].toString(),
    ),
  );

}).toList(),

              onChanged: (value) {
                categoryId = value;
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  jumlahController,

              keyboardType:
                  TextInputType.number,

              decoration:
                  const InputDecoration(
                labelText: "Jumlah",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  tanggalController,

              decoration:
                  const InputDecoration(
                labelText: "Tanggal",
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: satuan,

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

            const SizedBox(height: 25),

            ElevatedButton.icon(
              onPressed: simpan,
              icon:
                  const Icon(Icons.save),
              label: const Text(
                "Update Data",
              ),
            ),
          ],
        ),
      ),
    );
  }
}