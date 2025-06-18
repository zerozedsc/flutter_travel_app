import '../back_end/configs.dart';
import '../back_end/service.dart';
import '../back_end/page_controller.dart';
import '../pages/base_widget.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  final List<String> favourites = [];

  final List<String> recent = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {
            // Handle edit action
          },
          child: Text(
            LOCALIZATION.localize('edit'),
            style: TextStyle(color: primaryColor, fontSize: 15.5),
          ),
        ),
        title: Text(
          LOCALIZATION.localize('trip_planner'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Handle add button click
            },
            icon: Icon(
              Icons.add,
              color: primaryColor,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Favourites Section
              SectionTitle(title: LOCALIZATION.localize('favorite')),
              TripList(trips: favourites, accentColor: Colors.orange),
              const SizedBox(height: 16),

              // Recent Section
              SectionTitle(title: LOCALIZATION.localize('recent')),
              TripList(trips: recent, accentColor: Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

class TripList extends StatelessWidget {
  final List<String> trips;
  final Color accentColor;

  const TripList({required this.trips, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: trips
            .map((trip) => TripItem(trip: trip, color: accentColor))
            .toList(),
      ),
    );
  }
}

class TripItem extends StatelessWidget {
  final String trip;
  final Color color;

  const TripItem({required this.trip, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 5,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                trip,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }
}
