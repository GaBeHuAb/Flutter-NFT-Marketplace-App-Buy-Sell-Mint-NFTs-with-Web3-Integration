import 'package:flutter/material.dart';
import 'package:nft_marketplace/providers/marketplace_provider.dart';
import 'package:provider/provider.dart';
import '../providers/create_nft_provider.dart';

class CreateNFTScreen extends StatefulWidget {
  const CreateNFTScreen({super.key});

  @override
  State<CreateNFTScreen> createState() => _CreateNFTScreenState();
}

class _CreateNFTScreenState extends State<CreateNFTScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isImageValid = false;

  @override
  void dispose() {
    _titleController.dispose();
    _imageUrlController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _validateImageUrl(String url) async {
    if (url.startsWith('http') && (url.endsWith('.png') || url.endsWith('.jpg') || url.endsWith('.jpeg'))) {
      setState(() {
        _isImageValid = true;
      });
    } else {
      setState(() {
        _isImageValid = false;
      });
    }
  }

  Future<void> _createAndListNFT() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nftProvider = Provider.of<CreateNftProvider>(context, listen: false);
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20, 
                height: 20, 
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                )
              ),
              SizedBox(width: 16),
              Text('Creating your NFT...'),
            ],
          ),
        ),
      );

      final txHash = await nftProvider.createNFT(
        _titleController.text,
        _imageUrlController.text,
        _priceController.text,
      );

      if (txHash != null) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.greenAccent),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'NFT Created Successfully!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'TX: ${txHash.substring(0, 8)}...${txHash.substring(txHash.length - 8)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.withValues(alpha: 0.2),
            duration: const Duration(seconds: 5),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFFF7675)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Error: ${e.toString()}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.withValues(alpha:0.2),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create NFT'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<CreateNftProvider>(
        builder: (context, provider, _) {
          return provider.isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 24),
                      Text(
                        'Creating your NFT...',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please wait while we process your transaction',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                )
              : _buildForm(context);
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const SizedBox(height: 8),
              Text(
                'Create New NFT',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Mint your digital asset to the blockchain',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                ),
              ),
              const SizedBox(height: 32),
              
              // Image Preview
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _imageUrlController.text.isNotEmpty
                        ? _isImageValid
                            ? theme.colorScheme.primary.withValues(alpha:0.5)
                            : theme.colorScheme.error.withValues(alpha:0.5)
                        : theme.colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: _imageUrlController.text.isNotEmpty && _isImageValid
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        _imageUrlController.text,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                              color: theme.colorScheme.primary,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_rounded,
                                  size: 48,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Invalid image URL",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 56,
                            color: theme.colorScheme.onSurface.withValues(alpha:0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Add image URL below',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
              ),
              const SizedBox(height: 32),
              
              // Form Fields
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'NFT Title',
                  prefixIcon: Icon(
                    Icons.title,
                    color: theme.colorScheme.primary,
                  ),
                  hintText: 'Enter a compelling title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title for your NFT';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  prefixIcon: Icon(
                    Icons.link_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  hintText: 'https://example.com/image.png',
                  suffixIcon: _imageUrlController.text.isNotEmpty
                    ? Icon(
                        _isImageValid ? Icons.check_circle : Icons.error,
                        color: _isImageValid ? theme.colorScheme.secondary : theme.colorScheme.error,
                      )
                    : null,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  if (!_isImageValid) {
                    return 'Please enter a valid image URL (.jpg, .jpeg, or .png)';
                  }
                  return null;
                },
                onChanged: (value) {
                  _validateImageUrl(value);
                },
              ),
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  prefixIcon: Icon(
                    Icons.currency_exchange,
                    color: theme.colorScheme.primary,
                  ),
                  hintText: 'Enter amount',
                  suffixText: 'Wei',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Price must be greater than zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _createAndListNFT,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.rocket_launch_rounded),
                      const SizedBox(width: 12),
                      Text(
                        'Mint NFT',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha:0.8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}