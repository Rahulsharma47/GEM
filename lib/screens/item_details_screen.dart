// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gem_biz_app/screens/add_item_screen.dart';
import 'package:gem_biz_app/utils/firestore.dart'; // Import the new service
import 'package:gem_biz_app/models/item_model.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:gem_biz_app/widgets/snackbar.dart';
import 'package:gem_biz_app/widgets/fullscreen_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';


class ItemDetailsScreen extends StatefulWidget {
  final ItemModel item;

  const ItemDetailsScreen({super.key, required this.item});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final PageController _pageController = PageController();

  Widget _buildShimmerEffect() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer for app bar space
          Container(
            height: MediaQuery.of(context).padding.top + kToolbarHeight,
            color: Colors.transparent,
          ),
          // Image gallery shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: 300,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildShimmerSection('Product Info'),
                _buildShimmerSection('Quantities'),
                _buildShimmerSection('Replacement'),
                _buildShimmerSection('Colors'),
                _buildShimmerSection('Sizes'),
                _buildShimmerSection('Visibility'),
                _buildShimmerSection('Item Status'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Add this helper method for shimmer sections
  Widget _buildShimmerSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 20,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 20,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Container(
                width: 200,
                height: 20,
                color: Colors.white,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
      return;
    }

    // Add http:// prefix if not present
    if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
      urlString = 'https://$urlString';
    }

    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          showTopSnackBar(context, 'Could not launch the website');
        }
      }
    } catch (e) {
      if (mounted) {
        showTopSnackBar(context, 'Error launching website: $e');
      }
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: FutureBuilder<ItemModel?>(
      future: _firestoreService.getItem(widget.item.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Stack(
              children: [
                _buildShimmerEffect(),
                // Keep the app bar visible during loading
                Positioned(
                  top: MediaQuery.of(context).padding.top,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: kToolbarHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 48), // Space for menu button
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final firestoreItem = snapshot.data ?? widget.item;
          
        return SingleChildScrollView(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                  children: [
                    // Image gallery
                    _buildImageGallery(firestoreItem.imageUrls),
                    // Custom app bar overlay
                    Positioned(
                      top: MediaQuery.of(context).padding.top, // Account for status bar
                      left: 0,
                      right: 0,
                      child: Container(
                        height: kToolbarHeight,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back button
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            // Menu button
                            PopupMenuButton<String>(
                              color: Colors.white,
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              ),
                              onSelected: (String value) {
                                switch (value) {
                                  case 'Edit item':
                                    _editItem(context);
                                    break;
                                  case 'Delete item':
                                    _deleteItem(context);
                                    break;
                                  case 'Hide item':
                                  case 'Unhide item':
                                    _hideItem(context);
                                    break;
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return [
                                  const PopupMenuItem(
                                    value: 'Edit item',
                                    child: Text('Edit item'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'Delete item',
                                    child: Text('Delete item'),
                                  ),
                                  PopupMenuItem(
                                    value: widget.item.hideItem ? 'Unhide item' : 'Hide item',
                                    child: Text(widget.item.hideItem ? 'Unhide item' : 'Hide item'),
                                  ),
                                ];
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16), // Add spacing
                      _buildSection('Product Info', [
                        _buildInfoRow('Name', firestoreItem.name),
                        _buildInfoRow('Description', firestoreItem.description),
                        _buildInfoRow('MRP', firestoreItem.mrp.toString()),
                        _buildInfoRow('Selling Price', firestoreItem.sellingPrice.toString()),
                        _buildInfoRow('Country', firestoreItem.country),
                        if (firestoreItem.link.isNotEmpty)
                          _buildInfoRow('Link', firestoreItem.link),
                      ]),     
                      _buildSection(
                          'Quantities',
                          [
                            _buildInfoRow('Stock Info', firestoreItem.stockInfo),
                            _buildInfoRow('Quantities', firestoreItem.quantities.join('\n')),                        
                          ],
                        ),
                      _buildSection('Replacement', [
                        Text('Replacement Available: ${firestoreItem.isReplacement ? 'Yes' : 'No'}'),
                        if (firestoreItem.isReplacement) ...[
                          Text('Replacement Period: ${firestoreItem.replacementDays} ${firestoreItem.replacementUnit}'),
                        ],
                      ]),
                      _buildSection('Colors', [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: firestoreItem.colors.map((color) => _buildColorChip(color)).toList(),
                        ),
                      ]),
                      if (firestoreItem.sizes.isNotEmpty)
                        _buildSection('Sizes', [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: firestoreItem.sizes.map((size) => Chip(label: Text(size))).toList(),
                          ),
                        ]),
                      _buildSection('Visibility', [
                        Text('Hidden: ${firestoreItem.hideItem ? 'Yes' : 'No'}'),
                      ]),
                      _buildSection('Item Status', [
                        Text('Status: ${firestoreItem.itemStatus}'),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

Widget _buildImageGallery(List<String> imageUrls) {
  return SizedBox(
    height: 300,
    width: double.infinity,
    child: Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageViewer(
                          imageUrls: imageUrls,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: 300,
                    child: CachedNetworkImage(
                      imageUrl: imageUrls[index],
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                ),
                if (widget.item.hideItem)
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.visibility_off,
                        color: Colors.grey,
                        size: 32,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Center(
            child: SmoothPageIndicator(
              controller: _pageController,
              count: imageUrls.length,
              effect: WormEffect(
                dotWidth: 8,
                dotHeight: 8,
                activeDotColor: Colors.black,
                dotColor: Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _editItem(BuildContext context) async {
    try {
      // Navigate to AddItemScreen with the current item details
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AddItemScreen(itemId: widget.item.id),
        ),
      );

  
    } catch (e) {
      if (mounted) {  // Check if widget is still mounted
        showTopSnackBar(context, 'Failed to edit item: $e');
      }
    }
  }

  Future<void> _deleteItem(BuildContext context) async {
    // Show a confirmation dialog before deleting
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await _firestoreService.deleteItem(widget.item.itemId);
        showTopSnackBar(context, 'Item deleted successfully');
        Navigator.of(context).pop(); // Go back to the previous screen
      } catch (e) {
        showTopSnackBar(context, 'Failed to delete item: $e');
      }
    }
  }

void _hideItem(BuildContext context) async {
  try {
    bool newHideStatus = !widget.item.hideItem;
    widget.item.hideItem = newHideStatus;
    await _firestoreService.updateItem(widget.item);
    showTopSnackBar(context, newHideStatus ?'Item hidden' : 'Item unhidden');
    setState(() {
      widget.item.hideItem = newHideStatus;
    }); 
  } catch (e) {
    showTopSnackBar(context, 'Failed to update item visibility: $e');
  }
}

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

   Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: label.toLowerCase() == 'link'
                ? InkWell(
                    onTap: () => _launchUrl(value),
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: const TextStyle(fontSize: 15),
                  ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildColorChip(Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey),
      ),
    );
  }
}