import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../localization/app_strings.dart';

class VatRateDropdown extends StatelessWidget {
  final int selectedVatRate;
  final Function(int?) onChanged;

  const VatRateDropdown({
    super.key,
    required this.selectedVatRate,
    required this.onChanged,
  });

  String _getVatRateLabel(int rate) {
    switch (rate) {
      case 0:
        return AppStrings.vatRateZero;
      case 7:
        return AppStrings.vatRateSeven;
      case 23:
        return AppStrings.vatRateTwentyThree;
      default:
        return '$rate%';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: AppStrings.vatRateLabel,
        border: const OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedVatRate,
          isDense: true,
          onChanged: onChanged,
          items: AppConstants.vatRates.map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text(_getVatRateLabel(value)),
            );
          }).toList(),
        ),
      ),
    );
  }
}