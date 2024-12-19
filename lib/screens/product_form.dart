import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../db_helper.dart';

class ProductFormScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const ProductFormScreen({super.key, this.product});

  @override
  ProductFormScreenState createState() => ProductFormScreenState();
}

class ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String? _selectedCategory;
  List<String> _categories = [];
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!['name'];
      _priceController.text = widget.product!['price'].toString();
      _quantityController.text = widget.product!['quantity'].toString();
      _selectedCategory = widget.product!['category'];
      if (widget.product!['image'] != null) {
        _selectedImage = File(widget.product!['image']);
      }
    }
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final categories = await DBHelper.instance.getCategories();
    setState(() {
      _categories = categories.map((e) => e['name'] as String).toList();
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final product = {
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'quantity': int.parse(_quantityController.text),
        'category': _selectedCategory!,
        'image': _selectedImage?.path, // Guarda la ruta de la imagen
      };

      final db = await DBHelper.instance.database;

      if (widget.product == null) {
        // Agregar producto nuevo
        await db.insert('products', product);
      } else {
        // Editar producto existente
        await db.update(
          'products',
          product,
          where: 'id = ?',
          whereArgs: [widget.product!['id']],
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  Future<void> _addCategory(String newCategory) async {
    await DBHelper.instance.insertCategory(newCategory);
    _fetchCategories(); // Actualiza la lista
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.product == null ? 'Agregar Producto' : 'Editar Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration:
                      const InputDecoration(labelText: 'Nombre del producto'),
                  validator: (value) =>
                      value!.isEmpty ? 'Este campo es obligatorio' : null,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Este campo es obligatorio' : null,
                ),
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: 'Cantidad'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Este campo es obligatorio' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Seleccione una categoría' : null,
                ),
                const SizedBox(height: 16.0),
                _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      )
                    : const Text('No hay imagen seleccionada'),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Seleccionar Imagen'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_selectedCategory == null) {
                            final categoryController = TextEditingController();
                            showDialog(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Agregar Categoría'),
                                content: TextField(
                                  controller: categoryController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nueva categoría',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(dialogContext);
                                    },
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final currentContext = dialogContext;
                                      if (categoryController.text.isNotEmpty) {
                                        await _addCategory(
                                            categoryController.text);
                                        if (mounted) {
                                          // ignore: use_build_context_synchronously
                                          Navigator.pop(currentContext);
                                        }
                                      }
                                    },
                                    child: const Text('Guardar'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        child: const Text('Agregar Nueva Categoría'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _saveProduct,
                  child: const Text('Guardar Producto'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
