// ignore_for_file: avoid_print

import 'back_end/configs.dart';
import 'back_end/page_controller.dart';
import 'back_end/service.dart';
import 'db/db.dart';
import 'pages/login_page.dart';

import 'package:package_info_plus/package_info_plus.dart';

// ignore: unused_element
final Logger _logger = Logger('MyApp');

// assets import

// Separate async function for initializing components sequentially
// 初期化関数
Future<void> runAppInitializations() async {
  // Set up logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Initialize configuration
  await dotenv.load(fileName: ".env");
  globalAppConfig = await ConfigService
      .initializeConfig(); // Initialize app_config.json first

  // Load place names after config initialization
  await PlaceService.loadPlaceNames();

  // initialize Database (databaseの初期化はこれだけで十分)
  DB = await DatabaseConnection.getDatabase(dbName: "jp.db");
  if (DEBUG) {
    List<Map<String, dynamic>> result =
        await DatabaseQuery(db: DB).query("""SELECT DISTINCT
  SUBSTR(location, 1, INSTR(location, ',') - 1) AS prefecture
FROM
  spot_table;""");
    existPrefList = result.map((row) => row['prefecture'] as String).toList();
  }
  userDB = await DatabaseConnection.getDatabase(dbName: "user.db");
  ;
  await DatabaseQuery(db: userDB).printAllInTable('post');
  // initialize PrefectureService

  // INITIALIZE SETTING
  PREFSERVICE = await PrefectureService.initialize();
  // initialize LocalizationManager
  LOCALIZATION =
      LocalizationManager(globalAppConfig["userPreferences"]["language"]);

  // Fetch and print package info
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  print("Package Name: ${packageInfo.packageName}");
}

void main() async {
  Logger.root.level = Level.ALL; // Log all messages
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  WidgetsFlutterBinding.ensureInitialized();
  await runAppInitializations();

  // main function to run the app
  runApp(
    Platform.isAndroid || Platform.isIOS
        ? const MyApp()
        : DevicePreview(
            enabled: true,
            tools: const [
              ...DevicePreview.defaultTools,
              // CustomPlugin(),
            ],
            builder: (context) => const MyApp(),
          ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'Travel App',
      theme: ThemeData(
        fontFamily: 'NotoSerifJP',
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
      ),
      darkTheme: globalAppConfig["userPreferences"]["theme"] == "light"
          ? ThemeData.light()
          : ThemeData.dark(),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
