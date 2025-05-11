import 'package:flutter/material.dart';
import '../services/ethereum_service.dart';

class CreateNftProvider extends ChangeNotifier {
  final EthereumService _ethereumService;
  bool _isLoading = false;

  CreateNftProvider(this._ethereumService);

  bool get isLoading => _isLoading;

  Future<String?> createNFT(
    String title,
    String imageUrl,
    String price,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final txHash = await _ethereumService.listNFT(
        title,
        imageUrl,
        price,
      );
      
      return txHash;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}