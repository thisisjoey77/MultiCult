import 'package:flutter/material.dart';
import 'globals.dart' as globals;

// Define theme colors
const Color kBackgroundColor = Color(0xFF23272A); // grey black
const Color kCardColor = Color(0xFF1B263B);       // dark blue
const Color kTextColor = Colors.white;

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> with TickerProviderStateMixin {
  bool _languageExpanded = false;

  void _editInfo(String label, String initialValue, ValueChanged<String> onSave) async {
    final controller = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      onSave(result.trim());
    }
  }

  void _editBirthYear() async {
    final currentYear = DateTime.now().year;
    final years = List.generate(100, (i) => (currentYear - i).toString());
    int selectedIndex = years.indexOf(globals.userBirthYear);
    int tempIndex = selectedIndex >= 0 ? selectedIndex : 0;

    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        int pickerIndex = tempIndex;
        return SizedBox(
          height: 250,
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text('Select Birth Year', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 40,
                  controller: FixedExtentScrollController(initialItem: pickerIndex),
                  onSelectedItemChanged: (index) => pickerIndex = index,
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) => Center(
                      child: Text(years[index], style: const TextStyle(fontSize: 20)),
                    ),
                    childCount: years.length,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, years[pickerIndex]),
                child: const Text('Select'),
              ),
            ],
          ),
        );
      },
    );
    if (result != null && result != globals.userBirthYear) {
      setState(() {
        globals.userBirthYear = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Large bolded Settings title
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: kTextColor,
                ),
              ),
              const SizedBox(height: 32),

              // Information Section
              const Text(
                'Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: kTextColor,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: kCardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _InfoRow(
                        label: 'Email',
                        value: globals.userEmail,
                        onEdit: () => _editInfo('Email', globals.userEmail, (val) {
                          setState(() {
                            globals.userEmail = val;
                          });
                        }),
                      ),
                      const Divider(color: Colors.white24),
                      _InfoRow(
                        label: 'Name',
                        value: globals.userName,
                        onEdit: () => _editInfo('Name', globals.userName, (val) {
                          setState(() {
                            globals.userName = val;
                          });
                        }),
                      ),
                      const Divider(color: Colors.white24),
                      _InfoRow(
                        label: 'Birth Year',
                        value: globals.userBirthYear,
                        onEdit: _editBirthYear,
                        isBirthYear: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Language Section
              const Text(
                'Language',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: kTextColor,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: kCardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _languageExpanded = !_languageExpanded;
                            });
                          },
                          child: Row(
                            children: [
                              Text(
                                globals.languages[globals.selectedIndex]['flag']!,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                globals.languages[globals.selectedIndex]['name']!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: kTextColor,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                _languageExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: kTextColor,
                              ),
                            ],
                          ),
                        ),
                        if (_languageExpanded) ...[
                          const Divider(color: Colors.white24),
                          ...List.generate(globals.languages.length, (index) {
                            if (index == globals.selectedIndex) return const SizedBox();
                            return ListTile(
                              leading: Text(
                                globals.languages[index]['flag']!,
                                style: const TextStyle(fontSize: 24),
                              ),
                              title: Text(
                                globals.languages[index]['name']!,
                                style: const TextStyle(color: kTextColor),
                              ),
                              onTap: () {
                                setState(() {
                                  globals.selectedIndex = index;
                                  _languageExpanded = false;
                                });
                              },
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onEdit;
  final bool isBirthYear;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.onEdit,
    this.isBirthYear = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$label: $value',
            style: const TextStyle(fontSize: 16, color: kTextColor),
          ),
        ),
        IconButton(
          icon: Icon(
            isBirthYear ? Icons.calendar_today : Icons.edit,
            color: kTextColor,
          ),
          onPressed: onEdit,
        ),
      ],
    );
  }
}