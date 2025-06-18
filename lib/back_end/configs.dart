//export from configs
export 'package:flutter/material.dart';
export 'package:device_preview/device_preview.dart'
    hide basicLocaleListResolution;
export 'package:http/http.dart';
export 'package:shared_preferences/shared_preferences.dart';
export 'package:autocomplete_textfield/autocomplete_textfield.dart';
export 'package:flutter/services.dart';
export 'package:logging/logging.dart';
export 'package:flutter_typeahead/flutter_typeahead.dart';
export 'package:path_provider/path_provider.dart';
export 'package:kana_kit/kana_kit.dart'; // 漢字からかなへの変換
export 'package:html/parser.dart';
export 'package:fluttertoast/fluttertoast.dart';
export 'package:flutter_dotenv/flutter_dotenv.dart';
export 'dart:convert';
export 'dart:math';
export 'dart:io';
export 'dart:async';

//import to configs
import 'dart:convert';
import 'package:flutter/services.dart'; // Add this import statement
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// global var
late Map<String, dynamic> globalAppConfig;
String? prefImageUrl;
// ignore: non_constant_identifier_names
late LocalizationManager LOCALIZATION;

String? globalImageUrl;
Color primaryColor = Colors.indigo.shade600;
Color secondaryColor = Colors.indigo.shade300;

// ignore: constant_identifier_names
const bool DEBUG = true;
const String municipalitiesPath = 'assets/data/municipalities_objects.json';

// Class to handle the app configuration
class ConfigService {
  static const String _configFileName = 'app_config.json';
  static const String _assetConfigPath = 'assets/configs/app_config.json';

  // Initialize and load the configuration
  static Future<Map<String, dynamic>> initializeConfig() async {
    await _copyConfigFileToWritableDirectory();
    return await _loadConfig();
  }

  // Copy the config file from assets to a writable directory if it doesn't already exist
  static Future<void> _copyConfigFileToWritableDirectory() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String configPath = '${appDocDir.path}/$_configFileName';

    // Check if the file already exists
    if (FileSystemEntity.typeSync(configPath) ==
        FileSystemEntityType.notFound) {
      // If not, load from assets and copy to the writable directory
      final ByteData data = await rootBundle.load(_assetConfigPath);
      final List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(configPath).writeAsBytes(bytes);
    }
  }

  // Load the config file from the writable directory
  static Future<Map<String, dynamic>> _loadConfig() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String configPath = '${appDocDir.path}/$_configFileName';

    final String data = await File(configPath).readAsString();
    return json.decode(data);
  }

  // Update the app configuration file json based on globalAppConfig in the writable directory
  static Future<void> updateConfig() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String configPath = '${appDocDir.path}/$_configFileName';

    await File(configPath).writeAsString(json.encode(globalAppConfig));
  }
}

// Class to handle localization
class LocalizationManager {
  static final LocalizationManager _instance = LocalizationManager._internal();

  // Singleton instance
  factory LocalizationManager(String languageCode) {
    _instance.loadLanguage(languageCode);
    return _instance;
  }

  LocalizationManager._internal();

  Map<String, dynamic> _localizedStrings = {};

  // Load the JSON file for the given locale
  Future<void> loadLanguage(String languageCode) async {
    final String jsonString =
        await rootBundle.loadString('assets/data/lang/$languageCode.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    // Flattening the map to ensure all values are Strings
    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value));
  }

  // Retrieve a translated string by key
  String localize(String key) {
    return _localizedStrings[key] ?? key; // Return key if translation not found
  }

  // Retrieve a <String, dynamic> map by key
  Map<String, dynamic> localizeMap(String key) {
    return _localizedStrings[key] ?? {}; // Return empty map if key not found
  }
}
