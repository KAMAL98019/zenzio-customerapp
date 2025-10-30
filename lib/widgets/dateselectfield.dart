import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:customer_app/core/constants/appcolors.dart'; // Make sure you have this import

class DateSelectField extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final Function(DateTime)? onDateSelected;

  const DateSelectField({
    super.key,
    required this.labelText,
    this.hintText,
    this.onDateSelected,
  });

  @override
  State<DateSelectField> createState() => _DateSelectFieldState();
}

class _DateSelectFieldState extends State<DateSelectField> {
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            primaryColor: AppColors.primary,
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
      if (widget.onDateSelected != null) {
        widget.onDateSelected!(_selectedDate!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      onTap: () => _selectDate(context),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: const TextStyle(color: AppColors.primary, fontSize: 18),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryborder),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryborder, width: 1.0),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryborder),
        ),
        suffixIcon: IconButton(
          onPressed: () => _selectDate(context),
          icon: const Icon(Icons.calendar_today_outlined),
          color: AppColors.primary,
        ),
      ),
    );
  }
}
