import '../back_end/configs.dart';
import '../back_end/service.dart';
import '../back_end/page_controller.dart';

import '../pages/base_widget.dart';
import '../pages/recommend_page.dart';

import 'package:http/http.dart' as http;

// Home Page
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // misc variables
  String placeName = 'Loading...';
  String description = 'Loading...';

  final TextEditingController _controller = TextEditingController();
  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadPrefectureInfo();
  }

  Future<void> _loadPrefectureInfo() async {
    final info = PREFSERVICE.defaultPrefectureInfo;
    prefImageUrl ??= await fetchUnsplashImage(info[
        'placeName']!); // using "??="" if dont want to refresh value everytime

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
    final pageControllerState =
        context.findAncestorStateOfType<PageControllerClassState>();

    const double borderRadius = 20.0;

    return BaseWidget(
      scaffoldKey: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(20.0), // Custom AppBar height
        child: AppBar(
          backgroundColor: secondaryColor, // Set your desired color here
          automaticallyImplyLeading: false, // Disable the default back button
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black),
                  onPressed: () =>
                      _scaffoldKey.currentState?.openDrawer(), // Open drawer
                ),
                Expanded(
                  child: TypeAheadField<String>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: LOCALIZATION.localize('search_for_a_place'),
                        hintStyle: const TextStyle(
                            color: Colors.white, fontSize: 15.0),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white,
                              width:
                                  3), // White underline with a thickness of 1.5
                        ),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.black),
                      ),
                    ),
                    suggestionsCallback: (pattern) async {
                      var allSuggestions = PlaceService.getSuggestions(pattern);

                      if (pattern.isEmpty) {
                        allSuggestions.shuffle(); // Randomize the list
                        return allSuggestions
                            .take(5)
                            .toList(); // Return a subset
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
                      return ListTile(title: Text(suggestion));
                    },
                    onSuggestionSelected: (suggestion) {
                      _controller.text = suggestion;
                      setState(() {
                        placeName = suggestion;
                        pageControllerState?.navigateToSearchPage(suggestion);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                // Fullscreen background image
                Positioned.fill(
                  child: prefImageUrl != null
                      ? Image.network(
                          prefImageUrl!,
                          fit: BoxFit
                              .cover, // Ensures the image fills the entire background
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),

                // Overlay content
                // Search bar
                Positioned(
                  bottom: 480.0,
                  left: 16.0,
                  right: 16.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RecommendPage(),
                              ),
                            );
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height * 1 / 15,
                            width: MediaQuery.of(context).size.width * 3 / 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    primaryColor,
                                    secondaryColor,
                                  ]),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Text(""),
                                Text(
                                  LOCALIZATION.localize('take_travel_survey'),
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_right_alt_outlined,
                                    size: 25.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  bottom: 16.0,
                  left: 16.0,
                  right: 16.0,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey.withOpacity(0.4),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // New text on top
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6.0, horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(
                                  0.15), // Background color with opacity
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Text(
                              LOCALIZATION
                                  .localize("today_prefecture"), // The new text
                              style: TextStyle(
                                fontSize: 18.0, // Adjust size as needed
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.6),
                                    offset: const Offset(0, 2),
                                    blurRadius: 6.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                            height:
                                0.2), // Space between the new text and the rest of the content
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 28.0,
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                placeName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28.0,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black,
                                      offset: Offset(0, 2),
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          description,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            height: 1.5,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                offset: Offset(0, 1),
                                blurRadius: 4.0,
                              ),
                            ],
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10.0),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              pageControllerState
                                  ?.navigateToSearchPage(placeName);
                            });
                          },
                          icon: const Icon(Icons.arrow_forward,
                              color: Colors.white),
                          label: Text(
                            LOCALIZATION.localize('explore_more'),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16.0),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                secondaryColor.withOpacity(0.8), // Transparent
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
