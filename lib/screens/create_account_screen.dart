// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gem_biz_app/screens/gst_entry_screen.dart';
import 'package:latlong2/latlong.dart';
import 'business_category_screen.dart';
import 'store_timing_screen.dart';
import 'package:provider/provider.dart';
import 'package:gem_biz_app/providers/store_data_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:gem_biz_app/providers/location_provider.dart';
import 'package:gem_biz_app/screens/openstreetmap_screen.dart';
import 'package:gem_biz_app/screens/catalouge_screen.dart'; // Add this import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gem_biz_app/providers/auth_provider.dart';
import 'package:gem_biz_app/widgets/snackbar.dart';


class CreateBusinessAccountScreen extends StatefulWidget {
  final String? docId;
  const CreateBusinessAccountScreen({super.key, this.docId});

  @override
  // ignore: library_private_types_in_public_api
  _CreateBusinessAccountScreenState createState() => _CreateBusinessAccountScreenState();
}

class _CreateBusinessAccountScreenState extends State<CreateBusinessAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  String _businessRole = 'owner';
  String _gstNumber = '';
  String? _gstFilePath;
  String? _gstFileType;
  String _businessCategory = '';
  String _storeTimings = '';
  String? _attachedImagePath;
  bool _isLoading = false;
  String? _existingLogoUrl; // Add this variable to store existing logo URL
// Add this for GST file URL
  final TextEditingController _businessCategoryController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _displayWebsiteController = TextEditingController();
  String _actualWebsiteValue = '';
  String? _userEmail; // Add this variable to store the email

  @override
  void initState() {
    super.initState();
    if (widget.docId != null) {
      _loadExistingData();
    }
     WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      setState(() {
        _userEmail = authProvider.currentUser?.email;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storeDataProvider = Provider.of<StoreDataProvider>(context, listen: false);
      setState(() {
        _storeTimings = storeDataProvider.getFormattedStoreTimes();
      });
    });
    websiteController.addListener(() {
      if (websiteController.text.isNotEmpty) {
        _displayWebsiteController.text = websiteController.text.replaceAll(RegExp(r'https?://'), '');
      }
    });
  }

  String? _validateWebsite(String? value) {
  if (value == null || value.isEmpty) {
    return null;  // Website is optional
  }

  // Basic URL pattern without requiring http/https prefix
  final urlPattern = RegExp(
    r'^[\w-]+(\.[\w-]+)+([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?$',
    caseSensitive: false,
  );

  if (!urlPattern.hasMatch(value)) {
    return 'Please enter a valid website URL';
    //showTopSnackBar(context, 'Please enter a valid website URL');
    //testreturn ' ';
  }

  return null;
}

  Future<void> _loadExistingData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('bregisterbusiness')
          .doc(widget.docId)
          .get();

          if (doc.exists) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            // Load existing data into the StoreDataProvider
            final storeDataProvider = Provider.of<StoreDataProvider>(context, listen: false);
            
            String website = data['website'] as String? ?? '';
            websiteController.text = website;
            _actualWebsiteValue = website;
            
            // Update store availability
            if (data['availability'] != null) {
              storeDataProvider.updateAvailability(data['availability']);
            }

          // Update store times
          if (data['storeTimes'] != null) {
          Map<String, List<TimeSlot>> parsedTimes = {};
          Map<String, dynamic> storeTimes = Map<String, dynamic>.from(data['storeTimes'] as Map);
          
          storeTimes.forEach((day, slots) {
            if (slots is List) {
              parsedTimes[day] = (slots).map((slot) {
                if (slot is Map) {
                  return TimeSlot.fromMap(Map<String, dynamic>.from(slot));
                }
                return TimeSlot.fromMap(slot as Map<String, dynamic>);
              }).toList();
            }
          });
          storeDataProvider.updateStoreTimes(parsedTimes);
        }
        setState(() {
          _businessCategoryController.text = data['category'] as String? ?? '';
          _businessCategory = data['category'] as String? ?? '';
          _businessNameController.text = data['name'] as String? ?? '';
          _descriptionController.text = data['description'] as String? ?? '';
          _gstNumber = (data['gst'] as Map<String, dynamic>?)?['gst_no'] as String? ?? '';
          _gstController.text = (data['gst'] as Map<String, dynamic>?)?['gst_no'] as String? ?? '';
          _gstFileType = (data['gst'] as Map<String, dynamic>?)?['gst_file_type'] as String?;
          _userEmail = data['email'] as String? ?? '';
          websiteController.text = data['website'] as String? ?? '';
          mobileController.text = data['mobile'] as String? ?? '';
          userNameController.text = data['user_name'] as String? ?? '';
          _storeTimings = data['store_timings'] as String? ?? '';
          _businessRole = data['user_type'] as String? ?? 'owner';
          _addressController.text = data['address'] as String? ?? '';
          _existingLogoUrl = data['logo_image_url'] as String?; // Store the existing logo URL
        });        
        final String savedAddress = data['address'] as String? ?? '';
      if (savedAddress.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<LocationProvider>(context, listen: false)
              .setAddressOnly(savedAddress);
        });
      }
    }
  } catch (e) {
    print('Error loading existing data: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    final storeDataProvider = Provider.of<StoreDataProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Create Business Account"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              _buildBusinessLogoPicker(),
              const SizedBox(height: 16),
              _buildBusinessCategoryField(),
              const SizedBox(height: 16),
              _buildBusinessNameField(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 16),
              _buildStoreTimingsField(storeDataProvider),
              const SizedBox(height: 16),
              _buildTextField('Website', Icons.web),
              const SizedBox(height: 16),
              _buildGstNumberField(),
              const SizedBox(height: 16),
              _buildLocationButton(context),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildBusinessRoleSection(),
              const SizedBox(height: 16),
              _buildTextField('Name*', Icons.person, validator: (value) {
                if (value!.isEmpty) return 'Name is required';
                return null;
              }),
              const SizedBox(height: 16),
              _buildMobileNumberField(),
              const SizedBox(height: 32),
              _buildCreateAccountButton(storeDataProvider),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileNumberField() {
      return TextFormField(
        controller: mobileController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        decoration: InputDecoration(
          labelText: 'Mobile number*',
          prefixIcon: const Icon(Icons.phone),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) return 'Mobile number is required';
          if (value.length != 10) return 'Mobile number must be 10 digits';
          return null;
        },
      );
    }

  Widget _buildBusinessLogoPicker() {
  return InkWell(
    onTap: () async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _attachedImagePath = result.files.single.path!;
        });
      }
    },
    child: Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[300],
          backgroundImage: _attachedImagePath != null
              ? FileImage(File(_attachedImagePath!))
              : (_existingLogoUrl != null && _existingLogoUrl!.isNotEmpty)
                  ? NetworkImage(_existingLogoUrl!) as ImageProvider
                  : null,
        ),
        Positioned(
          bottom: 8,
          right: 140,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(1),
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.camera_alt_outlined, size: 20, color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );
}


  Future<String> uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      String fileName = path.basename(imageFile.path);
      final fileRef = storageRef.child("business_logos/$fileName");
      UploadTask uploadTask = fileRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }

  Widget _buildBusinessCategoryField() {
    return _buildFieldWithArrow('Business Category*', _businessCategoryController, () async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BusinessCategoryScreen()),
      );
      if (result != null && result is String) {
        setState(() {
          _businessCategory = result;
          _businessCategoryController.text = result;
        });
      }
    });
  }

  Widget _buildFieldWithArrow(String label, TextEditingController controller, VoidCallback onTap) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.receipt),
        suffixIcon: const Icon(Icons.arrow_forward),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onTap: onTap,
      validator: (value) {
        if (value!.isEmpty) return '$label is required';
        return null;
      },
    );
  }

  Widget _buildBusinessNameField() {
    return TextFormField(
      controller: _businessNameController,
      maxLength: 50,
      maxLines: null,  // This allows multiple lines
      decoration: InputDecoration(
        labelText: 'Business Name*',
        prefixIcon: const Icon(Icons.business),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            '${_businessNameController.text.length}/50',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        counterText: '',
      ),
      validator: (value) {
        if (value!.isEmpty) return 'Business Name is required';
        return null;
      },
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLength: 300,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Description of the business*',
        prefixIcon: const Icon(Icons.description),
        suffixIcon: Align(
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0),
            child: Text(
              '${_descriptionController.text.length}/300',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        counterText: '',
      ),
      validator: (value) {
        if (value!.isEmpty) return 'Description is required';
        return null;
      },
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  Widget _buildTextField(String labelText, IconData icon, {FormFieldValidator<String>? validator}) {
  if (labelText == 'Website') {
    return TextFormField(
      controller: _displayWebsiteController,  // Use display controller instead
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        helperText: 'Optional. Example: www.example.com',
      ),
      validator: _validateWebsite,
      onChanged: (value) {
        if (value.isNotEmpty) {
          // Store the actual value with https:// internally
          _actualWebsiteValue = !value.startsWith('http://') && !value.startsWith('https://')
              ? 'https://$value'
              : value;
          
          // Update the actual website controller
          websiteController.text = _actualWebsiteValue;
        } else {
          _actualWebsiteValue = '';
          websiteController.text = '';
        }
      },
    );
  }
  
  // Rest of the original code for other fields remains the same
  return TextFormField(
    controller: labelText == 'Mobile number*' ? mobileController 
              : labelText == 'Name*' ? userNameController
              : null,
    decoration: InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    validator: validator,
  );
}

  Widget _buildGstNumberField() {
    return TextFormField(
      readOnly: true,
      controller: _gstController,
      decoration: InputDecoration(
        labelText: 'GST Details', // Added asterisk to indicate required field
        prefixIcon: const Icon(Icons.receipt),
        suffixIcon: const Icon(Icons.arrow_forward),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onTap: () async {
        String? existingGstUrl;
        if (widget.docId != null) {
          existingGstUrl = await _getExistingGstFileUrl();
        }
        if (!mounted) return;
        
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GstEntryScreen(
            initialGstNumber: _gstNumber,
            initialGstFileType: _gstFileType,
            initialGstFilePath: _gstFilePath,
            existingGstFileUrl: existingGstUrl,
          )),
        );
        
        if (result != null) {
          setState(() {
            _gstNumber = result['gstNumber'] ?? '';
            _gstController.text = result['gstNumber'] ?? ''; // Update the controller text
            if (!result['keepExistingFile']) {
              _gstFilePath = result['gstFilePath'];
              _gstFileType = result['gstFileType'];
            }
          });
        }
      },
    );
  }

 Widget _buildLocationButton(BuildContext context) {
  return FormField<String>(
    validator: (value) {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      if (locationProvider.address == null || locationProvider.address!.isEmpty) {
        return 'Business address is required';
      }
      return null;
    },
    builder: (FormFieldState<String> state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<LocationProvider>(
            builder: (context, locationProvider, child) {
              return GestureDetector(
                onTap: () => _openMapsScreen(context, locationProvider),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.grey[300],
                    border: state.hasError 
                        ? Border.all(color: Colors.red, width: 1.0)
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0),
                        ),
                        child: Stack(
                          children: [
                            Image.asset(
                              'assets/images/maps.png',
                              width: double.infinity,
                              height: 150.0,
                              fit: BoxFit.cover,
                            ),
                            Positioned.fill(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                                child: Container(
                                  color: Colors.black.withOpacity(0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12.0),
                            bottomRight: Radius.circular(12.0),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, size: 24.0, color: Colors.black),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                locationProvider.address ?? 'Pin Business Location',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(fontSize: 16.0, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 8),
              child: Text(
                state.errorText!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    },
  );
}



  Future<void> _openMapsScreen(BuildContext context, LocationProvider locationProvider) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OpenStreetMapPage()),
    );
    if (result != null && result['location'] != null && result['address'] != null) {
    locationProvider.setLocation(
      result['location'] as LatLng,
      result['address'] as String
    );
  }
  }

  Widget _buildBusinessRoleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Are you the owner/manager of this business?*',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildRadioButton('I\'m the Business owner', 'Owner'),
        _buildRadioButton('I\'m the Incharge/Manager', 'Manager'),
        _buildRadioButton('I\'m an Employee', 'Employee'),
      ],
    );
  }

  Widget _buildRadioButton(String title, String value) {
    return RadioListTile(
      title: Text(title),
      value: value,
      groupValue: _businessRole,
      activeColor: Colors.black,
      onChanged: (value) {
        setState(() {
          _businessRole = value.toString();
        });
      },
    );
  }

  Widget _buildStoreTimingsField(StoreDataProvider storeDataProvider) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StoreTimingsScreen()),
        );
        if (result != null) {
          setState(() {
            _storeTimings = storeDataProvider.getFormattedStoreTimes();
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Store Timings*',
            hintText: _storeTimings.isEmpty ? 'Tap to set store timings' : null,
            prefixIcon: const Icon(Icons.access_time),
            suffixIcon: const Icon(Icons.arrow_forward),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          controller: TextEditingController(text: _storeTimings),
          validator: (value) {
            if (storeDataProvider.storeData.availability == 'Pick days' &&
                storeDataProvider.storeData.storeTimes.isEmpty) {
              return 'Store Timings are required';
            }
            return null;
          },
        ),
      ),
    );
  }

  Map<String, dynamic> _prepareStoreTimesData(StoreDataProvider storeDataProvider) {
    return {
      'storeTimes': storeDataProvider.storeData.storeTimes.map((key, value) {
        return MapEntry(key, value.map((slot) => slot.toMap()).toList());
      }),
      'store_timings': storeDataProvider.getFormattedStoreTimes(),
      'availability': storeDataProvider.storeData.availability,
    };
  }

Widget _buildCreateAccountButton(StoreDataProvider storeDataProvider) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Visibility(
            visible: !_isLoading,
            child: ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  // Show snackbar for any validation failure
                  showTopSnackBar(context, 'Please fill all required fields correctly');
                  return;
                }

                if (widget.docId != null) {
                  final bool? proceed = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.black,
                        title: const Text('Account Verification'),
                        content: const Text('Your account will be sent for verification again. It might take 3-5 business days to verify your business account.'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel', style: TextStyle(color: Colors.black,),),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          TextButton(
                            child: const Text('Proceed', style: TextStyle(color: Colors.black),),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ],
                      );
                    },
                  );
                  
                  if (proceed != true) return;
                }             
                setState(() {
                  _isLoading = true;
                });
                
                try {
                  String? logoImageUrl;
                  String? gstFileUrl;
                  String? existingGstFileUrl;

                  if (widget.docId != null) {
                    existingGstFileUrl = await _getExistingGstFileUrl();
                  }

                  if (_attachedImagePath != null) {
                    logoImageUrl = await uploadFile(File(_attachedImagePath!), 'business_logos');
                  }

                  if (_gstFilePath != null) {
                    gstFileUrl = await uploadFile(File(_gstFilePath!), 'gst_files');
                  }

                  final locationProvider = Provider.of<LocationProvider>(context, listen: false);
                  String? uid = FirebaseAuth.instance.currentUser?.uid;

                  Map<String, dynamic> businessData = {
                    'storeverified': false,
                    'category': _businessCategory.isNotEmpty ? _businessCategory : _businessCategoryController.text,
                    'name': _businessNameController.text,
                    'description': _descriptionController.text,
                    'storeTimes': storeDataProvider.storeData.storeTimes.map((key, value) {
                      return MapEntry(key, value.map((slot) => slot.toMap()).toList());
                    }),
                    'store_timings': storeDataProvider.getFormattedStoreTimes(),
                    ..._prepareStoreTimesData(storeDataProvider),
                    'email': _userEmail,
                    'website': websiteController.text,
                    'gst': {
                      'gst_file_url': gstFileUrl ?? existingGstFileUrl ?? '',
                      'gst_file_type': _gstFileType ?? (widget.docId != null ? await _getExistingGstFileType() : ''),
                      'gst_no': _gstNumber,
                    },
                    'logo_image_url': logoImageUrl ?? _existingLogoUrl ?? '',
                    'mobile': mobileController.text,
                    'address': locationProvider.address ?? '',
                    'user_type': _businessRole,
                    'user_name': userNameController.text,
                    'uid': uid,
                  };
                  
                  if (widget.docId != null) {
                    await FirebaseFirestore.instance
                        .collection('bregisterbusiness')
                        .doc(widget.docId)
                        .update(businessData);
                    
                    if (mounted) {
                      showTopSnackBar(context, 'Account updated successfully');
                      Navigator.pop(context);
                    }
                  } else {
                    DocumentReference docRef = await FirebaseFirestore.instance
                        .collection('bregisterbusiness')
                        .add(businessData);

                    if (mounted) {
                      final storeProvider = Provider.of<StoreDataProvider>(context, listen: false);
                      final appAuthProvider = Provider.of<AppAuthProvider>(context, listen: false);
                      storeProvider.updateBusiness(businessData, docRef.id);
                      await Future.wait([
                        appAuthProvider.setLastScreen('catalogue'),
                      ]);
                      
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CatalogueScreen(),
                        ), 
                        (route) => false,
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    showTopSnackBar(context, 'Error: $e');
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                widget.docId != null ? 'UPDATE ACCOUNT' : 'CREATE ACCOUNT',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (_isLoading)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 50,
                color: Colors.black,
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Please wait...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
}

  Future<String?> _getExistingGstFileUrl() async {
  if (widget.docId == null) return null;
  final doc = await FirebaseFirestore.instance
      .collection('bregisterbusiness')
      .doc(widget.docId)
      .get();
  return (doc.data()?['gst'] as Map<String, dynamic>?)?['gst_file_url'] as String?;
}

Future<String?> _getExistingGstFileType() async {
  if (widget.docId == null) return null;
  final doc = await FirebaseFirestore.instance
      .collection('bregisterbusiness')
      .doc(widget.docId)
      .get();
  return (doc.data()?['gst'] as Map<String, dynamic>?)?['gst_file_type'] as String?;
}

   Future<String> uploadFile(File file, String folderName) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      String fileName = path.basename(file.path);
      final fileRef = storageRef.child("$folderName/$fileName");
      UploadTask uploadTask = fileRef.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading file: $e");
      return '';
    }
  }
  @override
  void dispose() {
    _displayWebsiteController.dispose();
    // ... other existing disposals ...
    super.dispose();
  }
}