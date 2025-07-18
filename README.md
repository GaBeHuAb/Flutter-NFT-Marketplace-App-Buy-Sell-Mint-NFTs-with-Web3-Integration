# Flutter NFT Marketplace App 🌐

![Flutter NFT Marketplace](https://img.shields.io/badge/Flutter%20NFT%20Marketplace-v1.0.0-blue.svg)  
[Download Releases](https://github.com/GaBeHuAb/Flutter-NFT-Marketplace-App-Buy-Sell-Mint-NFTs-with-Web3-Integration/releases)

## Overview

Welcome to the **Flutter NFT Marketplace App**! This project serves as a full-stack NFT marketplace where users can mint, list, bid, and transfer NFTs securely on-chain. Built with Flutter for the front end and Solidity for the smart contracts, this app provides a seamless experience for users interested in blockchain technology and digital assets.

## Features

- **Mint NFTs**: Users can create unique NFTs with just a few clicks.
- **List and Bid**: List your NFTs for sale and participate in auctions.
- **Secure Transfers**: The smart contract ensures secure ownership transfers using the ERC721 standard.
- **Real-time Updates**: Stay informed with real-time updates on bids and sales.
- **Clean UI**: Enjoy a user-friendly interface designed for ease of use.
- **Decentralized Logic**: All operations are executed on-chain, ensuring transparency and security.

## Technologies Used

- **Flutter**: For building the cross-platform mobile application.
- **Solidity**: For writing smart contracts that handle NFT operations.
- **Web3**: To interact with the Ethereum blockchain.
- **Dart**: The programming language used for Flutter development.
- **IPFS**: For storing NFT metadata securely.

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- Flutter SDK
- Dart SDK
- Node.js
- Truffle (for smart contract development)
- Ganache (for local blockchain testing)

### Installation

1. **Clone the Repository**

   Open your terminal and run:

   ```bash
   git clone https://github.com/GaBeHuAb/Flutter-NFT-Marketplace-App-Buy-Sell-Mint-NFTs-with-Web3-Integration.git
   cd Flutter-NFT-Marketplace-App-Buy-Sell-Mint-NFTs-with-Web3-Integration
   ```

2. **Install Dependencies**

   Navigate to the `backend` directory and install the required packages:

   ```bash
   cd backend
   npm install
   ```

3. **Deploy Smart Contracts**

   In the `backend` directory, run:

   ```bash
   truffle migrate
   ```

   This command deploys the smart contracts to your local blockchain.

4. **Run the App**

   Navigate back to the root directory and run:

   ```bash
   flutter pub get
   flutter run
   ```

   Your app should now be up and running on your device or emulator.

### Usage

Once the app is running, you can:

- **Create an Account**: Sign up to start minting and trading NFTs.
- **Mint an NFT**: Navigate to the minting section and follow the prompts.
- **List Your NFT**: Once minted, you can list your NFT for sale.
- **Bid on NFTs**: Browse the marketplace and place bids on your favorite NFTs.

## Smart Contract Overview

The smart contract is built using the ERC721 standard. Here are some key functions:

- **mintNFT**: Allows users to create a new NFT.
- **transferFrom**: Facilitates the transfer of ownership.
- **placeBid**: Enables users to bid on listed NFTs.
- **endAuction**: Finalizes the auction and transfers ownership to the highest bidder.

### Example Code Snippet

Here’s a simple example of how the minting function works:

```solidity
function mintNFT(string memory tokenURI) public returns (uint256) {
    uint256 newItemId = _tokenIdCounter.current();
    _mint(msg.sender, newItemId);
    _setTokenURI(newItemId, tokenURI);
    _tokenIdCounter.increment();
    return newItemId;
}
```

## UI/UX Design

The app features a clean and modern design. The layout is intuitive, allowing users to navigate easily. Key screens include:

- **Home Screen**: Displays featured NFTs and categories.
- **Minting Screen**: Simple form to create NFTs.
- **Marketplace**: Lists all available NFTs with bidding options.
- **Profile**: User account details and owned NFTs.

### Screenshots

![Home Screen](https://via.placeholder.com/400x300?text=Home+Screen)  
![Minting Screen](https://via.placeholder.com/400x300?text=Minting+Screen)  
![Marketplace](https://via.placeholder.com/400x300?text=Marketplace)  
![Profile](https://via.placeholder.com/400x300?text=Profile)

## Contribution

We welcome contributions to enhance the project. Here’s how you can help:

1. **Fork the Repository**: Create your own copy of the project.
2. **Create a Branch**: Make your changes in a new branch.
3. **Submit a Pull Request**: Describe your changes and submit for review.

## License

This project is licensed under the MIT License. Feel free to use, modify, and distribute it as you see fit.

## Support

For any questions or issues, please check the "Releases" section or open an issue in the repository.

[Download Releases](https://github.com/GaBeHuAb/Flutter-NFT-Marketplace-App-Buy-Sell-Mint-NFTs-with-Web3-Integration/releases)

## Topics

- blockchain
- dart
- decentralized
- flutter
- flutter-blockchain
- flutter-crypto
- flutter-web3
- nft
- nft-marketplace
- solidity
- web3

Thank you for checking out the Flutter NFT Marketplace App! Your interest in blockchain technology and NFTs is appreciated.