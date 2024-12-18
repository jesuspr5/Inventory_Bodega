import 'package:flutter/material.dart';
import '../db_helper.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  ProductListScreenState createState() => ProductListScreenState();
}

class ProductListScreenState extends State<ProductListScreen> {
  List<Map<String, dynamic>> _products = [];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final db = await DBHelper.instance.database;
    final result = _selectedCategory == null
        ? await db.query('products')
        : await db.query(
            'products',
            where: 'category = ?',
            whereArgs: [_selectedCategory],
          );
    setState(() {
      _products = result;
    });
  }

  Future<List<String>> _fetchCategories() async {
    final db = await DBHelper.instance.database;
    final result = await db.rawQuery('SELECT DISTINCT category FROM products');
    return result.map((row) => row['category'] as String).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/addProduct')
                  .then((_) => _fetchProducts());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          FutureBuilder<List<String>>(
            future: _fetchCategories(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              return DropdownButton<String>(
                hint: const Text('Filtrar por categoría'),
                value: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                  _fetchProducts();
                },
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('todos los productos'),
                  ),
                  ...snapshot.data!.map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  ),
                ],
              );
            },
          ),
          Expanded(
            child: _products.isEmpty
                ? const Center(child: Text('No hay productos registrados.'))
                : ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return ListTile(
                        title: Text(product['name']),
                        subtitle: Text(
                            'Categoría: ${product['category']} - Cantidad: ${product['quantity']} - Precio: \$${product['price']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final db = await DBHelper.instance.database;
                            await db.delete('products',
                                where: 'id = ?', whereArgs: [product['id']]);
                            _fetchProducts();
                          },
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/editProduct',
                                  arguments: product)
                              .then((_) => _fetchProducts());
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
