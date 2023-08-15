import 'package:flutter/material.dart';
import 'package:productos/models/models.dart';

class ProductFormProvider extends ChangeNotifier {
  ProductFormProvider(this.product);
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late Product product;

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  void updateAvailability({bool? value}) {
    if (value != null) product.available = value;
    notifyListeners();
  }
}
