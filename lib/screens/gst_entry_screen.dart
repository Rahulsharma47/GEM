import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gem_biz_app/widgets/snackbar.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

class GstEntryScreen extends StatefulWidget {
  final String? initialGstNumber;
  final String? initialGstFilePath;
  final String? initialGstFileType;
  final String? existingGstFileUrl;

  const GstEntryScreen({
    super.key,
    this.initialGstNumber,
    this.initialGstFilePath,
    this.initialGstFileType,
    this.existingGstFileUrl,
  });

  @override
  // ignore: library_private_types_in_public_api
  _GstEntryScreenState createState() => _GstEntryScreenState();
}

class _GstEntryScreenState extends State<GstEntryScreen> {
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _otherFieldController = TextEditingController();
  String? _gstFilePath;
  String? _gstFileType;
  bool _hasExistingFile = false;
  //bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _gstController.text = widget.initialGstNumber?.toUpperCase() ?? '';
    _gstFilePath = widget.initialGstFilePath;
    _gstFileType = widget.initialGstFileType;
    _hasExistingFile = widget.existingGstFileUrl != null && widget.existingGstFileUrl!.isNotEmpty;
    _gstController.addListener(_checkFields);
    _otherFieldController.addListener(_checkFields);
  }

  void _checkFields() {
    setState(() {
      // Enable button only if GST field has exactly 15 characters and other field is filled
      //isButtonEnabled = _gstController.text.length == 15 && _otherFieldController.text.isNotEmpty;
    });
  }

  void _clearSelectedFile() {
    setState(() {
      _gstFilePath = null;
      _gstFileType = null;
      _hasExistingFile = false;
    });
  }

  void _submitData() {
    if (_gstController.text.isEmpty) {
      Navigator.pop(context, {
        'gstNumber': '',
        'gstFilePath': null,
        'gstFileType': null,
        'keepExistingFile': false,
      });
      return;
    }
    
    if (_gstController.text.length != 15) {
      showTopSnackBar(context, 'Please enter a valid 15-character GST number');
      return;
    }

    if (!_hasExistingFile && _gstFilePath == null) {
      showTopSnackBar(context, 'Please attach GST document');
      return;
    }

    Navigator.pop(context, {
      'gstNumber': _gstController.text,
      'gstFilePath': _gstFilePath,
      'gstFileType': _gstFileType ?? widget.initialGstFileType,
      'keepExistingFile': _hasExistingFile,
    });
  }

  @override
  void dispose() {
    _gstController.dispose();
    _otherFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('GST Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _submitData,
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _gstController,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                UpperCaseTextFormatter(),
                LengthLimitingTextInputFormatter(15),
              ],
              maxLength: 15,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Enter GST Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: theme.unselectedWidgetColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  margin: const EdgeInsets.only(top: 8),
                  child: InkWell(
                    onTap: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'jpeg', 'png', 'heic', 'heif', 'pdf'],
                        allowMultiple: false,
                      );

                      if (result != null && result.files.single.path != null) {
                        setState(() {
                          _gstFilePath = result.files.single.path;
                          _gstFileType = path.extension(_gstFilePath!).toLowerCase();
                          _hasExistingFile = false;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            _hasExistingFile
                                ? (widget.initialGstFileType == '.pdf' ? Icons.picture_as_pdf : Icons.image)
                                : (_gstFileType == '.pdf' ? Icons.picture_as_pdf : Icons.image),
                            color: Colors.black,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _hasExistingFile
                                  ? (widget.existingGstFileUrl != null && widget.existingGstFileUrl!.isNotEmpty
                                      ? path.basename(Uri.parse(widget.existingGstFileUrl!).pathSegments.last).length > 30
                                          ? '${path.basename(Uri.parse(widget.existingGstFileUrl!).pathSegments.last).substring(0, 30)}...'
                                          : path.basename(Uri.parse(widget.existingGstFileUrl!).pathSegments.last)
                                      : 'No file attached')
                                  : _gstFilePath != null
                                      ? ' ${path.basename(_gstFilePath!).length > 30 
                                          ? '${path.basename(_gstFilePath!).substring(0, 30)}...' 
                                          : path.basename(_gstFilePath!)}'
                                      : 'Browse to choose a file (Image or PDF)',
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ),
                          if (_hasExistingFile || _gstFilePath != null)
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: _clearSelectedFile,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              splashRadius: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    color: Colors.white,
                    child: Text(
                      'Upload GST Document',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.unselectedWidgetColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 300,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitData,  // Enable based on isButtonEnabled
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
