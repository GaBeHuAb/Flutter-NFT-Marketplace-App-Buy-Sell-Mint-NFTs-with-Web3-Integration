import 'package:get_it/get_it.dart';
import 'package:nft_marketplace/providers/create_nft_provider.dart';
import 'package:nft_marketplace/providers/marketplace_provider.dart';
import 'package:nft_marketplace/providers/nft_card_provider.dart';
import 'package:nft_marketplace/services/ethereum_service.dart';

import 'providers/wallet_connect_provider.dart';

final sl = GetIt.instance;
void initDependencies() {
  // Register services
  sl.registerLazySingleton(() => EthereumService());

  //providers
  sl.registerLazySingleton(() => WalletConnectProvider(sl()));
  sl.registerLazySingleton(() => CreateNftProvider(sl()));
  sl.registerLazySingleton(() => MarketplaceProvider(sl()));
  sl.registerLazySingleton(() => NFTCardProvider());
}