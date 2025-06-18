import 'configs.dart';

import '../db/database_view.dart';
import '../pages/search_page.dart';
import '../pages/home_page.dart';
import '../pages/planner_page.dart';
import '../pages/blank_page.dart';
import '../pages/settings_page.dart';

// page controller

class PageControllerClass extends StatefulWidget {
  final state;

  const PageControllerClass({super.key, this.state});

  @override
  State<PageControllerClass> createState() =>
      // ignore: no_logic_in_create_state
      PageControllerClassState(state: state);
}

class PageControllerClassState extends State<PageControllerClass> {
  final state;
  late String initialQuery;
  PageControllerClassState({this.state}) {
    initialQuery = state?['query'] ?? '';
  }

  int _currentIndex = 0;
  late final List<Widget> _children = [
    const MyHomePage(title: 'Simple Travel App'),
    const SearchPage(initialQuery: ''),
    const PlannerPage(),
    const SettingPage(),
    // const DatabaseViewPage(),
  ];
  final PageController _pageController = PageController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // If initialQuery is provided, navigate directly to index 1
    if (initialQuery.isNotEmpty) {
      _children[1] = SearchPage(initialQuery: initialQuery);
      _currentIndex = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageController.jumpToPage(1); // Directly jump to page 1
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onTabTapped(int index) {
    setState(() {
      if (index == 1) {
        _children[1] = const SearchPage(initialQuery: '');
      }

      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
    // Fluttertoast.showToast(
    //   msg: "Toast Message $index",
    //   toastLength: Toast.LENGTH_SHORT,
    //   gravity: ToastGravity.TOP_RIGHT,
    //   backgroundColor: primaryColor,
    //   textColor: Colors.white,
    //   fontSize: 16.0,
    // );
  }

  void navigateToSearchPage(String query) {
    print("$query received in PageControllerClass");

    setState(() {
      _children[1] =
          SearchPage(initialQuery: query); // update SearchPage with new query
      _currentIndex = 1;
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutSine,
      );
    });
  }

  // Bottom navigation bar items
  List<BottomNavigationBarItem> bottomNavBarItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Search',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today),
      label: 'Planner',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: 'Settings',
    ),
    // BottomNavigationBarItem(
    //   icon: Icon(Icons.data_object_sharp),
    //   label: 'DATABASE_VIEW',
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        physics:
            const NeverScrollableScrollPhysics(), // to prevent swipe to switch pages
        children: _children,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: bottomNavBarItems,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: onTabTapped,
        currentIndex: _currentIndex,
      ),
    );
  }
}
