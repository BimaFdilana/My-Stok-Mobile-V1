import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/item_model.dart';
import '../../models/ingredient_model.dart';
import '../../services/item_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_button.dart';

class EditBarangPage extends StatefulWidget {

  final ItemModel item;

  const EditBarangPage({
    super.key,
    required this.item,
  });

  @override
  State<EditBarangPage> createState()
      => _EditBarangPageState();
}

class _EditBarangPageState
    extends State<EditBarangPage> {

  late TextEditingController kodeC;
  late TextEditingController namaC;
  late TextEditingController hargaC;

  List<IngredientModel> ingredients = [];

  File? foto;

  @override
  void initState() {
    super.initState();

    kodeC =
        TextEditingController(
            text: widget.item.kode);

    namaC =
        TextEditingController(
            text: widget.item.nama);

    hargaC =
        TextEditingController(
            text:
                widget.item.harga.toString());

    ingredients =
        List.from(widget.item.ingredients);
  }

  Future<void> pilihFoto() async {

    final picked =
        await ImagePicker()
            .pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {

      setState(() {
        foto = File(picked.path);
      });
    }
  }

  Future<void> updateProduk() async {

    final success =
        await ItemService.updateItem(
      id: widget.item.id,
      kode: kodeC.text,
      nama: namaC.text,
      harga: int.parse(hargaC.text),
      foto: foto,
      ingredients: ingredients,
    );

    if (!mounted) return;

    if (success) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Produk berhasil diperbarui",
          ),
        ),
      );

      Navigator.pop(context, true);

    } else {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Gagal memperbarui produk",
          ),
        ),
      );
    }
  }

void tambahIngredient() {
  setState(() {
    ingredients.add(
      IngredientModel(
        kode: "",
        nama: "",
        stok: 0,
        satuan: "gram",
      ),
    );
  });
}

void hapusIngredient(int index) {
  setState(() {
    ingredients.removeAt(index);
  });
} 


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Edit Produk",
        ),
        backgroundColor: AppColors.barang,
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(
              controller: kodeC,
              decoration:
                  const InputDecoration(
                labelText: "Kode",
              ),
            ),
const SizedBox(height: 20),

Row(
  mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
  children: [

    const Text(
      "Bahan Baku",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),

    ElevatedButton.icon(
      onPressed: tambahIngredient,
      icon: const Icon(Icons.add),
      label: const Text("Tambah"),
    ),
  ],
),

const SizedBox(height: 10),

ListView.builder(
  shrinkWrap: true,
  physics:
      const NeverScrollableScrollPhysics(),
  itemCount: ingredients.length,
  itemBuilder: (context, index) {

    final ingredient =
        ingredients[index];

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(12),

        child: Column(
          children: [

            TextFormField(
              initialValue:
                  ingredient.kode,
              decoration:
                  const InputDecoration(
                labelText: "Kode",
              ),
              onChanged: (value) {
                ingredient.kode =
                    value;
              },
            ),

            const SizedBox(height: 10),

            TextFormField(
              initialValue:
                  ingredient.nama,
              decoration:
                  const InputDecoration(
                labelText: "Nama",
              ),
              onChanged: (value) {
                ingredient.nama =
                    value;
              },
            ),

            const SizedBox(height: 10),

            TextFormField(
              initialValue:
                  ingredient.stok
                      .toString(),
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                labelText: "stok",
              ),
              onChanged: (value) {
                ingredient.stok =
                    int.tryParse(
                          value,
                        ) ??
                        0;
              },
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<
                String>(
              value:
                  ingredient.satuan,

              items: const [

                DropdownMenuItem(
                  value: "gram",
                  child:
                      Text("gram"),
                ),

                DropdownMenuItem(
                  value: "ml",
                  child:
                      Text("ml"),
                ),

                DropdownMenuItem(
                  value: "pcs",
                  child:
                      Text("pcs"),
                ),
              ],

              onChanged: (value) {
                setState(() {
                  ingredient.satuan =
                      value!;
                });
              },
            ),

            const SizedBox(height: 10),

            Align(
              alignment:
                  Alignment.centerRight,
              child: IconButton(
                onPressed: () {
                  hapusIngredient(
                    index,
                  );
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  },
),

const SizedBox(height: 20),

SizedBox(
  width: double.infinity,
  child: AppButton(
    label: "Update Produk",
    icon: Icons.check_circle_outline,
    color: AppColors.barang,
    onPressed: updateProduk,
  ),
),
          ],
        ),
      ),
    );
  }
}
           