import '../back_end/configs.dart';
import '../back_end/service.dart';
import '../back_end/page_controller.dart';
import '../pages/search_page.dart';
import '../db/db.dart';

class RecommendPage extends StatefulWidget {
  const RecommendPage({Key? key}) : super(key: key);

  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<RecommendPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Map<String, dynamic> travelQuestions =
      LOCALIZATION.localizeMap("TRAVEL_QUESTIONS");

  late List<Map<String, dynamic>> _questions;

  @override
  void initState() {
    super.initState();
    _questions = travelQuestions.entries.map((entry) {
      return {
        "question": entry.value["q"], // The question text
        "answers": entry.value["a"] // The list of answers
      };
    }).toList();
  }

  int _currentQuestionIndex = 0;
  final Map<String, dynamic> _userResponses = {};
  bool _isLoading = false;
  Map<String, dynamic>? _recommendationData;

  Future<void> _saveResponses() async {
    setState(() {
      _isLoading = true; // Show the loading indicator
    });

    _userResponses["language"] = globalAppConfig["userPreferences"]["language"];
    print(existPrefList);

    if (DEBUG) {
      _userResponses["suggestOnlyPrefecture"] = existPrefList;
    }

    final Map<String, dynamic> recommendationData =
        await RecommendService().getRecommendations(_userResponses) ??
            {
              "prefecture": "石川県",
              "reason":
                  "石川県をおすすめする理由は、まず海が好きな方には能登半島や加賀温泉など、美しい海岸線や温泉地が豊富にあります。また、観光がお好きな方には、金沢市の兼六園やひがし茶屋街など、歴史的な観光スポットが充実しています。さらに、春に訪れると桜の名所としても知られ、低予算でも楽しめる観光地が多いです。",
              "places": ["金沢市", "加賀市", "能登半島"]
            };

    // final Map<String, dynamic> recommendationData = {
    //   "prefecture": "石川県",
    //   "reason":
    //       "石川県をおすすめする理由は、まず海が好きな方には能登半島や加賀温泉など、美しい海岸線や温泉地が豊富にあります。また、観光がお好きな方には、金沢市の兼六園やひがし茶屋街など、歴史的な観光スポットが充実しています。さらに、春に訪れると桜の名所としても知られ、低予算でも楽しめる観光地が多いです。",
    //   "places": ["金沢市", "加賀市", "能登半島"]
    // };

    recommendationData["picture_link"] = await fetchUnsplashImage(
        recommendationData["prefecture"]); // Fetch image link

    globalAppConfig["survey"] = _userResponses;
    ConfigService.updateConfig();

    setState(() {
      _isLoading = false; // Hide the loading indicator
      _recommendationData = recommendationData; // Save the recommendation data
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> currentQuestion =
        _questions[_currentQuestionIndex];

    if (_recommendationData != null) {
      // If recommendation data is available, show the recommendation page

      return _RecommendationPage(
        data: _recommendationData!,
        onPlacePressed: (place) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PageControllerClass(state: {"query": place}),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          LOCALIZATION.localize("travel_survey"),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 4,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _questions.length,
                color: Theme.of(context).colorScheme.primary,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.4),
              ),
              const SizedBox(height: 10),
              Text(
                "${_currentQuestionIndex + 1} / ${_questions.length}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor,
                        Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentQuestion["question"],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ...currentQuestion["answers"].map<Widget>((answer) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor:
                                  Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 24.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 5,
                            ),
                            onPressed: () {
                              setState(() {
                                _userResponses[currentQuestion["question"]] =
                                    answer;
                                if (_currentQuestionIndex <
                                    _questions.length - 1) {
                                  _currentQuestionIndex++;
                                } else {
                                  _saveResponses();
                                }
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.circle,
                                  size: 14,
                                  color: Colors.blueAccent,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  answer,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(
                              color: Colors.white,
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
      ),
    );
  }
}

class _RecommendationPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final Function(String place) onPlacePressed;

  const _RecommendationPage({
    required this.data,
    required this.onPlacePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LOCALIZATION.localize("recommended_prefecture"),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 4,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: data['picture_link'] != null
              ? DecorationImage(
                  image: NetworkImage(data['picture_link']),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.darken,
                  ),
                )
              : null,
          color: data['picture_link'] == null ? Colors.grey[200] : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section with Prefecture Name and Button
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.withOpacity(0.1),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: () {
                            onPlacePressed(data['prefecture']);
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_pin,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                data['prefecture'],
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data['reason'],
                      style: const TextStyle(
                        fontSize: 14.6,
                        color: Colors.white,
                        height: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.grey,
                            offset: Offset(1, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Places Buttons Section
              const Text(
                "訪問する場所",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: data['places'].map<Widget>((place) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.8),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 16.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      onPlacePressed("$place, ${data['prefecture']}");
                    },
                    child: Text(
                      place,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecommendService {
  final String _endpoint =
      dotenv.env['AZURE_ENDPOINT'] ?? ""; // Replace with your endpoint
  final String _modelName = "gpt-35-turbo"; // Replace with your model name
  final String _apiKey =
      dotenv.env['AZURE_API_KEY'] ?? ""; // Replace with your API key
  final String _apiVersion = "2024-05-01-preview";

  Future<Map<String, dynamic>>? getRecommendations(
      Map<String, dynamic> userSurvey) async {
    final String prompt = """
Based on survey, suggest:
1. str:"prefecture" (pick one from the list of "suggestOnlyPrefecture" if exist), 
2. str:"reason" (why recommend (1.), at least 3 reasons in one paragraph format),
3. list:"places" (only 3, can be Municipality or Town in (1.)). 
4. language should = survey["language"]

RESPONSE IN ONE JSON FILE, dont include ```json and ``` in response, make it easy to convert to JSON format.

survey: $userSurvey
""";

    final Map<String, dynamic> body = {
      "messages": [
        {"role": "system", "content": "You are a helpful japan travel guide."},
        {"role": "user", "content": prompt}
      ],
      "max_tokens": 800,
      "temperature": 0.9,
      "top_p": 0.95,
      "frequency_penalty": 0.2,
      "presence_penalty": 0.5,
      "stream": false
    };

    final Uri uri = Uri.parse(
        '$_endpoint/openai/deployments/$_modelName/chat/completions?api-version=$_apiVersion');

    try {
      final response = await post(
        uri,
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "api-key": _apiKey,
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final String content = data["choices"][0]["message"]["content"];
        // Convert response to JSON format
        return json.decode(content);
      } else {
        throw Exception('Failed to get response: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
