class NFT {
  final BigInt listingId;
  final BigInt tokenId;
  final String seller;
  final String title;
  final String imageUrl;
  final BigInt price;
  final BigInt highestBid;
  final String highestBidder;
  final bool active;

  NFT({
    required this.listingId,
    required this.tokenId,
    required this.seller,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.highestBid,
    required this.highestBidder,
    required this.active,
  });

  factory NFT.fromMap(Map<String, dynamic> map) {
    return NFT(
      listingId: map['listingId'],
      tokenId: map['tokenId'],
      seller: map['seller'],
      title: map['title'],
      imageUrl: map['imageUrl'],
      price: map['price'],
      highestBid: map['highestBid'],
      highestBidder: map['highestBidder'],
      active: map['active'],
    );
  }
}