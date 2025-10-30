import 'package:flutter/material.dart';
import 'package:customer_app/core/constants/appcolors.dart';
import 'package:customer_app/core/constants/appdimensions.dart';

class PhoneInputField extends StatefulWidget {
  const PhoneInputField({super.key});

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  String _selectedCountryCode = '+1';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(
          color: AppColors.secondaryborder,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.marginSmall,
            ),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: AppColors.secondaryborder,
                ),
              ),
            ),
            child: DropdownButton<String>(
              value: _selectedCountryCode,
              icon: const Icon(Icons.arrow_drop_down),
              underline: const SizedBox(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCountryCode = newValue!;
                });
              },
              items: <String>['+1', '+44', '+91', '+86']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppDimensions.marginSmall,
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Enter your mobile number',
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.phone,
              ),
            ),
          ),
        ],
      ),
    );
  }
}