# NFT Marketplace App

A decentralized NFT marketplace built with Flutter and Solidity smart contracts, allowing users to mint, list, and trade NFTs on the Ethereum blockchain (Sepolia testnet). This mobile application provides a complete solution for NFT creation, trading, and management using Web3 integration.

## Features

- **Wallet Connection**: Securely connect your Ethereum wallet using private key
- **NFT Creation**: Mint your own NFTs with custom images and metadata
- **NFT Listing**: List your NFTs for sale at your chosen price
- **NFT Trading**: Bid on NFTs and complete transactions on-chain
- **Portfolio Management**: View all your owned and listed NFTs
- **Transaction Tracking**: Get real-time confirmation of blockchain transactions

## Screenshots

<table>
  <tr>
    <td><img src="https://raw.githubusercontent.com/shehrii9/Flutter-NFT-Marketplace-App-Buy-Sell-Mint-NFTs-with-Web3-Integration/main/screenshots/connect_wallet.png" alt="Connect Wallet" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/shehrii9/Flutter-NFT-Marketplace-App-Buy-Sell-Mint-NFTs-with-Web3-Integration/main/screenshots/marketplace_empty.png" alt="Empty Marketplace" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/shehrii9/Flutter-NFT-Marketplace-App-Buy-Sell-Mint-NFTs-with-Web3-Integration/main/screenshots/create_nft.png" alt="Create NFT" width="200"/></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/shehrii9/Flutter-NFT-Marketplace-App-Buy-Sell-Mint-NFTs-with-Web3-Integration/main/screenshots/creating_nft.png" alt="Creating NFT" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/shehrii9/Flutter-NFT-Marketplace-App-Buy-Sell-Mint-NFTs-with-Web3-Integration/main/screenshots/my_nfts.png" alt="My NFTs" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/shehrii9/Flutter-NFT-Marketplace-App-Buy-Sell-Mint-NFTs-with-Web3-Integration/main/screenshots/marketplace_with_nft.png" alt="Marketplace with NFT" width="200"/></td>
  </tr>
</table>


## Technical Architecture

### Frontend
- Built with Flutter for cross-platform support
- Provider pattern for state management
- Custom dark mode UI with modern design elements
- Progress HUD for transaction feedback
- Dependency injection for clean architecture

### Backend
- Solidity smart contract deployed on Sepolia testnet
- ERC-721 standard for NFT implementation
- OpenZeppelin libraries for security and standardization
- ReentrancyGuard for transaction safety

## Smart Contract

The NFT Marketplace contract is built on Solidity 0.8.24 and includes:
- ERC721 token standard implementation
- Secure bidding mechanism
- NFT ownership transfer logic
- Listing management
- Reentrancy protection

## Project Structure

```
nft_marketplace/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   └── theme/
│   │       └── app_theme.dart
│   ├── models/
│   ├── providers/
│   │   ├── create_nft_provider.dart
│   │   ├── marketplace_provider.dart
│   │   ├── nft_card_provider.dart
│   │   └── wallet_connect_provider.dart
│   ├── screens/
│   │   └── wallet_connect_screen.dart
│   ├── services/
│   ├── widgets/
│   ├── injection_container.dart
│   └── main.dart
├── contract/
│   └── marketplace.sol
├── .env
└── README.md
```

## Getting Started

### Prerequisites

- Flutter SDK installed
- Ethereum wallet with Sepolia testnet ETH
- Infura account for Ethereum API access
- Smart contract deployed on Sepolia testnet

### Environment Setup

1. Clone the repository:
```bash
git clone https://github.com/shehril/NFT-Marketplace-App-Buy-Sell-Mint-NFTs-with-Web3-Integration.git
cd NFT-Marketplace-App-Buy-Sell-Mint-NFTs-with-Web3-Integration
```

2. Create a `.env` file in the project root with the following variables:
```
INFURA_SEPOLIA_URL=https://sepolia.infura.io/v3/YOUR_INFURA_KEY
CONTRACT_ADDRESS=YOUR_DEPLOYED_CONTRACT_ADDRESS
CHAIN_ID=11155111
```

3. Install dependencies:
```bash
flutter pub get
```

### Running the App

```bash
flutter run
```

## Usage Guide

### Connecting Your Wallet
1. Open the app and tap "Connect Wallet"
2. Enter your private key (For production, consider using WalletConnect or a more secure method)
3. Your wallet address and ETH balance will be displayed

### Creating an NFT
1. Tap the "+" button in the marketplace screen
2. Enter NFT details:
   - NFT Title: Give your NFT a name
   - Image URL: Link to the image you want to use for your NFT
   - Price: Set the initial listing price in ETH
3. Tap "Mint NFT" to create your NFT
4. Wait for the blockchain transaction to complete

### Trading NFTs
1. Browse available NFTs in the marketplace
2. Tap on an NFT to view details
3. Place a bid (must be higher than the current highest bid)
4. Sellers can accept bids and transfer NFT ownership

## Key Components

### Main App
```dart
void main() {
  runZonedGuarded(() async {
    // Initialize environment variables and dependencies
    await dotenv.load(fileName: ".env");
    initDependencies();
    
    // Run the app with multiple providers
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => sl<WalletConnectProvider>()),
          ChangeNotifierProvider(create: (_) => sl<CreateNftProvider>()),
          ChangeNotifierProvider(create: (_) => sl<MarketplaceProvider>()),
          ChangeNotifierProvider(create: (_) => sl<NFTCardProvider>()),
        ],
        child: const MyApp(),
      ),
    );
  }, (error, stackTrace) {
    // Error handling
    debugPrint('Error: $error');
    debugPrint('StackTrace: $stackTrace');
  });
}
```

### Error Handling
The app implements comprehensive error handling with:
- Flutter error capture using `FlutterError.onError`
- Zone-based error handling with `runZonedGuarded`
- Progress HUD for user feedback during operations

## Security Considerations

- **Private Key Storage**: The app currently requires direct private key input which is not recommended for production. Consider implementing more secure wallet connection methods like WalletConnect.
- **Image URLs**: Use decentralized storage solutions like IPFS for storing NFT images in a production environment.
- **Error Handling**: The app includes error handling but consider adding more specific error messages for blockchain-related issues.
- **Testnet Only**: This version is configured for Sepolia testnet. Reconfigure for mainnet with caution.

## Development

### Architecture
The app follows a Provider pattern for state management:
- **WalletConnectProvider**: Handles wallet connection and Ethereum transactions
- **CreateNftProvider**: Manages the NFT creation process
- **MarketplaceProvider**: Controls marketplace listings and interactions
- **NFTCardProvider**: Handles individual NFT card states and operations

### Dependency Injection
The app uses a service locator pattern implemented in `injection_container.dart` for dependency injection:
```dart
void initDependencies() {
  // Register providers
  sl.registerLazySingleton(() => WalletConnectProvider());
  sl.registerLazySingleton(() => CreateNftProvider());
  sl.registerLazySingleton(() => MarketplaceProvider());
  sl.registerLazySingleton(() => NFTCardProvider());
  
  // Register services
  // ...
}
```

### Theming
Custom dark theme is implemented in `core/theme/app_theme.dart` with a consistent color scheme throughout the application.

### Contract Deployment
If you want to deploy your own instance of the contract:

1. Install Truffle or Hardhat
2. Configure your deployment network
3. Deploy the contract
4. Update the CONTRACT_ADDRESS in your .env file

## License

[MIT License](LICENSE)

## Acknowledgements

- OpenZeppelin for secure contract libraries
- Infura for Ethereum API services
- Flutter and Dart teams for the development framework

---

*This project is for educational purposes and should be thoroughly audited before any production use.*
