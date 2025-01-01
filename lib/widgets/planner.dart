import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'listSchedule.dart';

class Planner extends StatefulWidget {
  const Planner({super.key});

  @override
  State<Planner> createState() => _PlannerState();
}

class _PlannerState extends State<Planner> {
@override
  void initState() {
    searchable = false;
    fetchSchedulesF();
    // TODO: implement initState
    super.initState();
  }
  String nameFrom = 'From';
  String nameTo = 'To';
  final DatabaseReference ref = FirebaseDatabase.instance.ref();
  Map<dynamic, String> stopNames = {};
  late bool searchable;
List<Map<String, dynamic>> filtredSchedules = [];
  List<Map<String, dynamic>> schedules = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Route Planner"),centerTitle: true,backgroundColor: Colors.white,),
      body: Column(
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  color: Colors.white,
                  child: SizedBox(
                    height: 100,
                    width:  MediaQuery.of(context).size.width * 0.95,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    var selectedStop = await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => listSchedule()),
                                    );
                                    if(selectedStop != null){
                                      setState(() {
                                        nameFrom = selectedStop ;
                                      });
                                    }

                                  },
                                  child: SizedBox(
                                    height: 40,
                                    width: double.infinity,
                                    child: Row(
                                      children: [
                                        Icon(Icons.abc),

                                        Padding(
                                          padding: const EdgeInsets.only(left: 20),
                                          child: Text(nameFrom),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(
                                  color: Colors.black,
                                  thickness: 1,
                                  height: 1, // Adjust spacing around the divider
                                ),
                                InkWell(

                                  onTap: () async {
                                    final selectedStop = await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => listSchedule()),
                                    );
                                  if(selectedStop != null){
                                    setState(() {
                                      nameTo = selectedStop ;
                                    });
                                  }},
                                  child: SizedBox(
                                    height: 40,
                                    width: double.infinity,
                                    child: Row(
                                      children: [
                                        Icon(Icons.abc),

                                        Padding(
                                          padding: const EdgeInsets.only(left: 20),
                                          child: Text(nameTo),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {

                              if(nameFrom != "From" && nameTo != "To"){
                                setState(() {
                                  String temp = nameFrom;
                                  nameFrom = nameTo;
                                  nameTo = temp;
                                });

                              }

                            },
                            icon: Icon(Icons.flip_camera_android),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          TextButton(onPressed: () {
            if(nameFrom != "From" && nameTo != "To"){
              setState(() {
                filter(nameFrom, nameTo);
                searchable = true;
              });
            }
          }, child: Text("Search")),
          filtredSchedules.isNotEmpty && searchable ?
          Expanded(
            child: ListView.separated(
              itemCount: filtredSchedules.length,
              itemBuilder: (context, index) {
                final schedule = filtredSchedules[index];
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
          ): SizedBox(),
        ],

      ),
        backgroundColor: Color(0xFFF1F1F1),
    );
  }

  Future<void> fetchSchedulesF() async {
    try {
      // Fetch all stop names
      DatabaseEvent stopsEvent = await ref.child('Stop').once();
      if (stopsEvent.snapshot.exists) {
        final stopsData = stopsEvent.snapshot.value as List<dynamic>; // Assuming Stop is a list
        stopNames = {
          for (int i = 0; i < stopsData.length; i++)
            i.toString(): stopsData[i]['name'] ?? 'Unknown'
        };
        //print("Stop names fetched: $stopNames");
      } else {
        print("No stop names found");
      }

      // Fetch schedules
      DatabaseEvent schedulesEvent = await ref.child('Schedule').once();
      if (schedulesEvent.snapshot.exists) {
        final schedulesData = schedulesEvent.snapshot.value as List<dynamic>; // Assuming Schedule is a list
        schedules = schedulesData
            .where((schedule) => schedule != null

        )
            .map((schedule) => {
          'dstopName': stopNames[schedule['dstopId'].toString()] ?? 'Unknown',
          'astopName': stopNames[schedule['astopId'].toString()] ?? 'Unknown',
          'departureTime': schedule['departureTime'] ?? 'N/A',
          'arrivalTime': schedule['arrivalTime'] ?? 'N/A',
        })
            .toList();
        setState(() {

        });
        //print("Schedules fetched: //////////////////////////////////////////////// $schedules");
      } else {
        print("No schedules found");
      }
    } catch (e) {
      print("Error fetching schedules: $e");
    }
  }
  void filter(String f, String t) {
    try{
      filtredSchedules = [];
    for ( int i=0; i < schedules.length;i++){
      if(schedules[i]['dstopName'] == f && schedules[i]['astopName'] == t){
        filtredSchedules.add(schedules[i]);
      }
    }

    print("filtred Schedules //////////////////////////////////////////////// $filtredSchedules");
  }catch(e){
      print("ERROR //////////////////////////////////////////////// $e");
    }
  }
}
