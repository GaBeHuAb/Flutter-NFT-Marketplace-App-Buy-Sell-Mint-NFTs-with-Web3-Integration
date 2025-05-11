import 'package:bmprogresshud/progresshud.dart';
import 'package:flutter/material.dart';
import 'package:nft_marketplace/core/constants/functions.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';
import '../providers/marketplace_provider.dart';
import 'my_nfts_screen.dart';
import 'create_nft_screen.dart';
import '../widgets/nft_card.dart';

class MarketplaceScreen extends StatefulWidget {
  final EthereumAddress walletAddress;

  const MarketplaceScreen({super.key, required this.walletAddress});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<MarketplaceProvider>()
          .loadMarketNFTs(widget.walletAddress.hex);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketplaceProvider>(
      builder: (context, marketplaceProvider, _) {
        // Filter NFTs based on search query
        final filteredNFTs = marketplaceProvider.marketNFTs.where((nft) {
          return nft['title']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: const Color(0xFF121212),
            title: const Text(
              'NFT Marketplace',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
                tooltip: _isGridView ? 'List View' : 'Grid View',
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => marketplaceProvider
                    .loadMarketNFTs(widget.walletAddress.hex),
                tooltip: 'Refresh',
              ),
              IconButton(
                icon: const Icon(Icons.account_circle_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyNFTsScreen(
                        walletAddress: widget.walletAddress,
                      ),
                    ),
                  );
                },
                tooltip: 'My NFTs',
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search NFTs...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Expanded(
                child: _buildNFTList(marketplaceProvider, filteredNFTs),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateNFTScreen(),
                ),
              ).then((_) async {
                marketplaceProvider.loadMarketNFTs(widget.walletAddress.hex);
              });
            },
            tooltip: 'Create NFT',
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildNFTList(MarketplaceProvider marketplaceProvider,
      List<Map<String, dynamic>> nfts) {
    if (marketplaceProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (nfts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No NFTs available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            if (_searchQuery.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
                child: const Text('Clear search'),
              ),
          ],
        ),
      );
    }

    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: nfts.length,
        itemBuilder: (context, index) {
          final nft = nfts[index];
          final isOwner = nft['seller'].toLowerCase() ==
              widget.walletAddress.hex.toLowerCase();

          return NFTCard(
            nft: nft,
            isOwner: isOwner,
            onTap: (String amount) async {
              ProgressHud.showLoading();
              String? res = await marketplaceProvider.placeBid(
                nft['listingId'],
                amount,
              );
              ProgressHud.dismiss();
              if (res != null) {
                toast("Successfully placed bid");
                marketplaceProvider.loadMarketNFTs(widget.walletAddress.hex);
              } else {
                toast("Error placing bid");
              }
            },
            isGridView: true,
          );
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: nfts.length,
        itemBuilder: (context, index) {
          final nft = nfts[index];
          final isOwner = nft['seller'].toLowerCase() ==
              widget.walletAddress.hex.toLowerCase();

          return NFTCard(
            nft: nft,
            isOwner: isOwner,
            onTap: (String amount) {
              marketplaceProvider.placeBid(
                nft['listingId'],
                amount,
              );
            },
            isGridView: false,
          );
        },
      );
    }
  }
}
