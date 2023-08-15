import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ProductsService extends ChangeNotifier {
  final String _baseUrl =
      'flutter-varios-5b527-default-rtdb.europe-west1.firebasedatabase.app';

  final List<Product> products = [];
  late Product _selectedProduct;

  final _storage = const FlutterSecureStorage();

  bool isLoading = true;

  bool isSaving = false;

  File? newPicture;

  Product get selectedProduct => _selectedProduct;
  set selectedProduct(Product value) {
    _selectedProduct = value;
    notifyListeners();
  }

  ProductsService() {
    loadProducts();
  }

  Future<List<Product>> loadProducts() async {
    final url = Uri.https(
      _baseUrl,
      'products.json',
      {'auth': await _storage.read(key: 'token') ?? ''},
    );

    final response = await http.get(url);

    final Map<String, dynamic> productsMap = json.decode(response.body);

    productsMap.forEach((key, value) {
      final tempProduct = Product.fromMap(value);
      tempProduct.id = key;
      products.add(tempProduct);
    });

    isLoading = false;
    notifyListeners();

    return products;
  }

  Future saveOrUpdateProduct(Product product) async {
    isSaving = true;
    notifyListeners();
    if (product.id == null) {
      await createProduct(product);
    } else {
      await updateProduct(product);
    }

    isSaving = false;
    notifyListeners();
  }

  Future updateProduct(Product product) async {
    final url = Uri.https(
      _baseUrl,
      'products/${product.id}.json',
      {'auth': await _storage.read(key: 'token') ?? ''},
    );

    await http.put(url, body: product.toJson());

    products[products.indexWhere((element) => element.id == product.id)] =
        product;
  }

  Future createProduct(Product product) async {
    final url = Uri.https(
      _baseUrl,
      'products.json',
      {'auth': await _storage.read(key: 'token') ?? ''},
    );

    final response = await http.post(url, body: product.toJson());

    final Map decodedData = json.decode(response.body);

    product.id = decodedData['name'];

    products.add(product);
  }

  void updateSelectedProductImage(String? path) {
    if (path == null) return;

    selectedProduct.picture = path;
    newPicture = File.fromUri(Uri(path: path));

    notifyListeners();
  }

  Future<String?> uploadImage() async {
    if (newPicture == null) return null;

    isSaving = true;
    notifyListeners();

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/dgtcmpysk/image/upload?upload_preset=jjpgcfmm',
    );

    final imageUploadRequest = http.MultipartRequest(
      'POST',
      url,
    );

    final file = await http.MultipartFile.fromPath('file', newPicture!.path);

    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      return null;
    }

    newPicture = null;

    final Map decodedData = json.decode(resp.body);
    return decodedData['secure_url'];
  }
}
