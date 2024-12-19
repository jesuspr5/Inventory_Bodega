import 'dart:io';
import 'package:flutter/material.dart';
import '../db_helper.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  ProductListScreenState createState() => ProductListScreenState();
}

class ProductListScreenState extends State<ProductListScreen> {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    final db = await DBHelper.instance.database;
    final products = await db.query('products');
    setState(() {
      _products = products;
      _filteredProducts =
          products; // Inicialmente, mostrar todos los productos.
    });
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((product) {
        final name = product['name'].toLowerCase();
        final category = product['category'].toLowerCase();
        return name.contains(query) || category.contains(query);
      }).toList();
    });
  }

  Future<void> _deleteProduct(int id) async {
    final db = await DBHelper.instance.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
    _fetchProducts(); // Actualizar la lista después de eliminar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Productos'),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_rounded),
            color: const Color.fromARGB(255, 255, 255, 255),
            onPressed: () async {
              await Navigator.pushNamed(context, '/addProduct');
              _fetchProducts(); // Refrescar la lista al regresar
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(child: Text('No hay productos'))
                : ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      final imagePath = product['image'] as String?;
                      return ListTile(
                        leading: imagePath != null && imagePath.isNotEmpty
                            ? Image.file(
                                File(imagePath),
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                              )
                            : const Icon(Icons.image_not_supported, size: 50),
                        title: Text(product['name']),
                        subtitle: Text(
                          '${product['category']}-'
                          'Precio: ${product['price']}Bs-'
                          'Cantidad: ${product['quantity']}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                await Navigator.pushNamed(
                                  context,
                                  '/editProduct',
                                  arguments: product,
                                );
                                _fetchProducts(); // Refrescar la lista
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteProduct(product['id']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
