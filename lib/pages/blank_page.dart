import '../back_end/configs.dart';
import '../pages/base_widget.dart';

class BlankPage extends StatefulWidget {
  const BlankPage({super.key});

  @override
  State<BlankPage> createState() => _BlankPage();
}

class _BlankPage extends State<BlankPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      scaffoldKey: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          LOCALIZATION.localize("coming_soon"),
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      child: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon or Image for a travel theme
              Icon(
                Icons.airplanemode_active,
                size: 80,
                color: primaryColor,
              ),
              const SizedBox(height: 20),

              // "Coming Soon" Text
              Text(
                LOCALIZATION.localize("coming_soon"),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              // Subheading with a travel-related feel
              const SizedBox(height: 8),
              Text(
                LOCALIZATION.localize("exciting_travel_coming"),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),

              // Add some spacing
              const SizedBox(height: 20),

              // A button to go back or explore
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.pop(context);
              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: primaryColor,
              //     padding:
              //         const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(20),
              //     ),
              //   ),
              //   child: Text(
              //     LOCALIZATION.localize("go_back"),
              //     style: const TextStyle(fontSize: 16, color: Colors.white),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
