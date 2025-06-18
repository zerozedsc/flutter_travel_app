import 'dart:ffi';

import '../back_end/configs.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:image_picker/image_picker.dart';
import '../db/db.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // Import flutter_inappwebview package

// Explanation Screen
class RelatedTabScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String dataType;

  const RelatedTabScreen(
      {super.key, required this.data, required this.dataType});

  @override
  State<RelatedTabScreen> createState() => _RelatedTabScreen();
}

class _RelatedTabScreen extends State<RelatedTabScreen> {
  late Map<String, dynamic> data;
  late String dataType;
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    data = widget.data;
    dataType = widget.dataType;
  }

  @override
  Widget build(BuildContext context) {
    String title = dataType;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          title,
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'addtoplan') {
                _showAddToPlanDialog(context);
              } else {
                print('Selected: $value');
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'favorite',
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(LOCALIZATION.localize('favorite')),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'addtoplan',
                  child: Row(
                    children: [
                      Icon(Icons.add, color: primaryColor),
                      const SizedBox(width: 4),
                      Text(LOCALIZATION.localize('add_to_plan')),
                    ],
                  ),
                ),
              ];
            },
            icon: const Icon(Icons.more_vert, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              if (data.containsKey('name')) _buildTitleSection(data['name']),
              const SizedBox(height: 10),

              // Image Section
              if (data.containsKey('img_link'))
                _buildImageSection(data['img_link'], screenHeight),
              const SizedBox(height: 20),

              // Description Section
              if (data.containsKey('description') && data['description'] != '')
                _buildDescriptionSection(data['description'])
              else if (data.containsKey('content') && data['content'] != '')
                _buildDescriptionSection(data['content']),
              const SizedBox(height: 20),

              if (data.containsKey('comment') && data['comment'] != '')
                _buildDescriptionSection(data['comment']),

              // Google Maps Section
              if (data.containsKey('googlemaps_link'))
                _buildGoogleMapsSection(
                    data['googlemaps_link'], data['address']),
              const SizedBox(height: 20),

              // Other Details Section
              if (dataType != 'ポスト')
                _buildDetailsSection(data),
            ],
          ),
        ),
      ),
    );
  }

  // Show Add to Plan Dialog
  void _showAddToPlanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LOCALIZATION.localize('add_to_plan')),
          content: Text(LOCALIZATION.localize('add_to_plan_description')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(LOCALIZATION.localize('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle add to plan action
                Navigator.of(context).pop();
              },
              child: Text(LOCALIZATION.localize('add')),
            ),
          ],
        );
      },
    );
  }

  // Title Section
  Widget _buildTitleSection(String name) {
    return Text(
      name,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  // Image Section
  Widget _buildImageSection(dynamic imgLink, double screenHeight) {
    final double imageHeight = screenHeight / 3;

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Image.asset(
        imgLink, // Path to the image in assets
        height: imageHeight,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  // Description Section
  Widget _buildDescriptionSection(String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Html(
        data: description,
        style: {
          "p": Style(fontSize: FontSize.large),
        },
      ),
    );
  }

  // Other Details Section
  Widget _buildDetailsSection(Map<String, dynamic> data) {
    List<Widget> detailWidgets = [];

    // List of fields that we want to display as meaningful data
    final List<String> detailKeys = [
      'open_hours',
      'location',
      'url',
      'mainwebsite_url',
      'address',
      'contact',
      'googlemaps_link',
      'feedback',
      'favourite',
      'score',
    ];

    data.forEach((key, value) {
      if (detailKeys.contains(key)) {
        detailWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _getIconForKey(key),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _capitalizeFirstLetter(
                            key.toString().replaceAll("_", " ")),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 16),
                      ),
                      _buildDetailContent(key, value),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LOCALIZATION.localize("other_information"),
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
        ),
        const SizedBox(height: 10),
        ...detailWidgets,
      ],
    );
  }

  // Google Maps Section
  Widget _buildGoogleMapsSection(String googleMapsLink, String location) {
    const double width = 300.0;
    const double height = 200.0;
    // Create the iframe HTML string
    String iframeHtml = '''
              <html>
                <head>
                  <style>
                    body, html {
                      margin: 0;
                      padding: 0;
                      height: 100%;
                      overflow: hidden;
                    }

                  </style>
                </head>
                <body>
                  <div class="gmap_canvas" style="width: 100%">
                  <iframe class="gmap_iframe" frameborder="0" scrolling="yes" marginheight="0" marginwidth="0" width="100%" height="100%" 
                  src="https://maps.google.com/maps?width=100&amp;height=600&amp;hl=en&amp;q=$location&amp;
t=&amp;
z=19&amp;
ie=UTF8&amp;
iwloc=B&amp;
output=embed">
</iframe>
</div>
                </body>
              </html>
              ''';

    return Container(
      height: height,
      width: width, // Adjust the height as needed
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InAppWebView(
          initialUrlRequest: URLRequest(
              url: WebUri('about:blank')), // Empty page to load HTML content
          initialSettings: InAppWebViewSettings(
            supportZoom: true,
            initialScale: 0,
            textZoom: 300,
            iframeAllowFullscreen: true,
            displayZoomControls: true,
            pageZoom: 0.1,
          ),
          onWebViewCreated: (InAppWebViewController controller) {
            // Load the HTML content into the WebView
            _webViewController = controller;
            controller.loadData(
              data: iframeHtml,
              mimeType: "text/html",
              encoding: "utf-8",
              baseUrl: WebUri(
                  'about:blank'), // Use about:blank since we're loading local content
            );
          },
        ),
      ),
    );
  }

  // Get Icon Based on Key
  Widget _getIconForKey(String key) {
    switch (key) {
      case 'url':
      case 'mainwebsite_url':
      case 'googlemaps_link':
        return Icon(Icons.link, color: primaryColor, size: 20);
      case 'open_hours':
        return Icon(Icons.access_time, color: primaryColor, size: 20);
      case 'location':
        return Icon(Icons.location_on, color: primaryColor, size: 20);
      case 'address':
        return Icon(Icons.location_city, color: primaryColor, size: 20);
      case 'contact':
        return Icon(Icons.phone, color: primaryColor, size: 20);
      case 'feedback':
        return Icon(Icons.feedback, color: primaryColor, size: 20);
      case 'favourite':
        return Icon(Icons.favorite, color: primaryColor, size: 20);
      case 'score':
        return Icon(Icons.star, color: primaryColor, size: 20);
      default:
        return Icon(Icons.info, color: primaryColor, size: 20);
    }
  }

  // Build Detail Content
  Widget _buildDetailContent(String key, dynamic value) {
    if (key == 'url' ||
        key == 'mainwebsite_url' ||
        key == 'googlemaps_link' ||
        key == 'contact') {
      return GestureDetector(
        onTap: () => _launchUrl(value),
        child: Text(
          value,
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      );
    } else if (key == 'favourite') {
      if (value is int) {
        return Text(
          value == 1 ? 'Yes' : 'No',
          style: const TextStyle(fontSize: 14),
        );
      }
      return Text(
        value ? 'Yes' : 'No',
        style: const TextStyle(fontSize: 14),
      );
    } else if (key == 'score') {
      return Row(
        children: List.generate(5, (index) {
          return Icon(
            index < (value as double) ? Icons.star : Icons.star_border,
            color: Colors.yellow[700],
            size: 20,
          );
        }),
      );
    } else {
      return Text(
        value.toString(),
        style: const TextStyle(fontSize: 14),
      );
    }
  }

  // Capitalize first letter of the string
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  // Launch URL
  void _launchUrl(String url) {
    // Implement URL launch (can use url_launcher package)
    print("Launch URL: $url");
  }
}

// Base Widget for the App
class BaseWidget extends StatelessWidget {
  final Widget child;
  final appBar;
  final floatingWidget;
  final GlobalKey<ScaffoldState> scaffoldKey; // Added key for scaffold

  const BaseWidget({
    super.key,
    required this.child,
    required this.appBar,
    required this.scaffoldKey, // Initialize the key
    this.floatingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey, // Assign the key to the Scaffold
      appBar: appBar,
      floatingActionButton: floatingWidget,
      body: child,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: secondaryColor,
              ),
              child: const Text('Drawer Header Test'),
            ),
            ListTile(
              title: const Text('Item 1 test'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Item 2 test'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ユーザーの投稿機能
class CreatePost extends StatelessWidget {
  final Database database;

  const CreatePost({Key? key, required this.database}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    final TextEditingController commentController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    ValueNotifier<File?> selectedImageNotifier = ValueNotifier<File?>(null);

    Future<void> _pickImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        selectedImageNotifier.value = imageFile;
      }
    }

    Future<String> _saveImageToStorage(File image) async {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await image.copy(imagePath);
      return savedImage.path;
    }

    Future<void> _addTourismSpot() async {
      final imageFile = selectedImageNotifier.value;
      String? savedImagePath;
      if (imageFile != null) {
        savedImagePath = await _saveImageToStorage(imageFile);
      }

      final spot = {
        'name': nameController.text,
        'content': contentController.text,
        'location': locationController.text,
        'comment': commentController.text,
        if (savedImagePath != null) 'imagePath': savedImagePath,
      };

      final DatabaseQuery dbquery = DatabaseQuery(db: database);
      await dbquery.insertData('post', spot);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('投稿が完了しました')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('観光地を投稿', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('観光地名'),
              const SizedBox(height: 8.0),
              _buildTextField(
                controller: nameController,
                hintText: '観光地の名前を入力してください',
              ),
              const SizedBox(height: 16.0),

              _buildSectionTitle('詳細'),
              const SizedBox(height: 8.0),
              _buildTextField(
                controller: contentController,
                hintText: '観光地の詳細を入力してください',
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),

              _buildSectionTitle('県名'),
              const SizedBox(height: 8.0),
              _buildTextField(
                controller: locationController,
                hintText: '観光地のある県名を入力してください',
              ),
              const SizedBox(height: 16.0),

              _buildSectionTitle('コメント'),
              const SizedBox(height: 8.0),
              _buildTextField(
                controller: commentController,
                hintText: 'コメントを入力してください',
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),

              _buildSectionTitle('画像を追加'),
              const SizedBox(height: 8.0),
              ValueListenableBuilder<File?>(
                valueListenable: selectedImageNotifier,
                builder: (context, selectedImage, child) {
                  return GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade100,
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                selectedImage,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo,
                                    size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text(
                                  '画像を選択する',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24.0),

              Center(
                child: ElevatedButton.icon(
                  onPressed: _addTourismSpot,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 32.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.check, size: 20, color: Colors.white),
                  label: const Text(
                    '投稿する',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
      maxLines: maxLines,
    );
  }
}


