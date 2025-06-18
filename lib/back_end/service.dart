import 'configs.dart';
import 'package:http/http.dart' as http;

import '../db/db.dart';

// SERVICES RELATED GLOBAL VARIABLES
// ignore: non_constant_identifier_names
late PrefectureService PREFSERVICE;

// API WEBSITE
// https://rapidapi.com/search/Travel?sortBy=ByRelevance
// https://serpapi.com/

// SERVICES RELATED FUNCTIONS
Future<String?> fetchUnsplashImage(String placeName) async {
  String clientId = dotenv.env['UNSPLASH_API_KEY'] ?? '';
  late Uri url;
  if (globalAppConfig["userPreferences"]["language"] == "ja") {
    url = Uri.parse(
        'https://api.unsplash.com/search/photos?query=$placeName&client_id=$clientId');
  } else {
    url = Uri.parse(
        'https://api.unsplash.com/search/photos?query=$placeName, Japan&client_id=$clientId');
  }

  // print(url);

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final results = data['results'];
    if (results.isNotEmpty) {
      return results[Random().nextInt(results.length)]['urls']['regular'];
    }
  }

  return null;
}

// SERVICES RELATED CLASS
class PrefectureService {
  late String defaultPlaceName;
  late List<String> prefectures;
  late Map<String, String> defaultPrefectureInfo;

  PrefectureService._privateConstructor();

  static final PrefectureService instance =
      PrefectureService._privateConstructor();

  static Future<PrefectureService> initialize() async {
    final service = PrefectureService._privateConstructor();
    await service.checkAppLang();
    await service.getPrefectureInfo();
    return service;
  }

  Future<void> checkAppLang() async {
    if (globalAppConfig["userPreferences"]["language"] == "ja") {
      defaultPlaceName = '富山県';
      prefectures = [
        '北海道',
        '青森県',
        '岩手県',
        '宮城県',
        '秋田県',
        '山形県',
        '福島県',
        '茨城県',
        '栃木県',
        '群馬県',
        '埼玉県',
        '千葉県',
        '東京都',
        '神奈川県',
        '新潟県',
        '富山県',
        '石川県',
        '福井県',
        '山梨県',
        '長野県',
        '岐阜県',
        '静岡県',
        '愛知県',
        '三重県',
        '滋賀県',
        '京都府',
        '大阪府',
        '兵庫県',
        '奈良県',
        '和歌山県',
        '鳥取県',
        '島根県',
        '岡山県',
        '広島県',
        '山口県',
        '徳島県',
        '香川県',
        '愛媛県',
        '高知県',
        '福岡県',
        '佐賀県',
        '長崎県',
        '熊本県',
        '大分県',
        '宮崎県',
        '鹿児島県',
        '沖縄県'
      ];
    } else {
      defaultPlaceName = 'Toyama';
      prefectures = [
        'Hokkaido',
        'Aomori',
        'Iwate',
        'Miyagi',
        'Akita',
        'Yamagata',
        'Fukushima',
        'Ibaraki',
        'Tochigi',
        'Gunma',
        'Saitama',
        'Chiba',
        'Tokyo',
        'Kanagawa',
        'Niigata',
        'Toyama',
        'Ishikawa',
        'Fukui',
        'Yamanashi',
        'Nagano',
        'Gifu',
        'Shizuoka',
        'Aichi',
        'Mie',
        'Shiga',
        'Kyoto',
        'Osaka',
        'Hyogo',
        'Nara',
        'Wakayama',
        'Tottori',
        'Shimane',
        'Okayama',
        'Hiroshima',
        'Yamaguchi',
        'Tokushima',
        'Kagawa',
        'Ehime',
        'Kochi',
        'Fukuoka',
        'Saga',
        'Nagasaki',
        'Kumamoto',
        'Oita',
        'Miyazaki',
        'Kagoshima',
        'Okinawa'
      ];
    }

    defaultPrefectureInfo = {'placeName': defaultPlaceName, 'description': ""};
  }

  Future<Map<String, String>> getPrefectureInfo() async {
    await checkAppLang();
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toString();
    final String placeName, description;

    // Check if stored date is today
    if (prefs.getString('date') == today) {
      defaultPlaceName = prefs.getString('placeName') ?? defaultPlaceName;
      placeName = defaultPlaceName;
      description =
          prefs.getString('description') ?? 'Description not available.';
    } else {
      final Map<String, dynamic>? getPrefectureRow =
          await DatabaseQuery(db: DB).getRandomRow("spot_table");
      final String? getPrefectureName = getPrefectureRow?["location"];
      final random = Random();
      placeName = getPrefectureName == null
          ? prefectures[random.nextInt(prefectures.length)]
          : getPrefectureName.split(',')[0];
      defaultPlaceName = placeName;
      description = await _fetchWikipediaDescription(placeName) ?? "";

      // Store today's date, placeName and description
      await prefs.setString('date', today);
      await prefs.setString('placeName', placeName);
      await prefs.setString('description', description);
    }
    defaultPrefectureInfo = {
      'placeName': placeName,
      'description': description
    };
    return defaultPrefectureInfo;
  }

  Future<String> _fetchWikipediaDescription(String placeName) async {
    if (globalAppConfig["userPreferences"]["language"] == "ja") {
      final url = Uri.parse(Uri.encodeFull(
          'https://ja.wikipedia.org/api/rest_v1/page/summary/$placeName'));
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['extract'] ?? '詳細は不明.';
      } else {
        return '詳細は不明.';
      }
    } else {
      final url = Uri.parse(Uri.encodeFull(
          'https://en.wikipedia.org/api/rest_v1/page/summary/${placeName}_Prefecture'));
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['extract'] ?? 'Description not available.';
      } else {
        return 'Description not available.';
      }
    }
  }
}

class PlaceService {
  static List<String> placeNames = [];

  static List<String> getSuggestions(String query) {
    if (globalAppConfig["userPreferences"]["language"] != "ja") {
      placeNames
          .retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    }

    return placeNames;
  }

  static Future<void> loadPlaceNames() async {
    final String response = await rootBundle.loadString(municipalitiesPath);
    final List<dynamic> data = json.decode(response);

    if (globalAppConfig["userPreferences"]["language"] == "ja") {
      placeNames = data.map<String>((item) {
        final String nameKana = (item['name_kana'] ??
            item['name_kana_breakdown'].split(',').join('')) as String;
        final String prefectureKana = item['prefecture_kana'];
        return '$nameKana, $prefectureKana';
      }).toList();

      placeNames.addAll([
        'ほっかいどう',
        'あおもりけん',
        'いわてけん',
        'みやぎけん',
        'あきたけん',
        'やまがたけん',
        'ふくしまけん',
        'いばらきけん',
        'とちぎけん',
        'ぐんまけん',
        'さいたまけん',
        'ちばけん',
        'とうきょうと',
        'かながわけん',
        'にいがたけん',
        'とやまけん',
        'いしかわけん',
        'ふくいけん',
        'やまなしけん',
        'ながのけん',
        'ぎふけん',
        'しずおかけん',
        'あいちけん',
        'みえけん',
        'しがけん',
        'きょうとふ',
        'おおさかふ',
        'ひょうごけん',
        'ならけん',
        'わかやまけん',
        'とっとりけん',
        'しまねけん',
        'おかやまけん',
        'ひろしまけん',
        'やまぐちけん',
        'とくしまけん',
        'かがわけん',
        'えひめけん',
        'こうちけん',
        'ふくおかけん',
        'さがけん',
        'ながさきけん',
        'くまもとけん',
        'おおいたけん',
        'みやざきけん',
        'かごしまけん',
        'おきなわけん'
      ]);
    } else {
      placeNames = data.map<String>((item) {
        final String nameRomaji = item['name_romaji'];
        final String prefectureRomaji = item['prefecture_romaji'].split(' ')[0];
        return '$nameRomaji, $prefectureRomaji';
      }).toList();

      placeNames.addAll([
        'Hokkaido',
        'Aomori',
        'Iwate',
        'Miyagi',
        'Akita',
        'Yamagata',
        'Fukushima',
        'Ibaraki',
        'Tochigi',
        'Gunma',
        'Saitama',
        'Chiba',
        'Tokyo',
        'Kanagawa',
        'Niigata',
        'Toyama',
        'Ishikawa',
        'Fukui',
        'Yamanashi',
        'Nagano',
        'Gifu',
        'Shizuoka',
        'Aichi',
        'Mie',
        'Shiga',
        'Kyoto',
        'Osaka',
        'Hyogo',
        'Nara',
        'Wakayama',
        'Tottori',
        'Shimane',
        'Okayama',
        'Hiroshima',
        'Yamaguchi',
        'Tokushima',
        'Kagawa',
        'Ehime',
        'Kochi',
        'Fukuoka',
        'Saga',
        'Nagasaki',
        'Kumamoto',
        'Oita',
        'Miyazaki',
        'Kagoshima',
        'Okinawa'
      ]);
    }
  }

  // only use for search box
  static Future<List<Map<String, dynamic>>?> getPlaceInfoFromSearchJP(
      String searchValue) async {
    final String response = await rootBundle.loadString(municipalitiesPath);
    final List<dynamic> data = json.decode(response);

    List<Map<String, dynamic>> dataList = [];

    if (searchValue.contains(",")) {
      // Return only one data but in a list with the condition
      dataList = data
          .where((item) =>
              item is Map<String, dynamic> &&
                  (item['name_kana'] == searchValue.split(',')[0].trim() &&
                      item['prefecture_kana'] ==
                          searchValue.split(',')[1].trim()) ||
              (item['name_kanji'] == searchValue.split(',')[0].trim() &&
                  item['prefecture_kanji'] == searchValue.split(',')[1].trim()))
          .cast<Map<String, dynamic>>()
          .toList();

      return dataList.isNotEmpty ? dataList : null;
    }

    // Return all data that has the same `prefecture_kana` in `dataList`
    dataList = data
        .where((item) =>
            item is Map<String, dynamic> &&
            (item['prefecture_kana'] == searchValue ||
                item['prefecture_kanji'] == searchValue))
        .cast<Map<String, dynamic>>()
        .toList();

    return dataList.isNotEmpty ? dataList : null;
  }
}

class DatabaseService {
  DatabaseQuery dbClass = DatabaseQuery(db: DB);
  DatabaseQuery dbUser = DatabaseQuery(db: userDB);

  // データの挿入
  Future<void> addSpot(Map<String, dynamic> spotData) async {
    await dbClass.insertData('spot_table', spotData);
  }

  // データ取得（全行取得）
  Future<List<Map<String, dynamic>>> getAllSpotData(String location) async {
    String tableName = 'spot_table';
    String query = '''
    SELECT * FROM $tableName
    WHERE location LIKE '%$location%'
  ''';

    return await dbClass.query(query);
  }

  Future<List<Map<String, dynamic>>> getAllPostData(String location) async {
    String tableName = 'post';
    String query = '''
    SELECT * FROM $tableName
    WHERE location LIKE '%$location%'
  ''';

    return await dbUser.query(query);
  }

  Future<Map<String, dynamic>?> getRandomSpotData() {
    return dbClass.getRandomRow('spot_table');
  }

  Future<List<Map<String, dynamic>>> getAllEventData(String location) async {
    String tableName = 'event_table';
    String query = '''
    SELECT * FROM $tableName
    WHERE location LIKE '%$location%'
  ''';

    return await dbClass.query(query);
  }

  // データ更新
  Future<void> updateSpot(int id, Map<String, dynamic> updatedData) async {
    await dbClass.updateData('spot_table', id, updatedData);
  }

  // データの削除
  Future<void> deleteSpot(int id) async {
    await dbClass.deleteData('spot_table', id);
  }
}

class PlannerService {}

// NEWS WEBSITES
class NewsService {}
