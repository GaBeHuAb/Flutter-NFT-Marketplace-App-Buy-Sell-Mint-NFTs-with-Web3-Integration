import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import '../services/ethereum_service.dart';

class MarketplaceProvider extends ChangeNotifier {
  final EthereumService _ethereumService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  EtherAmount? _balance;
  EtherAmount? get balance => _balance;

  bool _isBidPlaceLoading = false;
  bool get isBidPlaceLoading => _isBidPlaceLoading;
  set isBidPlaceLoading(bool value) {
    _isBidPlaceLoading = value;
    notifyListeners();
  }

  List<Map<String, dynamic>> marketNFTs = [];
  List<Map<String, dynamic>> myNFTs = [];
  MarketplaceProvider(this._ethereumService);

  getBalance() async {
    _balance = await _ethereumService.getBalance();
    notifyListeners();
  }

  Future<void> loadMarketNFTs(String address) async {
    marketNFTs.clear();
    myNFTs.clear();
    _isLoading = true;
    notifyListeners();
    try {
      final nfts = await _ethereumService.getMarketNFTs();
      for (var e in nfts) {
        print(e);
        if (e['seller'].toLowerCase() == address.toLowerCase()) {
          myNFTs.add(e);
        } else {
          marketNFTs.add(e);
        }
      }
    } catch (e) {
      debugPrint('Error loading marketplace NFTs: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> placeBid(BigInt listingId, String amount) async {
    try {
      return await _ethereumService.placeBid(listingId, amount);
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> finalizeTransfer(BigInt listingId) async {
    try {
      return await _ethereumService.transferNFT(listingId);
    } catch (e) {
      return e.toString();
    }
  }
}
