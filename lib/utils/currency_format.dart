import 'package:flutter/cupertino.dart';
import 'package:money2/money2.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';

import '../models/currency_model.dart';
import '../provider/app_provider.dart';
import '../provider/general_settings_provider.dart';
import '../provider/home_provider.dart';

// Helper function to generate currency pattern
String getPattern(String thousandSeparator, String decimalSeparator, int decimalNumber, String leftSymbol, String rightSymbol) {
  if (decimalNumber == 0) {
    return '$leftSymbol#$thousandSeparator###$rightSymbol'; // No decimal places for whole numbers
  } else {
    return '$leftSymbol#$thousandSeparator###$decimalSeparator##0$rightSymbol'; // Two decimal places for fractional numbers
  }
}String stringToCurrency(num idr, BuildContext context, {CurrencyModel? currencyDetail}) {
  final currencySetting = Provider.of<HomeProvider>(context, listen: false);
  final appLanguage = Provider.of<AppNotifier>(context, listen: false);
  final generalCurrency = Provider.of<GeneralSettingsProvider>(context, listen: false);

  var symbol = 'AED'; // Default symbol
  String? code = 'IDR';
  var thousandSeparator = '.';
  var decimalSeparator = ',';
  var decimalNumber = 2; // Default to two decimal places
  var currencyPos = "left";

  // Update symbol and currency rate if activated
  if (currencySetting.activateCurrency) {
    symbol = generalCurrency.selectedCurrency != null
        ? convertHtmlUnescape(generalCurrency.selectedCurrency!.symbol!)
        : "";
    code = generalCurrency.selectedCurrency!.name;
    currencyPos = generalCurrency.selectedCurrency!.position!;
    idr = idr * generalCurrency.selectedCurrency!.rate!;
  } else {
    symbol = currencySetting.currency.description != null
        ? convertHtmlUnescape(currencySetting.currency.description!)
        : '';
    code = currencySetting.currency.title;
    currencyPos = currencySetting.currency.position!;
  }

  // Override symbol and position if currency detail is provided
  if (currencyDetail != null) {
    symbol = convertHtmlUnescape(currencyDetail.symbol!);
    code = currencyDetail.name;
    currencyPos = currencyDetail.position!;
  }

  // Translation logic between "QR", "ق.ر", and "ر.ق"
  if (appLanguage.appLocal == Locale("ar")) {
    // Arabic locale
    if (symbol == 'QR') {
      symbol = 'ق.ر'; // Change QR to ق.ر for Arabic
    } else if (symbol == 'ر.ق') {
      symbol = 'ق.ر'; // Keep ر.ق as ق.ر for Arabic
    }
  } else {
    // Other locales (e.g., English)
    if (symbol == 'ق.ر') {
      symbol = 'QR'; // Change ق.ر to QR for English or other locales
    } else if (symbol == 'ر.ق') {
      symbol = 'QR'; // Change ر.ق to QR for English or other locales
    }
  }

  // Set thousand and decimal separators
  thousandSeparator = currencySetting.formatCurrency.image ?? ".";
  decimalSeparator = currencySetting.formatCurrency.title ?? ",";

  if (thousandSeparator == '.' && decimalSeparator == '.') {
    decimalSeparator = ',';
  } else if (thousandSeparator == ',' && decimalSeparator == ',') {
    decimalSeparator = '.';
  }

  // Determine the number of decimal places based on the value
  decimalNumber = (idr == idr.toInt()) ? 0 : 2; // Use 0 for whole numbers, 2 for decimals

  // Generate currency pattern based on locale and currency position
  String pattern = '';
  if (appLanguage.appLocal == Locale("ar")) {
    // Arabic locale
    if (currencyPos == 'left') {
      pattern = getPattern(thousandSeparator, decimalSeparator, decimalNumber, "S", "");
    } else if (currencyPos == 'left_space') {
      pattern = getPattern(thousandSeparator, decimalSeparator, decimalNumber, "S ", "");
    } else if (currencyPos == 'right') {
      pattern = getPattern(thousandSeparator, decimalSeparator, decimalNumber, "", "S");
    } else if (currencyPos == 'right_space') {
      pattern = getPattern(thousandSeparator, decimalSeparator, decimalNumber, "", " S");
    }
  } else {
    // Other locales
    if (currencyPos == 'left') {
      pattern = getPattern(thousandSeparator, decimalSeparator, decimalNumber, "S", "");
    } else if (currencyPos == 'left_space') {
      pattern = getPattern(thousandSeparator, decimalSeparator, decimalNumber, "S ", "");
    } else if (currencyPos == 'right') {
      pattern = getPattern(thousandSeparator, decimalSeparator, decimalNumber, "", "S");
    } else if (currencyPos == 'right_space') {
      pattern = getPattern(thousandSeparator, decimalSeparator, decimalNumber, "", " S");
    }
  }

  // Create currency object based on the determined decimal number
  final currency = Currency.create(code!, decimalNumber, symbol: symbol, pattern: pattern);

  // Convert the amount to a Money object and return the string representation
  final convertedPrice = Money.fromNumWithCurrency(idr, currency);
  return convertedPrice.toString();
}
