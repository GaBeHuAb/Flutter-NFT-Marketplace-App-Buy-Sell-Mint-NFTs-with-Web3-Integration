import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import '../services/ethereum_service.dart';

class WalletConnectProvider extends ChangeNotifier {
  final EthereumService _ethereumService;
  bool _isLoading = false;
  EthereumAddress? _walletAddress;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  EthereumAddress? get walletAddress => _walletAddress;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _walletAddress != null;

  bool _obscureText = true;
  bool get obscureText => _obscureText;
  set obscureText(bool value) {
    _obscureText = value;
    notifyListeners();
  }

  WalletConnectProvider(this._ethereumService);

  Future<bool> connectWallet(String privateKey) async {
    if (privateKey.isEmpty) {
      _errorMessage = 'Private key cannot be empty';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _ethereumService.initialize(privateKey);

      if (success) {
        _walletAddress = _ethereumService.walletAddress;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to connect wallet';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void disconnectWallet() {
    _walletAddress = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
