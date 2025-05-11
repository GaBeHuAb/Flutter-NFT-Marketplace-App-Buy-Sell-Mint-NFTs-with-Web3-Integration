import 'package:flutter/material.dart';
import 'package:nft_marketplace/core/constants/functions.dart';
import 'package:nft_marketplace/providers/nft_card_provider.dart';
import 'package:provider/provider.dart';

class NftDetailsWidget extends StatefulWidget {
  final Map<String, dynamic> nft;
  final bool isOwner;
  final Function(String) onTap;
  const NftDetailsWidget({
    super.key,
    required this.nft,
    required this.onTap,
    required this.isOwner,
  });

  @override
  State<NftDetailsWidget> createState() => _NftDetailsWidgetState();
}

class _NftDetailsWidgetState extends State<NftDetailsWidget> {
  final TextEditingController bidAmountController = TextEditingController();

  @override
  void dispose() {
    bidAmountController.dispose();
    super.dispose();
  }

  String _truncateAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Consumer<NFTCardProvider>(builder: (context, cardProvider, _) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    if (widget.nft['imageUrl'].toString().isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.nft['imageUrl'],
                          height: 240,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 240,
                            color: Colors.grey.shade800,
                            child: const Center(
                              child: Icon(Icons.broken_image,
                                  size: 80, color: Colors.grey),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 240,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child:
                              Icon(Icons.image, size: 80, color: Colors.grey),
                        ),
                      ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                          constraints: const BoxConstraints.tightFor(
                            width: 40,
                            height: 40,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.nft['title'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.nft['active']
                            ? Colors.green.withValues(alpha: 0.8)
                            : Colors.grey.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.nft['active'] ? 'Active' : 'Inactive',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF252525),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Price',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          Text(
                            formatWei(widget.nft['price']),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFF333333), height: 24),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Highest Bid',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          Text(
                            BigInt.parse(widget.nft['highestBid'].toString()) >
                                    BigInt.zero
                                ? formatWei(widget.nft['highestBid'])
                                : 'No bids yet',
                            style: TextStyle(
                              color: BigInt.parse(
                                          widget.nft['highestBid'].toString()) >
                                      BigInt.zero
                                  ? Colors.amber
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      if (BigInt.parse(widget.nft['highestBid'].toString()) >
                          BigInt.zero) ...[
                        const Divider(color: Color(0xFF333333), height: 24),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Highest Bidder',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            Text(
                              _truncateAddress(widget.nft['highestBidder']),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Divider(color: Color(0xFF333333), height: 24),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Token ID',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          Text(
                            widget.nft['tokenId'].toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFF333333), height: 24),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Seller',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          Text(
                            _truncateAddress(widget.nft['seller']),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (!widget.isOwner && widget.nft['active']) ...[
                  if (cardProvider.showBidForm) ...[
                    TextField(
                      controller: bidAmountController,
                      decoration: InputDecoration(
                        hintText: 'Enter bid amount',
                        filled: true,
                        fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.monetization_on,
                            color: Colors.grey),
                        suffixText: 'Wei',
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              cardProvider.showBidForm = false;
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: cardProvider.isLoading
                                ? null
                                : () {
                                    if (bidAmountController.text.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Bid amount can't be empty")),
                                      );
                                      return;
                                    }

                                    widget
                                        .onTap(bidAmountController.text.trim());
                                    Navigator.pop(context);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: cardProvider.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text(
                                    'Place Bid',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ] else
                    ElevatedButton(
                      onPressed: () {
                        cardProvider.showBidForm = true;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 0),
                      ),
                      child: const Text(
                        'Place a Bid',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
                if (widget.isOwner &&
                    widget.nft['active'] &&
                    BigInt.parse(widget.nft['highestBid'].toString()) >
                        BigInt.zero)
                  ElevatedButton(
                    onPressed: cardProvider.isLoading
                        ? null
                        : () {
                            widget.onTap("");
                            Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                    child: cardProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Accept Highest Bid',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
