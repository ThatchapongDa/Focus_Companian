import 'package:flutter/material.dart';

class NumberPicker extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final int value;
  final ValueChanged<int> onChanged;
  final String suffix;
  final int step;

  const NumberPicker({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.value,
    required this.onChanged,
    this.suffix = '',
    this.step = 1,
  });

  @override
  State<NumberPicker> createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPicker> {
  late FixedExtentScrollController _scrollController;
  late List<int> _values;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _values = _generateValues();
    final initialIndex = _values.indexOf(widget.value);
    _selectedIndex = initialIndex >= 0 ? initialIndex : 0;
    _scrollController = FixedExtentScrollController(
      initialItem: _selectedIndex!,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<int> _generateValues() {
    final values = <int>[];
    for (int i = widget.minValue; i <= widget.maxValue; i += widget.step) {
      values.add(i);
    }
    return values;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Selection highlight
          Center(
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.5),
                  width: 2,
                ),
              ),
            ),
          ),
          // Number wheel
          ListWheelScrollView.useDelegate(
            controller: _scrollController,
            itemExtent: 50,
            physics: const FixedExtentScrollPhysics(),
            diameterRatio: 1.5,
            perspective: 0.003,
            onSelectedItemChanged: (index) {
              setState(() => _selectedIndex = index);
              widget.onChanged(_values[index]);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: _values.length,
              builder: (context, index) {
                final value = _values[index];
                final isSelected = index == _selectedIndex;

                return Center(
                  child: Text(
                    '$value${widget.suffix}',
                    style: TextStyle(
                      fontSize: isSelected ? 32 : 20,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
