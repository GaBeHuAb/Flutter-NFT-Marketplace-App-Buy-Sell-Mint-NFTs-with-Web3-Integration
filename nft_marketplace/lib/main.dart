import 'dart:async';

import 'package:bmprogresshud/bmprogresshud.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nft_marketplace/providers/marketplace_provider.dart';
import 'package:nft_marketplace/providers/nft_card_provider.dart';
import 'package:nft_marketplace/providers/wallet_connect_provider.dart';
import 'core/theme/app_theme.dart';
import 'injection_container.dart';
import 'screens/wallet_connect_screen.dart';
import 'package:provider/provider.dart';
import 'providers/create_nft_provider.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
    initDependencies();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
    };

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: MarketplaceTheme.backgroundColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

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
    debugPrint('Error: $error');
    debugPrint('StackTrace: $stackTrace');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProgressHud(
      isGlobalHud: true,
      child: MaterialApp(
        title: 'NFT Marketplace',
        debugShowCheckedModeBanner: false,
        theme: MarketplaceTheme.getTheme(),
        home: WalletConnectScreen(),
      ),
    );
  }
}