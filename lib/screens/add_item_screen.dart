// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gem_biz_app/screens/catalouge_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gem_biz_app/providers/store_verification_provider.dart';
import 'package:gem_biz_app/models/item_model.dart';
import 'package:country_picker/country_picker.dart';
import 'dart:io';
import 'package:gem_biz_app/utils/firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gem_biz_app/utils/url_validator.dart';
import 'package:gem_biz_app/widgets/snackbar.dart';

class AddItemScreen extends StatefulWidget {
  final String itemId;
  const AddItemScreen({super.key, required this.itemId});

  @override
  // ignore: library_private_types_in_public_api
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _replacementDaysController = TextEditingController();
  final TextEditingController _mrpController = TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();
  final TextEditingController _stockInfoController = TextEditingController();
  final List<TextEditingController> _quantityControllers = [TextEditingController()];
  bool isReplacement = false;
  String selectedCountry = "India";
  String replacementUnit = "Days";
  List<Color> pickedColors = [];
  List<String> pickedSizes = [];
  bool hideItem = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final ImagePicker _picker = ImagePicker();
  final List<File?> _selectedImages = List<File?>.filled(4, null);
  final List<String?> _existingImageUrls = List<String?>.filled(4, null);

  bool get isFormValid {
      bool hasRequiredText = 
      _itemNameController.text.isNotEmpty &&
      _descriptionController.text.isNotEmpty &&
      selectedCountry.isNotEmpty &&
      _mrpController.text.isNotEmpty &&
      _sellingPriceController.text.isNotEmpty &&
      _stockInfoController.text.isNotEmpty;

      bool hasImages = _selectedImages.any((image) => image != null) || 
                      _existingImageUrls.any((url) => url != null);
      bool hasQuantity = _quantityControllers.any((controller) => controller.text.isNotEmpty);
      bool hasColor = pickedColors.isNotEmpty;
      bool hasValidReplacement = !isReplacement || 
                               (isReplacement && _replacementDaysController.text.isNotEmpty);

      return hasRequiredText &&
         hasImages &&
         hasQuantity &&
         hasColor &&
         hasValidReplacement;
    }

  Future<void> _pickImage(int index) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImages[index] = File(pickedFile.path);
        _existingImageUrls[index] = null; // Clear existing image URL when new image is picked
      });
    }
  }

  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isSaving = false;
  bool _isLoading = true;
  bool _isEditMode = false;

  @override
    void initState() {
      super.initState();
      _loadItemData();
    }

  Future<void> _loadItemData() async {
    if (widget.itemId.isNotEmpty) {
      setState(() {
        _isLoading = true;
        _isEditMode = true;
      });

      try {
        ItemModel? item = await _firestoreService.getItem(widget.itemId);
        if (item != null) {
          _itemNameController.text = item.name;
          _descriptionController.text = item.description;
          _linkController.text = item.link;
          _replacementDaysController.text = item.replacementDays;
          _mrpController.text = item.mrp.toString();
          _sellingPriceController.text = item.sellingPrice.toString();
          _stockInfoController.text = item.stockInfo;
          
          setState(() {
            selectedCountry = item.country;
            isReplacement = item.isReplacement;
            replacementUnit = item.replacementUnit;
            pickedColors = item.colors;
            pickedSizes = item.sizes;
            hideItem = item.hideItem;
            
            // Handle quantities
            _quantityControllers.clear();
            for (String quantity in item.quantities) {
              _quantityControllers.add(TextEditingController(text: quantity));
            }
            if (_quantityControllers.isEmpty) {
              _quantityControllers.add(TextEditingController());
            }

            // Handle images
            // Note: You might need to adjust this part depending on how you want to handle existing images
            // For now, we'll just show placeholders for existing images
            for (int i = 0; i < item.imageUrls.length && i < 4; i++) {
              _selectedImages[i] = null; // Placeholder for existing image
            }
            _existingImageUrls.fillRange(0, 4, null); // Reset first
            for (int i = 0; i < item.imageUrls.length && i < 4; i++) {
              _existingImageUrls[i] = item.imageUrls[i];
            }
          });
        }
      } catch (e) {
        print('Error loading item data: $e');
        showTopSnackBar(context, 'Error loading item data: $e');        
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    
    // First, add any existing image URLs that weren't replaced
    for (int i = 0; i < 4; i++) {
      if (_existingImageUrls[i] != null && _selectedImages[i] == null) {
        imageUrls.add(_existingImageUrls[i]!);
      }
    }

    // Then upload any new images
    for (int i = 0; i < 4; i++) {
      if (_selectedImages[i] != null) {
        String fileName = '${DateTime.now().millisecondsSinceEpoch}_$i';
        Reference ref = _storage.ref().child('item_images/$fileName');
        UploadTask uploadTask = ref.putFile(_selectedImages[i]!);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }
    }
    
    return imageUrls;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveItem() async {
    String errorMessage = '';
      
      if (!_selectedImages.any((image) => image != null) && 
          !_existingImageUrls.any((url) => url != null)) {
        errorMessage = 'Please add at least one image';
      } else if (!_quantityControllers.any((controller) => controller.text.isNotEmpty)) {
        errorMessage = 'Please add at least one quantity';
      } else if (_stockInfoController.text.isEmpty) {
        errorMessage = 'Please add stock information';
      } else if (pickedColors.isEmpty) {
        errorMessage = 'Please add at least one color';
      } else if (isReplacement && _replacementDaysController.text.isEmpty) {
        errorMessage = 'Please specify replacement days';
      } else if (_linkController.text.isNotEmpty && 
        !RegExp(r'^(https?://)?(www\.)?([a-zA-Z0-9-]+\.)+([a-zA-Z]{2,})(/[^\s]*)?$')
            .hasMatch(_linkController.text)) {
        errorMessage = 'Please provide a valid link format (e.g., https://example.com)';
        //showTopSnackBar(context, 'Please provide a valid link format (e.g., https://example.com)');
      }

      if (errorMessage.isNotEmpty) {
        _showErrorDialog(errorMessage);
        return;
      }
    
    if (!isFormValid) {
      _showErrorDialog('Please fill in all required fields.');
      return;
    }

    // Parse the MRP and Selling Price values
    double? mrp = double.tryParse(_mrpController.text);
    double? sellingPrice = double.tryParse(_sellingPriceController.text);

    // Check if Selling Price is more than MRP
    if (mrp != null && sellingPrice != null && sellingPrice > mrp) {
      // Show Snackbar if Selling Price exceeds MRP
        showTopSnackBar(context , "Selling Price can't be more than MRP.");
      return; // Exit the function early if the validation fails
    }

    setState(() {
      _isSaving = true;
    });
    
    try {
      
    List<String> imageUrls = await _uploadImages();

    String? uid = _auth.currentUser?.uid;
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      // Generate or use the existing itemId
    final itemId = (widget.itemId.isNotEmpty)
        ? widget.itemId // Use the passed-in itemId
        : DateTime.now().millisecondsSinceEpoch.toString();

      final item = ItemModel(
        id: itemId,
        itemId: itemId,
        uid: uid, // Add the user's UID here
        name: _itemNameController.text,
        description: _descriptionController.text,
        country: selectedCountry,
        link: _linkController.text,
        quantities: _quantityControllers.map((controller) => controller.text).toList(),
        isReplacement: isReplacement,
        replacementDays: _replacementDaysController.text,
        replacementUnit: replacementUnit,
        colors: pickedColors,
        sizes: pickedSizes,
        hideItem: hideItem,
        itemStatus: 'pending',
        imageUrls: imageUrls,
        mrp: double.parse(_mrpController.text),
        sellingPrice: double.parse(_sellingPriceController.text),
        stockInfo: _stockInfoController.text,
      );

      if (_isEditMode) {
        await _firestoreService.updateItem(item);
      } else {
        await _firestoreService.saveItem(item);
      }
     
      // Save to provider
      Provider.of<StoreVerificationProvider>(context, listen: false).saveItem(item);

      if (mounted) {
        showTopSnackBar(context, "Item saved successfully");
      }

      // Navigate and clear stack up to CatalogueScreen
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const CatalogueScreen(),
          ),
          (Route<dynamic> route) => false, // This will clear all routes
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to save item: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isEditMode ? 'Edit Item' : 'Add Item'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          _isEditMode ? 'Edit Item' : 'Add Item',
          style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: ElevatedButton(
              onPressed: isFormValid && !_isSaving ? _saveItem : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isFormValid && !_isSaving ? Colors.black : Colors.grey,
                disabledBackgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4), // Adjust this value to make corners less rounded
                ),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            // Image picker section
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index)  => _buildImagePicker(index)),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Product Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            TextField(
              controller: _itemNameController,
              decoration: const InputDecoration(labelText: 'Item Name*', border: OutlineInputBorder()),
              onChanged: (value) {
                setState(() {
                  // This empty setState will trigger a rebuild and re-evaluate isFormValid
                });
              }
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description*', border: OutlineInputBorder()),
              onChanged: (value) {
                setState(() {
                  // This empty setState will trigger a rebuild and re-evaluate isFormValid
                });
              }
            ),
            const SizedBox(height: 12),

            InkWell(
              onTap: () {
                showCountryPicker(
                  context: context,
                  
                  showPhoneCode: false, // Set to true if you want to display country phone codes
                  countryListTheme: const CountryListThemeData(
                    flagSize: 0,
                    backgroundColor: Colors.white,
                    textStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
                    bottomSheetHeight: 500, // Optional height for the picker
                  ),
                  onSelect: (Country country) {
                    setState(() {
                      selectedCountry = country.name; // Update selected country
                    });
                  },
                );
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Country of origin*',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(selectedCountry),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _linkController,
              decoration: const InputDecoration(
                labelText: 'Link',
                border: OutlineInputBorder(),
                helperText: 'Optional: Enter product website or social media link',
                errorMaxLines: 2,
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: URLValidator.validateURL,
              onChanged: (value) {
                setState(() {
                  // This will trigger rebuild to update the form validation state
                });
              },
            ),
            const SizedBox(height: 24),

            const Text('Pricing Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            TextField(
              controller: _mrpController,
              decoration: const InputDecoration(labelText: '₹ MRP/Retail Price*', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  // This empty setState will trigger a rebuild and re-evaluate isFormValid
                });
              }
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _sellingPriceController,
              decoration: const InputDecoration(labelText: '₹ Selling Price*', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  // This empty setState will trigger a rebuild and re-evaluate isFormValid
                });
              },
            ),
            const SizedBox(height: 24),

            const Text('Stock Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            TextField(
              controller: _stockInfoController,
              decoration: const InputDecoration(labelText: 'Stock info*', border: OutlineInputBorder()),
              onChanged: (value) {
                setState(() {
                  // This empty setState will trigger a rebuild and re-evaluate isFormValid
                });
              }
            ),
            const SizedBox(height: 24),

            const Text('Add Quantity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Column(
              children: [
                for (int i = 0; i < _quantityControllers.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TextField(
                      controller: _quantityControllers[i],
                      decoration: const InputDecoration(labelText: 'Ex: 100 ML, 1000 Kg, etc...*', border: OutlineInputBorder()),
                      onChanged: (value) {
                        setState(() {
                          // This empty setState will trigger a rebuild and re-evaluate isFormValid
                        });
                      }
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => setState(() => _quantityControllers.add(TextEditingController())),
                      child: const Text('+ Add new', style: TextStyle(color: Colors.blue)),
                    ),
                    if (_quantityControllers.length > 1)
                      TextButton(
                        onPressed: () => setState(() {
                          _quantityControllers.last.dispose();
                          _quantityControllers.removeLast();
                        }),
                        child: const Text('- Remove last', style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Replacement*', style: TextStyle(fontSize: 18)),
                Switch(
                  value: isReplacement,
                  onChanged: (value) => setState(() => isReplacement = value),
                  activeColor: Colors.green,
                  inactiveTrackColor: Colors.transparent,
                  inactiveThumbColor: Colors.black,
                  activeTrackColor: Colors.transparent,
                ),
              ],
            ),
            if (isReplacement) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _replacementDaysController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Number', border: OutlineInputBorder()),
                      onChanged: (value) {
                        setState(() {
                          // This empty setState will trigger a rebuild and re-evaluate isFormValid
                        });
                      }
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      dropdownColor: Colors.white,
                      value: replacementUnit,
                      items: ["Days", "Hours"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          replacementUnit = newValue!;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            const Text('Add Colour*', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...pickedColors.map((color) => _buildColorChip(color)),
                if (pickedColors.length < 10)
                  InkWell(
                    onTap: _showColorPicker,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(Icons.add, color: Colors.grey),
                    ),
                  ),
              ],
            ),
            Text('${pickedColors.length}/10 colors selected', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 24),

            const Text('Add Size', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...pickedSizes.map((size) => _buildSizeChip(size)),
                if (pickedSizes.length < 9)
                  InkWell(
                    onTap: _showSizePicker,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(Icons.add, color: Colors.grey),
                    ),
                  ),
              ],
            ),
            Text('${pickedSizes.length}/9 sizes selected', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: hideItem,
                    activeColor: Colors.black,
                    onChanged: (value) {
                      setState(() {
                        hideItem = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      "Hide item, \nWhen you hide an item, customers won't see it in your catalog.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildColorChip(Color color) {
    return InkWell(
      onTap: () {
        setState(() {
          pickedColors.remove(color);
        });
      },
      child: Container(
        //color: Colors.white,
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, color: Colors.white),
      ),
    );
  }

  Widget _buildImagePicker(int index) {
    return InkWell(
      onTap: () => _pickImage(index),
      child: Container(
        width: 150,
        height: 150,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(95, 201, 190, 231),
          borderRadius: BorderRadius.circular(8),
          image: _selectedImages[index] != null
              ? DecorationImage(
                  image: FileImage(_selectedImages[index]!),
                  fit: BoxFit.cover,
                )
              : _existingImageUrls[index] != null
                  ? DecorationImage(
                      image: NetworkImage(_existingImageUrls[index]!),
                      fit: BoxFit.cover,
                    )
                  : null,
        ),
        child: Stack(
          children: [
            if (_selectedImages[index] == null && _existingImageUrls[index] == null)
              const Center(child: Icon(Icons.add_photo_alternate, size: 30)),
            if (_selectedImages[index] != null || _existingImageUrls[index] != null)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedImages[index] = null;
                        _existingImageUrls[index] = null;
                      });
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeChip(String size) {
    return InkWell(
      onTap: () {
        setState(() {
          pickedSizes.remove(size);
        });
      },
      child: Chip(
        label: Text(size),
        onDeleted: () {
          setState(() {
            pickedSizes.remove(size);
          });
        },
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color tempColor = Colors.blue;
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (Color color) {
                tempColor = color;
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                if (pickedColors.length < 10) {
                  setState(() => pickedColors.add(tempColor));
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSizePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Pick a size'),
          content: SingleChildScrollView(
            child: Column(
              // Filter out sizes already in pickedSizes before displaying
              children: ['XXXS','XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL']
                  .where((size) => !pickedSizes.contains(size))
                  .map((size) {
                return ListTile(
                  title: Text(size),
                  onTap: () {
                    // Add size only if it's within the limit and not already picked
                    if (pickedSizes.length < 10) {
                      setState(() => pickedSizes.add(size));
                    }
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    _replacementDaysController.dispose();
    _mrpController.dispose();
    _sellingPriceController.dispose();
    _stockInfoController.dispose();
    for (var controller in _quantityControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}