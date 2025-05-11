import 'package:bmprogresshud/progresshud.dart';
import 'package:flutter/material.dart';
import 'package:nft_marketplace/core/constants/functions.dart';
import 'package:nft_marketplace/providers/marketplace_provider.dart';
import 'package:nft_marketplace/screens/create_nft_screen.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';
import '../widgets/nft_card.dart';

class MyNFTsScreen extends StatefulWidget {
  final EthereumAddress walletAddress;
  const MyNFTsScreen({super.key, required this.walletAddress});

  @override
  State<MyNFTsScreen> createState() => _MyNFTsScreenState();
}

class _MyNFTsScreenState extends State<MyNFTsScreen> {
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketplaceProvider>().getBalance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<MarketplaceProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My NFTs'),
            actions: [
              IconButton(
                icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
              ),
            ],
          ),
          body: Column(
            children: [
              _buildBalanceCard(provider),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Listed NFTs',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${provider.myNFTs.length} items',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildNFTsContent(provider),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              provider.loadMarketNFTs(widget.walletAddress.hex);
            },
            tooltip: 'Refresh',
            child: const Icon(Icons.refresh),
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard(MarketplaceProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6C5CE7).withValues(alpha: 0.8),
            Color(0xFF6C5CE7).withValues(alpha: 0.4),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                provider.balance == null
                    ? "0 Eth"
                    : '${formatEther(provider.balance!)} ETH',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wallet, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.walletAddress.hex.substring(0, 6)}...${widget.walletAddress.hex.substring(widget.walletAddress.hex.length - 4)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNFTsContent(MarketplaceProvider provider) {
    if (provider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF6C5CE7),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading your NFTs...',
              style: TextStyle(color: Color(0xFFB2B2B2)),
            ),
          ],
        ),
      );
    }

    if (provider.myNFTs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 64,
              color: Color(0xFF636E72),
            ),
            const SizedBox(height: 16),
            Text(
              'You don\'t have any NFTs listed',
              style: TextStyle(
                color: Color(0xFFB2B2B2),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateNFTScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create New NFT'),
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
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: provider.myNFTs.length,
        itemBuilder: (context, index) {
          final nft = provider.myNFTs[index];
          return NFTCard(
            nft: nft,
            isOwner: true,
            onTap: (_) async {
              ProgressHud.showLoading();
              String? res = await provider.finalizeTransfer(nft["listingId"]);
              ProgressHud.dismiss();
              if (res != null) {
                toast("Successfully transferred");
                provider.loadMarketNFTs(widget.walletAddress.hex);
              } else {
                toast("Error transferring NFT");
              }
            },
            isGridView: true,
          );
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.myNFTs.length,
        itemBuilder: (context, index) {
          final nft = provider.myNFTs[index];
          return NFTCard(
            nft: nft,
            isOwner: true,
            onTap: (_) {
              provider.finalizeTransfer(nft["listingId"]);
            },
            isGridView: false,
          );
        },
      );
    }
  }

  String formatEther(EtherAmount amount) {
    final inEth = amount.getValueInUnit(EtherUnit.ether);
    return inEth.toStringAsFixed(4);
  }
}
