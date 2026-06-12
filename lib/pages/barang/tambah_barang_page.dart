import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/category_model.dart';
import '../../models/ingredient_model.dart';
import '../../services/item_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_button.dart';

class TambahBarangPage extends StatefulWidget {
  final CategoryModel kategori;

  const TambahBarangPage({
    Key? key,
    required this.kategori,
  }) : super(key: key);

  @override
  State<TambahBarangPage> createState() =>
      _TambahBarangPageState();
}

class _TambahBarangPageState
    extends State<TambahBarangPage> {

  final kodeController =
      TextEditingController();

  final namaController =
      TextEditingController();

  final hargaController =
      TextEditingController();

  final ImagePicker picker =
      ImagePicker();

  File? foto;

  List<IngredientModel> ingredients = [];

  bool loading = false;

  Future<void> pilihFoto() async {
    final image =
        await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    setState(() {
      foto = File(image.path);
    });
  }

  void tambahBahan() {
    setState(() {
      ingredients.add(
        IngredientModel(
          kode: '',
          nama: '',
          stok: 1,
          satuan: 'gram',
        ),
      );
    });
  }

  Future<void> simpan() async {
    if (kodeController.text.isEmpty ||
        namaController.text.isEmpty ||
        hargaController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Semua field wajib diisi"),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    final success =
        await ItemService.createItem(
      kode: kodeController.text,
      nama: namaController.text,
      harga:
          int.parse(hargaController.text),
      kategoriId: widget.kategori.id,
      foto: foto,
      ingredients: ingredients,
    );

    setState(() {
      loading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Produk berhasil ditambahkan"),
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Gagal menambahkan produk"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Barang"),
        backgroundColor: AppColors.barang,
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [

            TextFormField(
              controller:
                  kodeController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Kode Produk",
              ),
            ),

            const SizedBox(height: 15),

            TextFormField(
              controller:
                  namaController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Nama Produk",
              ),
            ),

            const SizedBox(height: 15),

            TextFormField(
              controller:
                  hargaController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                labelText:
                    "Harga",
              ),
            ),

            const SizedBox(height: 15),

            TextFormField(
              enabled: false,
              initialValue:
                  widget.kategori.nama,
              decoration:
                  const InputDecoration(
                labelText:
                    "Kategori",
              ),
            ),

            const SizedBox(height: 20),

            InkWell(
              onTap: pilihFoto,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration:
                    BoxDecoration(
                  border:
                      Border.all(),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: foto == null
                    ? const Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          Icon(
                            Icons.image,
                            size: 50,
                          ),
                          SizedBox(
                              height: 8),
                          Text(
                            "Pilih Foto",
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                        child:
                            Image.file(
                          foto!,
                          fit:
                              BoxFit.cover,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                const Text(
                  "Bahan Baku",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                ElevatedButton.icon(
                  onPressed:
                      tambahBahan,
                  icon:
                      const Icon(
                    Icons.add,
                  ),
                  label:
                      const Text(
                    "Tambah",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ...ingredients
                .asMap()
                .entries
                .map((entry) {

              int index =
                  entry.key;

              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom: 12,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    10,
                  ),
                  child: Column(
                    children: [

                      TextFormField(
                        decoration:
                            const InputDecoration(
                          labelText:
                              "Kode Bahan",
                        ),
                        onChanged:
                            (v) {
                          ingredients[
                                  index]
                              .kode = v;
                        },
                      ),

                      TextFormField(
                        decoration:
                            const InputDecoration(
                          labelText:
                              "Nama Bahan",
                        ),
                        onChanged:
                            (v) {
                          ingredients[
                                  index]
                              .nama = v;
                        },
                      ),

                      TextFormField(
                        keyboardType:
                            TextInputType
                                .number,
                        decoration:
                            const InputDecoration(
                          labelText:
                              "Jumlah",
                        ),
                        onChanged:
                            (v) {
                          ingredients[
                                  index]
                              .stok =
                              int.tryParse(
                                    v,
                                  ) ??
                                  1;
                        },
                      ),

                      DropdownButtonFormField<
                          String>(
                        value:
                            ingredients[
                                    index]
                                .satuan,
                        items: const [

                          DropdownMenuItem(
                            value:
                                "gram",
                            child: Text(
                                "gram"),
                          ),

                          DropdownMenuItem(
                            value:
                                "ml",
                            child: Text(
                                "ml"),
                          ),

                          DropdownMenuItem(
                            value:
                                "pcs",
                            child: Text(
                                "pcs"),
                          ),
                        ],
                        onChanged:
                            (value) {
                          ingredients[
                                  index]
                              .satuan =
                              value!;
                        },
                      ),

                      const SizedBox(
                          height: 10),

                      ElevatedButton.icon(
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            ingredients.removeAt(
                                index);
                          });
                        },
                        icon:
                            const Icon(
                          Icons.delete,
                          color:
                              Colors.white,
                        ),
                        label:
                            const Text(
                          "Hapus",
                          style:
                              TextStyle(
                            color: Colors
                                .white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 25),

            SizedBox(
              width:
                  double.infinity,
              child: AppButton(
                label: "Simpan Produk",
                icon: Icons.check_circle_outline,
                loading: loading,
                color: AppColors.barang,
                onPressed: simpan,
              ),
            ),
          ],
        ),
      ),
    );
  }
}