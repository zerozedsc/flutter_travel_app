import 'package:travel_app/db/db.dart';

import '../back_end/configs.dart';
import '../back_end/service.dart';
import '../back_end/page_controller.dart';
import '../pages/base_widget.dart';

// Search Page
class SearchPage extends StatefulWidget {
  final String initialQuery;

  const SearchPage({super.key, required this.initialQuery});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  // misc variables
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String placeName = 'Loading...';
  String description = 'Loading...';
  String initialQuery = "";
  List<String> placeNames = [];
  List<Map<String, dynamic>>? _queryInfo, _spotData, _eventData, _postData;

  late TabController _tabController;
  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPrefectureInfo();
    _tabController = TabController(length: 4, vsync: this);
    initialQuery = widget.initialQuery;
    _tabController.addListener(() {
      setState(() {
        _activeTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _processInitialQuery(String searchQuery) async {
    try {
      DatabaseService dbService = DatabaseService();

      //ユーザーが空文字列を返した場合、データベースからランダムにデータを選択する。
      if (searchQuery.isEmpty) {
        searchQuery = PREFSERVICE.defaultPlaceName;
      }

      String kanjiPlaceName = "";
      late List<Map<String, dynamic>> spotData, eventData, postData;

      final List<Map<String, dynamic>>? queryInfo =
          await PlaceService.getPlaceInfoFromSearchJP(searchQuery);

      if (queryInfo != null && queryInfo.isNotEmpty) {
        if (queryInfo.length == 1) {
          kanjiPlaceName =
              "${queryInfo[0]['prefecture_kanji']}, ${queryInfo[0]['name_kanji']}";
        } else {
          kanjiPlaceName = queryInfo[0]['prefecture_kanji'];
        }

        spotData = await dbService.getAllSpotData(kanjiPlaceName);
        eventData = await dbService.getAllEventData(kanjiPlaceName);
        postData = await dbService.getAllPostData(kanjiPlaceName);
      }
      // Fetch all spot data for the specified location

      // Update the state with queryInfo and resultSpot only after all async operations are complete
      setState(() {
        _queryInfo = queryInfo ?? [];
        _spotData = spotData;
        _eventData = eventData;
        _postData = postData;
      });
    } catch (e) {
      print("Error processing initial query: $e");
    }
  }

  Future<void> _loadPrefectureInfo() async {
    final info = PREFSERVICE.defaultPrefectureInfo;
    setState(() {
      placeName = info['placeName']!;
      description = info['description']!;
      const int maxLen = 350;
      if (description.length >= maxLen) {
        int cutIndex = description.lastIndexOf('.', maxLen);
        if (cutIndex != -1) {
          description = description.substring(0, cutIndex + 1);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final pageControllerState =
    //     context.findAncestorStateOfType<PageControllerClassState>();
    const tabbar_font_size = 13.5;
    //この 「return BaseWidget 」の前のコードは、「searchpage 」のすべてのウィジェットをロードする前に、データベースからデータを取得するためである。
    if (globalAppConfig["userPreferences"]["language"] == "ja" &&
        (_queryInfo == null)) {
      _processInitialQuery(initialQuery);

      return const Center(child: CircularProgressIndicator());
    }

    return BaseWidget(
      scaffoldKey: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors
            .transparent, // Make the background transparent for a cleaner look
        elevation: 0, // Remove default shadow to make it look flat
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor.withOpacity(0.8),
                secondaryColor.withOpacity(0.8)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 1.0, right: 1.0),
          child: TypeAheadField<String>(
            textFieldConfiguration: TextFieldConfiguration(
              controller: _controller,
              decoration: InputDecoration(
                hintText: initialQuery == ""
                    ? LOCALIZATION.localize("search_for_a_place")
                    : initialQuery,
                hintStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500), // Light style for hint
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white
                    .withOpacity(0.2), // Slightly transparent fill to add depth
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 12.0), // Adjust padding for better alignment
              ),
              onSubmitted: (value) {
                _processInitialQuery(value);
              },
            ),
            suggestionsCallback: (pattern) async {
              var allSuggestions = PlaceService.getSuggestions(pattern);

              if (pattern.isEmpty) {
                allSuggestions.shuffle(); // Randomize the list
                return allSuggestions
                    .take(5)
                    .toList(); // Limit suggestions to 5
              } else {
                return allSuggestions
                    .where((suggestion) => suggestion
                        .toLowerCase()
                        .startsWith(pattern.toLowerCase()))
                    .take(5)
                    .toList();
              }
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(
                  suggestion,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0), // Standardized font size
                ),
              );
            },
            onSuggestionSelected: (suggestion) {
              _controller.text = suggestion;
              setState(() {
                placeName = suggestion;
                _loadPrefectureInfo();
                _processInitialQuery(suggestion);
              });
            },
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0), // Adjust TabBar height
          child: Material(
            color: Colors.transparent,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white, // White indicator for TabBar
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              tabs: [
                Tab(
                  child: Text(
                    LOCALIZATION.localize("all"),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: tabbar_font_size,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    LOCALIZATION.localize("spot_place"),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: tabbar_font_size,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    LOCALIZATION.localize("event"),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: tabbar_font_size - 1.595,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    LOCALIZATION.localize("posts"),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: tabbar_font_size - 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingWidget: _activeTabIndex == 3 // Show only on ニュース tab
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreatePost(
                      database: userDB,
                    ),
                  ),
                );
                print('Floating action button pressed');
              },
              backgroundColor: primaryColor,
              child: const Icon(Icons.post_add, color: Colors.white),
            )
          : null,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildAllTab(),
          _buildKankouList(),
          _buildEventList(),
          _buildPostsList(),
        ],
      ),
    );
  }

  // main build all tab
  Widget _buildAllTab() {
    const double setHeight = 7.0;
    const double setFontSize = 13.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSectionTitleinALL(
            LOCALIZATION.localize("today_prefecture"),
            textStyle: const TextStyle(
                fontSize: setFontSize, fontWeight: FontWeight.bold),
          ),
          _buildPrefectureCardinALL(),
          const SizedBox(height: setHeight),
          _buildSectionTitleinALL(LOCALIZATION.localize("spot_place_recommend"),
              textStyle: const TextStyle(
                  fontSize: setFontSize, fontWeight: FontWeight.bold),
              showMore: true,
              onShowMore: () => _tabController.animateTo(1)),
          SizedBox(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  _buildPopularPlaceinALL(), // Your method to build the place cards
                  // Add more widgets if necessary
                ],
              ),
            ),
          ),
          const SizedBox(height: setHeight),
          _buildSectionTitleinALL(LOCALIZATION.localize("event"),
              textStyle: const TextStyle(
                  fontSize: setFontSize, fontWeight: FontWeight.bold),
              showMore: true,
              onShowMore: () => _tabController.animateTo(2)),
          _buildEvent(),
          const SizedBox(height: setHeight),
          _buildSectionTitleinALL(LOCALIZATION.localize("posts"),
              textStyle: const TextStyle(
                  fontSize: setFontSize, fontWeight: FontWeight.bold),
              showMore: true,
              onShowMore: () => _tabController.animateTo(3)),
          _buildPost(),
        ],
      ),
    );
  }

  Widget _buildSectionTitleinALL(String title,
      {bool showMore = false, VoidCallback? onShowMore, TextStyle? textStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: textStyle ??
              const TextStyle(
                  fontSize: 18.0, fontWeight: FontWeight.bold), // Default style
        ),
        if (showMore)
          TextButton(
            onPressed: onShowMore,
            child: const Text('Show more'),
          ),
      ],
    );
  }

  Widget _buildPrefectureCardinALL() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16.0)),
            child: prefImageUrl != null
                ? Image.network(
                    prefImageUrl!,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey,
                    child: const Center(
                      child: Text(
                        'No picture available',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
                child: Text(
              placeName,
              style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularPlaceinALL() {
    final List<Map<String, dynamic>> places = List.from(
      _spotData!.map((map) => Map<String, dynamic>.from(map)),
    );
    for (var place in places) {
      place['img_link'] =
          "assets/images/S${place['id']}.jpg"; // Add or update a key-value pair
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: places
            .map((place) =>
                _buildPlaceCardinALL(place["name"].toString(), place))
            .toList(),
      ),
    );
  }

  Widget _buildPlaceCardinALL(String place, Map<String, dynamic> kankou) {
    return InkWell(
        onTap: () {
          // ここに観光地の詳細情報を表示させる
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RelatedTabScreen(data: kankou, dataType: '詳細'),
            ),
          );
          debugPrint('Card taped');
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          margin: const EdgeInsets.all(4.0),
          child: Column(
            children: <Widget>[
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16.0)),
                child: Image.asset(
                  kankou["img_link"], // Path to your image in the assets folder
                  height: 80,
                  width: 170,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(place),
              ),
            ],
          ),
        ));
  }

// posts card in all tab
  Widget _buildPost() {
    final List<Map<String, dynamic>> posts = List.from(
      _postData!.map((map) => Map<String, dynamic>.from(map)),
    );

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns
        crossAxisSpacing: 8.0, // Spacing between columns
        mainAxisSpacing: 8.0, // Spacing between rows
        childAspectRatio: 0.75, // Adjust this for card aspect ratio
      ),
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // Prevent GridView scrolling inside a parent scroll view
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _buildPostCard(post["name"].toString(), post);
      },
    );
  }

  Widget _buildPostCard(String name, Map<String, dynamic> post) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RelatedTabScreen(data: post, dataType: 'ポスト'),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        margin: const EdgeInsets.all(4.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                      child: post["imagepath"] != null && post["imagepath"].isNotEmpty
                          ? Image.file(
                              File(post["imagepath"]), // アプリのストレージ内の画像パスを指定
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              height: 120,
                              width: double.infinity,
                              color: Colors.grey, // Placeholder background color
                              child: Icon(
                                Icons.image, // Placeholder icon
                                color: Colors.white,
                                size: 48.0,
                              ),
                            ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis, // オーバーフロー時に省略記号を表示
                        maxLines: 2, // 最大1行まで表示
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// event card in all tab
  Widget _buildEvent() {
    final List<Map<String, dynamic>> events = List.from(
      _eventData!.map((map) => Map<String, dynamic>.from(map)),
    );

    for (var event in events) {
      event['img_link'] =
          "assets/images/E${event['id']}.jpg"; // Add or update a key-value pair
    }

    return Column(
      children: events.map((event) => _buildEventCard(event)).toList(),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RelatedTabScreen(data: event, dataType: 'イベント'),
            ),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        event['name']!,
                        style: const TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        event['open_hours']!,
                        style: const TextStyle(
                          fontSize: 8.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

// 観光地ページのデータ
  Widget _buildKankouPlace() {
    final List<Map<String, dynamic>> places = List.from(
      _spotData!.map((map) => Map<String, dynamic>.from(map)),
    );

    for (var place in places) {
      place['img_link'] =
          "assets/images/S${place['id']}.jpg"; // Add or update a key-value pair
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns
        crossAxisSpacing: 8.0, // Spacing between columns
        mainAxisSpacing: 8.0, // Spacing between rows
        childAspectRatio: 0.775, // Adjust this for card aspect ratio
      ),
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // Prevent GridView scrolling inside a parent scroll view
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return _buildKankouCard(place["name"].toString(), place);
      },
    );
  }

  Widget _buildKankouCard(String place, Map<String, dynamic> kankou) {
    return InkWell(
        onTap: () {
          // ここに観光地の詳細情報を表示させる
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RelatedTabScreen(data: kankou, dataType: '詳細'),
            ),
          );
          debugPrint('Card taped');
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          margin: const EdgeInsets.all(4.0),
          child: Column(
            children: <Widget>[
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16.0)),
                child: Image.asset(
                  kankou["img_link"], // Path to your image in the assets folder
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  place,
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis, // オーバーフロー時に省略記号を表示
                  maxLines: 2, // 最大1行まで表示
                ),
              ),
            ],
          ),
        ));
  }

/* all tab */
// ニュース in posts tab
  Widget _buildPostsList() {
    // const double setHeight = 7.0;
    const double setFontSize = 13.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSectionTitleinALL(
            LOCALIZATION.localize("posts"),
            textStyle: const TextStyle(
                fontSize: setFontSize, fontWeight: FontWeight.bold),
          ),
          _buildPost(),
        ],
      ),
    );
  }

// イベント in event tab
  Widget _buildEventList() {
    // const double setHeight = 7.0;
    const double setFontSize = 13.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSectionTitleinALL(
            'イベント情報',
            textStyle: const TextStyle(
                fontSize: setFontSize, fontWeight: FontWeight.bold),
          ),
          _buildEvent(),
        ],
      ),
    );
  }

// 観光地ページ
  Widget _buildKankouList() {
    // const double setHeight = 7.0;
    const double setFontSize = 13.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSectionTitleinALL(
            '観光地情報',
            textStyle: const TextStyle(
                fontSize: setFontSize, fontWeight: FontWeight.bold),
          ),
          _buildKankouPlace(),
        ],
      ),
    );
  }

/*one tab */
}
