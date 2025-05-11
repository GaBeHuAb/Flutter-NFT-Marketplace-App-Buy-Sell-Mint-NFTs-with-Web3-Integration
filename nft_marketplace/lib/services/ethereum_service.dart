import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

class EthereumService {
  late Web3Client _client;
  late String _privateKey;
  late EthereumAddress _walletAddress;
  late DeployedContract _contract;
  late ContractFunction _listNFTFunction;
  late ContractFunction _bidFunction;
  late ContractFunction _getMarketNFTsFunction;
  late ContractFunction _transferNFTFunction;
  late ContractFunction _getOwnedNFTsFunction;

  bool isInitialized = false;

  EthereumAddress get walletAddress => _walletAddress;

  Future<bool> initialize(String privateKey) async {
    try {
      _privateKey = privateKey;
      final httpClient = http.Client();

      _client = Web3Client(dotenv.get("INFURA_SEPOLIA_URL"), httpClient);

      final credentials = EthPrivateKey.fromHex(_privateKey);
      _walletAddress = credentials.address;

      final abiJson =
          await rootBundle.loadString('assets/abi/NFTMarketplace.json');
      final contractAbi = ContractAbi.fromJson(abiJson, 'NFTMarketplace');

      _contract = DeployedContract(
          contractAbi, EthereumAddress.fromHex(dotenv.get("CONTRACT_ADDRESS")));

      _listNFTFunction = _contract.function('listNFT');
      _bidFunction = _contract.function('bid');
      _getMarketNFTsFunction = _contract.function('getMarketNFTs');
      _transferNFTFunction = _contract.function('transferNFT');
      _getOwnedNFTsFunction = _contract.function('getOwnedNFTs');

      isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('Error initializing Ethereum service: $e');
      return false;
    }
  }

  Future<EtherAmount> getBalance() async {
    if (!isInitialized) {
      throw Exception('EthereumService not initialized');
    }

    try {
      final balance = await _client.getBalance(_walletAddress);
      return balance;
    } catch (e) {
      debugPrint('Error getting wallet balance: $e');
      throw Exception('Failed to get wallet balance');
    }
  }

  Future<List<Map<String, dynamic>>> getMarketNFTs() async {
    try {
      final response = await _client.call(
        contract: _contract,
        function: _getMarketNFTsFunction,
        params: [],
      );

      final List<dynamic> nftsRaw = response[0];
      final List<Map<String, dynamic>> nfts = [];

      for (var nft in nftsRaw) {
        nfts.add({
          'listingId': nft[0],
          'tokenId': nft[1],
          'seller': nft[2].toString(),
          'title': nft[3],
          'imageUrl': nft[4],
          'price': nft[5],
          'highestBid': nft[6],
          'highestBidder': nft[7].toString(),
          'active': nft[8],
        });
      }

      return nfts;
    } catch (e) {
      debugPrint('Error loading marketplace NFTs: $e');
      return [];
    }
  }

  Future<String?> listNFT(
      String title, String imageUrl, String priceInWei) async {
    try {
      final credentials = EthPrivateKey.fromHex(_privateKey);
      final priceInBigInt = BigInt.parse(priceInWei);

      final transaction = Transaction.callContract(
        contract: _contract,
        function: _listNFTFunction,
        parameters: [
          title,
          imageUrl,
          priceInBigInt,
        ],
        from: _walletAddress,
      );

      final txHash = await _client.sendTransaction(
        credentials,
        transaction,
        chainId: dotenv.getInt("CHAIN_ID"),
      );

      return txHash;
    } catch (e) {
      debugPrint('Error listing NFT: $e');
      return null;
    }
  }

  Future<String?> placeBid(BigInt listingId, String bidAmountInWei) async {
    try {
      final credentials = EthPrivateKey.fromHex(_privateKey);
      final bidAmount = EtherAmount.fromBigInt(
        EtherUnit.wei,
        BigInt.parse(bidAmountInWei),
      );

      final transaction = Transaction.callContract(
        contract: _contract,
        function: _bidFunction,
        parameters: [listingId],
        from: _walletAddress,
        value: bidAmount,
      );

      final txHash = await _client.sendTransaction(
        credentials,
        transaction,
        chainId: dotenv.getInt("CHAIN_ID"),
      );

      debugPrint(txHash);

      return txHash;
    } catch (e) {
      debugPrint('Error placing bid: $e');
      return "Error: $e";
    }
  }

  Future<String?> transferNFT(BigInt listingId) async {
    try {
      final credentials = EthPrivateKey.fromHex(_privateKey);

      final transaction = Transaction.callContract(
        contract: _contract,
        function: _transferNFTFunction,
        parameters: [listingId],
        from: _walletAddress,
      );

      final txHash = await _client.sendTransaction(
        credentials,
        transaction,
        chainId: dotenv.getInt("CHAIN_ID"),
      );

      return txHash;
    } catch (e) {
      debugPrint('Error transferring NFT: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getOwnedNFTs() async {
    try {
      final response = await _client.call(
        contract: _contract,
        function: _getOwnedNFTsFunction,
        params: [],
      );

      print(response);
      final List<dynamic> nftsRaw = response[0];
      final List<Map<String, dynamic>> nfts = [];

      for (var nft in nftsRaw) {
        print(nft);
        nfts.add({
          'listingId': nft[0],
          'tokenId': nft[1],
          'seller': nft[2].toString(),
          'title': nft[3],
          'imageUrl': nft[4],
          'price': nft[5],
          'highestBid': nft[6],
          'highestBidder': nft[7].toString(),
          'active': nft[8],
        });
      }

      return nfts;
    } catch (e) {
      debugPrint('Error loading owned NFTs: $e');
      return [];
    }
  }

  void dispose() {
    _client.dispose();
  }
}
