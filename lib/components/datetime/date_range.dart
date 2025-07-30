import 'package:flutter/material.dart';

class DateRangePickerFormField extends StatefulWidget {
  final void Function(DateTimeRange?) onChanged;
  final DateTimeRange? initialValue;

  const DateRangePickerFormField({
    super.key,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<DateRangePickerFormField> createState() => _DateRangePickerFormFieldState();
}

class _DateRangePickerFormFieldState extends State<DateRangePickerFormField> {
  DateTimeRange? selectedRange;

  @override
  void initState() {
    super.initState();
    selectedRange = widget.initialValue;
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDateRange: selectedRange,
    );
    if (picked != null) {
      setState(() {
        selectedRange = picked;
      });
      widget.onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = selectedRange == null
        ? 'Select date range'
        : '${selectedRange!.start.toLocal().toString().split(' ')[0]} - ${selectedRange!.end.toLocal().toString().split(' ')[0]}';

    return InkWell(
      onTap: () => _pickDateRange(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date range',
          border: OutlineInputBorder(),
        ),
        child: Text(text),
      ),
    );
  }
}
