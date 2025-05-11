import 'package:flutter/material.dart';
import 'package:nft_marketplace/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../providers/wallet_connect_provider.dart';
import 'marketplace_screen.dart';

class WalletConnectScreen extends StatefulWidget {
  const WalletConnectScreen({super.key});

  @override
  State<WalletConnectScreen> createState() => _WalletConnectScreenState();
}

class _WalletConnectScreenState extends State<WalletConnectScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController privateKeyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    privateKeyController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> connectWallet(WalletConnectProvider walletProvider) async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }

    HapticFeedback.lightImpact();

    try {
      final success =
          await walletProvider.connectWallet(privateKeyController.text);

      if (success && mounted) {
        _animationController.reverse().then((_) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  MarketplaceScreen(
                walletAddress: walletProvider.walletAddress!,
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.vibrate();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error connecting wallet: ${e.toString()}'),
            backgroundColor: MarketplaceTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              MarketplaceTheme.backgroundColor,
              MarketplaceTheme.backgroundColor.withValues(alpha: 0.8),
              MarketplaceTheme.surfaceColor.withValues(alpha: 0.4),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeInAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: child,
                ),
              );
            },
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Hero(
                        tag: 'wallet_icon',
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: MarketplaceTheme.cardColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: MarketplaceTheme.primaryColor
                                    .withValues(alpha:0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 50,
                            color: MarketplaceTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'NFT Marketplace',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: MarketplaceTheme.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Connect your wallet to start trading NFTs',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: MarketplaceTheme.textSecondary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Card(
                        color: MarketplaceTheme.cardColor,
                        elevation: 8,
                        shadowColor:
                            MarketplaceTheme.primaryColor.withValues(alpha:0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Connect Wallet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: MarketplaceTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Enter your private key to connect',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: MarketplaceTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Consumer<WalletConnectProvider>(
                                  builder: (context, walletProvider, _) {
                                return TextFormField(
                                  controller: privateKeyController,
                                  style: TextStyle(
                                    color: MarketplaceTheme.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Private Key',
                                    labelStyle: TextStyle(
                                      color: MarketplaceTheme.textSecondary,
                                    ),
                                    hintText: '0x...',
                                    hintStyle: TextStyle(
                                      color: MarketplaceTheme.textSecondary
                                          .withValues(alpha:0.5),
                                    ),
                                    filled: true,
                                    fillColor: MarketplaceTheme.surfaceColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: MarketplaceTheme.primaryColor,
                                        width: 2,
                                      ),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.key_rounded,
                                      color: MarketplaceTheme.primaryColor,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        walletProvider.obscureText
                                            ? Icons.visibility_rounded
                                            : Icons.visibility_off_rounded,
                                        color: MarketplaceTheme.textSecondary,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          walletProvider.obscureText =
                                              !walletProvider.obscureText;
                                        });
                                      },
                                    ),
                                  ),
                                  obscureText: walletProvider.obscureText,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your private key';
                                    }
                                    if (!value.startsWith('0x')) {
                                      return 'Private key should start with 0x';
                                    }
                                    return null;
                                  },
                                  onChanged: (_) {
                                    // Clear any previous error states
                                    _formKey.currentState?.validate();
                                  },
                                );
                              }),
                              const SizedBox(height: 24),
                              Consumer<WalletConnectProvider>(
                                  builder: (context, walletProvider, _) {
                                return ElevatedButton(
                                  onPressed: walletProvider.isLoading
                                      ? null
                                      : () => connectWallet(walletProvider),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        MarketplaceTheme.primaryColor,
                                    disabledBackgroundColor:
                                        MarketplaceTheme.primaryColor
                                            .withValues(alpha:0.4),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                    shadowColor: MarketplaceTheme.primaryColor
                                        .withValues(alpha:0.5),
                                  ),
                                  child: walletProvider.isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.login_rounded,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Connect Wallet',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextButton(
                        onPressed: () {
                          // Show a demo dialog about wallet security
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                'Wallet Security',
                                style: TextStyle(
                                  color: MarketplaceTheme.textPrimary,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Never share your private key with anyone. Keep it secure and stored safely.',
                                    style: TextStyle(
                                      color: MarketplaceTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Got it',
                                    style: TextStyle(
                                      color: MarketplaceTheme.accentColor,
                                    ),
                                  ),
                                ),
                              ],
                              backgroundColor: MarketplaceTheme.cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: MarketplaceTheme.textSecondary,
                        ),
                        child: const Text(
                          'Learn about wallet security',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}