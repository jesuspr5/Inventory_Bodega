import 'package:flutter/material.dart';
import '../db_helper.dart';

class ProductFormScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const ProductFormScreen({super.key, this.product});

  @override
  ProductFormScreenState createState() => ProductFormScreenState();
}

class ProductFormScreenState extends State<ProductFormScreen> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!['name'];
      _categoryController.text = widget.product!['category'];
      _quantityController.text = widget.product!['quantity'].toString();
      _priceController.text = widget.product!['price'].toString();
    }
  }

  Future<void> _saveProduct() async {
    final db = await DBHelper.instance.database;
    final newProduct = {
      'name': _nameController.text,
      'category': _categoryController.text,
      'quantity': int.parse(_quantityController.text),
      'price': double.parse(_priceController.text),
    };

    if (widget.product == null) {
      await db.insert('products', newProduct);
    } else {
      await db.update('products', newProduct,
          where: 'id = ?', whereArgs: [widget.product!['id']]);
    }

    // Verificamos si el widget sigue montado antes de navegar
    if (mounted) {
      Navigator.pop(context); // Solo navegar si el widget sigue montado
    }
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
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Categoría'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
