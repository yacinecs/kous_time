import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'cache/cache_helper.dart';

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> schedules = [];
  List<Map<String, dynamic>> filteredSchedules = [];
  Map<dynamic, String> stopNames = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : schedules.isEmpty
          ? const Center(child: Text("No schedules available"))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search by stop name",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => filterSchedules(value),
            ),
          ),
          Expanded(
            child: ListView.separated(
              cacheExtent: 100.0,
              itemCount: filteredSchedules.length,
              itemBuilder: (context, index) {
                final schedule = filteredSchedules[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Departure Stop: ${schedule['dstopName']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Arrival Stop: ${schedule['astopName']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Departure Time: ${schedule['departureTime']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Arrival Time: ${schedule['arrivalTime']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(
                color: Colors.grey,
                thickness: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fetch schedules and stop names
  Future<void> fetchSchedules() async {
    try {
      // Try to get cached schedules first
      List<Map<String, dynamic>> cachedSchedules = await CacheHelper.getCachedSchedules();
      if (cachedSchedules.isNotEmpty) {
        // If cached data exists, use it
        setState(() {
          schedules = cachedSchedules;
          filteredSchedules = List.from(schedules);
          isLoading = false;
        });
        return; // Skip Firebase fetch if data is cached
      }

      // Fetch all stop names
      DatabaseEvent stopsEvent = await ref.child('Stop').once();
      if (stopsEvent.snapshot.exists) {
        final stopsData = stopsEvent.snapshot.value as List<dynamic>;
        stopNames = {
          for (int i = 0; i < stopsData.length; i++)
            i.toString(): stopsData[i]['name'] ?? 'Unknown'
        };
        print("Stop names fetched: $stopNames");
      } else {
        print("No stop names found");
      }

      // Fetch schedules from Firebase
      DatabaseEvent schedulesEvent = await ref.child('Schedule').once();
      if (schedulesEvent.snapshot.exists) {
        final schedulesData = schedulesEvent.snapshot.value as List<dynamic>;
        schedules = schedulesData
            .where((schedule) => schedule != null)
            .map((schedule) => {
          'dstopName': stopNames[schedule['dstopId'].toString()] ?? 'Unknown',
          'astopName': stopNames[schedule['astopId'].toString()] ?? 'Unknown',
          'departureTime': schedule['departureTime'] ?? 'N/A',
          'arrivalTime': schedule['arrivalTime'] ?? 'N/A',
        })
            .toList();

        // Cache the fetched schedules
        await CacheHelper.cacheSchedules(schedules);

        setState(() {
          filteredSchedules = List.from(schedules);
          isLoading = false;
        });
        print("Schedules fetched and cached: $schedules");
      } else {
        print("No schedules found");
      }
    } catch (e) {
      print("Error fetching schedules: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }




  // Filter schedules based on search query
  void filterSchedules(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredSchedules = List.from(schedules);
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredSchedules = schedules.where((schedule) {
        return schedule['dstopName'].toLowerCase().contains(lowerQuery) ||
            schedule['astopName'].toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

}
