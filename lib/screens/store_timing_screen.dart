// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gem_biz_app/providers/store_data_provider.dart';
import 'package:gem_biz_app/widgets/snackbar.dart';


class StoreTimingsScreen extends StatefulWidget {
  const StoreTimingsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StoreTimingsScreenState createState() => _StoreTimingsScreenState();
}

class _StoreTimingsScreenState extends State<StoreTimingsScreen> {
  late StoreDataProvider _storeDataProvider;
  bool _isInitialized = false;


@override
  void initState() {
    super.initState();
    _timeSlots = Map.from(_defaultTimeSlots);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _storeDataProvider = Provider.of<StoreDataProvider>(context, listen: false);
      _initializeData();
      _isInitialized = true;
    }
  }

  Future<void> _initializeData() async {
    await _storeDataProvider.fetchStoreData();
    
    setState(() {
      _selectedOption = _storeDataProvider.storeData.availability;
      _timeSlots = Map.from(_storeDataProvider.storeData.storeTimes);
      _selectedDays = List.from(_storeDataProvider.storeData.selectedDays);
      
      // Update store open status based on time slots
      _storeOpenStatus = Map.fromEntries(
        _timeSlots.entries.map((e) => MapEntry(e.key, e.value.isNotEmpty))
      );
    });
  }

  void toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
        _storeOpenStatus[day] = false;
        _timeSlots[day] = [];
      } else {
        _selectedDays.add(day);
        _storeOpenStatus[day] = true;
        if (_timeSlots[day]?.isEmpty ?? true) {
          _timeSlots[day] = [TimeSlot()];
        }
      }
      _storeDataProvider.updateSelectedDays(_selectedDays);
    });
  }

  String _selectedOption = 'Available 24/7';
  List<String> _selectedDays = [];
  Map<String, bool> _storeOpenStatus = {
    'Sunday': false,
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
  };
  final Map<String, List<TimeSlot>> _defaultTimeSlots = {
    'Sunday': [],
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
  };
  late Map<String, List<TimeSlot>> _timeSlots;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Timings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Availability',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  _buildRadioOption('Available 24/7'),
                  _buildRadioOption('Pick days'),
                ],
              ),
              const SizedBox(height: 16),
              if (_selectedOption == 'Pick days')
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'].map((day) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: _buildDayRow(day),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),
               Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedOption == 'Pick days' && !_validateTimings()) {
                      showTopSnackBar(context, 'Please select timings for all open days');
                    } else {
                      _storeDataProvider.updateStoreTimes(_timeSlots);
                      _storeDataProvider.updateAvailability(_selectedOption);
                      Navigator.pop(context, _storeDataProvider.getFormattedStoreTimes());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Save'),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateTimings() {
    bool atLeastOneDayOpen = false;
    for (String day in _storeOpenStatus.keys) {
      if (_storeOpenStatus[day] == true) {
        atLeastOneDayOpen = true;
        if (_timeSlots[day]!.isEmpty) {
          return false;
        }
        for (TimeSlot slot in _timeSlots[day]!) {
          if (slot.openTime == null || slot.closeTime == null) {
            return false;
          }
        }
      }
    }
    return atLeastOneDayOpen;
  }

  Widget _buildDayRow(String day) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day Header with Toggle and Add Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(day, style: const TextStyle(fontSize: 16)),
            Row(
              children: [
                CustomSwitch(
                  value: _storeOpenStatus[day]!,
                  onChanged: (value) {
                    setState(() {
                      _storeOpenStatus[day] = value;
                      if (!value) {
                        _timeSlots[day]!.clear();
                      } else if (_timeSlots[day]!.isEmpty) {
                        _timeSlots[day]!.add(TimeSlot());
                      }
                    });
                  },
                ),
                if (_storeOpenStatus[day]!)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      setState(() {
                        _timeSlots[day]!.add(TimeSlot());
                      });
                    },
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        // List of TimeSlots
        if (_storeOpenStatus[day]!)
          Column(
            children: _timeSlots[day]!.map((slot) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: _buildTimeSlotRow(day, slot),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildTimeSlotRow(String day, TimeSlot slot) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final times = await _selectOpenCloseTimes(context);
                if (times != null) {
                  setState(() {
                    slot.openTime = times[0];
                    slot.closeTime = times[1];
                  });
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Open & Close Time',
                    border: const OutlineInputBorder(),
                    hintText: _formatTimeSlot(slot),
                  ),
                  controller: TextEditingController(text: _formatTimeSlot(slot)),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: () {
              setState(() {
                _timeSlots[day]!.remove(slot);
              });
            },
          ),
        ],
      ),
    );
  }

  Future<List<TimeOfDay>?> _selectOpenCloseTimes(BuildContext context) async {
    // Select Opening Time
    final openTime = await _selectTime(context, 'Select Opening Time');
    if (openTime == null) return null;

    // Select Closing Time
    final closeTime = await _selectTime(context, 'Select Closing Time');
    if (closeTime == null) return null;

    // Validate that closing time is after opening time
    final openDateTime = DateTime(0, 0, 0, openTime.hour, openTime.minute);
    final closeDateTime = DateTime(0, 0, 0, closeTime.hour, closeTime.minute);
    if (closeDateTime.isBefore(openDateTime) || closeDateTime.isAtSameMomentAs(openDateTime)) {
      showTopSnackBar(context, 'Closing time must be after opening time');
      return null;
    }

    return [openTime, closeTime];
  }

  Future<TimeOfDay?> _selectTime(BuildContext context, String label) async {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: label,
    );
  }

  String _formatTimeSlot(TimeSlot slot) {
    if (slot.openTime == null || slot.closeTime == null) return 'Not set';
    return '${_formatTimeOfDay(slot.openTime)} - ${_formatTimeOfDay(slot.closeTime)}';
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  Widget _buildRadioOption(String title) {
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      value: title,
      activeColor: Colors.black,
      groupValue: _selectedOption,
      onChanged: (value) {
        setState(() {
          _selectedOption = value!;
          if (_selectedOption == 'Available 24/7') {
            // If 24/7 is selected, clear all selected days
            _storeOpenStatus.updateAll((key, value) => false);
            _timeSlots.updateAll((key, value) => []);
          }
        });
      },
    );
  }
}

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 100,
        height: 35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: value ? Colors.green : Colors.red,
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 65 : 0,
              right: value ? 0 : 65,
              top: 2.5,
              bottom: 2.5,
              child: Container(
                width: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
            Center(
              child: Text(
                value ? 'Open    ' : '     Closed',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

