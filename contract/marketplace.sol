// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarketplace is ERC721URIStorage, ReentrancyGuard {
    uint public listingIdCounter;
    uint public tokenIdCounter; // For minting new token IDs

    struct Listing {
        uint listingId;
        uint tokenId;
        address payable seller;
        string title;
        string imageUrl;
        uint price; // Price of the NFT in Wei
        uint highestBid;
        address payable highestBidder;
        bool active;
    }

    mapping(uint => Listing) public listings;
    mapping(uint => uint) public tokenIdToListingId; // Map tokenId to its latest listingId

    event NFTListed(uint listingId, address seller, uint tokenId, string title, string imageUrl, uint price);
    event NewBid(uint listingId, address bidder, uint amount);
    event NFTTransferred(uint listingId, address from, address to);
    event NFTMinted(address to, uint tokenId, string tokenURI);

    constructor() ERC721("NFT Marketplace", "NFTM") {}

    /// @notice List and mint an NFT on the marketplace
    function listNFT(string memory _title, string memory _imageUrl, uint _price) external {
        uint newTokenId = tokenIdCounter + 1;
        _mint(msg.sender, newTokenId); // Mint the new token
        _setTokenURI(newTokenId, _imageUrl); // Set the metadata URI (e.g., image URL)

        tokenIdCounter = newTokenId; // Increment tokenIdCounter

        // Add the newly minted NFT to the marketplace listing
        listingIdCounter++;
        listings[listingIdCounter] = Listing({
            listingId: listingIdCounter,
            tokenId: newTokenId,
            seller: payable(msg.sender),
            title: _title,
            imageUrl: _imageUrl,
            price: _price, // Set the price of the NFT
            highestBid: 0,
            highestBidder: payable(address(0)),
            active: true
        });

        // Track the latest listing for this token
        tokenIdToListingId[newTokenId] = listingIdCounter;

        emit NFTMinted(msg.sender, newTokenId, _imageUrl);
        emit NFTListed(listingIdCounter, msg.sender, newTokenId, _title, _imageUrl, _price);
    }

    /// @notice Bid on an NFT
    function bid(uint _listingId) external payable nonReentrant {
        Listing storage listing = listings[_listingId];
        require(listing.active, "Listing not active");
        require(msg.value > listing.highestBid, "Bid too low");
        require(msg.sender != listing.seller, "Seller cannot bid");

        // Refund previous bidder
        if (listing.highestBid > 0) {
            listing.highestBidder.transfer(listing.highestBid);
        }

        listing.highestBid = msg.value;
        listing.highestBidder = payable(msg.sender);

        emit NewBid(_listingId, msg.sender, msg.value);
    }

    /// @notice Finalize the sale and transfer NFT
    function transferNFT(uint _listingId) external nonReentrant {
        Listing storage listing = listings[_listingId];
        require(listing.active, "Listing not active");
        require(msg.sender == listing.seller, "Only seller can finalize");
        require(listing.highestBid > 0, "No bids placed");
        
        // Store local variables to prevent issues during transfer
        address payable seller = listing.seller;
        address payable buyer = listing.highestBidder;
        uint256 tokenId = listing.tokenId;
        uint256 amount = listing.highestBid;
        
        // Ensure the seller is actually the owner before transfer
        require(ownerOf(tokenId) == seller, "Seller not owner of NFT");
        
        // Transfer the funds to the seller first (following checks-effects-interactions pattern)
        seller.transfer(amount);
        
        // Transfer the NFT directly without using approve
        _transfer(seller, buyer, tokenId);
        
        // Update the seller to the new owner (buyer) and reset the bid data
        listing.seller = buyer;
        listing.highestBid = 0;
        listing.highestBidder = payable(address(0));
        // Keep the listing active
        
        emit NFTTransferred(_listingId, seller, buyer);
    }

    /// @notice Get all market NFTs (active listings)
    function getMarketNFTs() external view returns (Listing[] memory) {
        uint total = listingIdCounter;
        uint count = 0;

        for (uint i = 1; i <= total; i++) {
            if (listings[i].active) count++;
        }

        Listing[] memory items = new Listing[](count);
        uint index = 0;
        for (uint i = 1; i <= total; i++) {
            if (listings[i].active) {
                items[index] = listings[i];
                index++;
            }
        }

        return items;
    }
    
    /// @notice Get all owned NFTs (both active listings and purchased NFTs)
    function getOwnedNFTs() external view returns (Listing[] memory) {
        uint total = listingIdCounter;
        uint ownedCount = 0;
        
        // First count how many NFTs the caller owns (by checking if they are the seller in any listing)
        for (uint i = 1; i <= total; i++) {
            if (listings[i].seller == msg.sender) {
                ownedCount++;
            }
        }
        
        Listing[] memory ownedItems = new Listing[](ownedCount);
        uint index = 0;
        
        // Get all listings where the caller is the seller
        for (uint i = 1; i <= total; i++) {
            if (listings[i].seller == msg.sender) {
                ownedItems[index] = listings[i];
                index++;
            }
        }
        
        return ownedItems;
    }
}