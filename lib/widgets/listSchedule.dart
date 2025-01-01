import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
class listSchedule extends StatefulWidget {
  const listSchedule({super.key});

  @override
  State<listSchedule> createState() => _listScheduleState();
}

class _listScheduleState extends State<listSchedule> {

  List<Map<String,dynamic>> stopNames = [] ;

  List<Map<String, dynamic>> filteredStopNames = [];

  final DatabaseReference ref = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    listStop();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search by stop name",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => filterStops(value),
            ),
          ),
        ),
      body: ListView.separated(

          itemBuilder: (context, index)  {
            final stop = filteredStopNames[index];
            return Card(

              child:
              InkWell(
                onTap: (){
                  Navigator.pop(context,filteredStopNames[index]["name"]);
                },
                child: Padding(
                    padding: EdgeInsets.all(5),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: Icon(Icons.add_business_rounded),
                        ),
                        Text(filteredStopNames[index]["name"],
                          style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)

                      ],
                  ),
                ),
                ),
              ),
              
            );
          },



          separatorBuilder: (context, index) => const Divider(
        color: Colors.grey,
        thickness: 1,
      ),
          itemCount: filteredStopNames.length
      ),
    );
  }

  Future<void> listStop() async {
    DatabaseEvent stopsEvent = await ref.child('Stop').once();
    try {
      if (stopsEvent.snapshot.exists) {
        final stopsData = stopsEvent.snapshot.value as List<dynamic>; // Assuming Stop is a list
        setState(() {
        stopNames = stopsData
          .where((stop) => stop != null)
            .map((stop) => {
              'name': stop['name'].toString() ?? 'Unknown',


  })
      .toList();
        filteredStopNames = List.from(stopNames);
});




        print(
            "Stop names fetched://///////////////////////////////////////////////// $stopNames");

      } else {
        print("No stop names found");
      }
    }catch(e){
      print("ERRORRRRRRRRRRRRR : $e");
    }
  }
  void filterStops(String value) {
    setState(() {
      filteredStopNames = stopNames
          .where((stop) =>
          stop['name'].toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }
}
