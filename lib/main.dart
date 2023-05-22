import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: const MyHomePage(title: 'My Location'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _mapcontroller = MapController(initMapWithUserPosition: true);
  var markerMap = <String, String>{};


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapcontroller.listenerMapLongTapping.addListener(() async {
        //when will tap on map , we will add  new marker
        var position = _mapcontroller.listenerMapLongTapping.value;
        if (position != null) {
          await _mapcontroller.addMarker(position,
              markerIcon: const MarkerIcon(
                icon: Icon(
                  Icons.pin_drop_outlined,
                  color: Colors.cyan,
                  size: 50,
                ),
              ));
          var key = '${position!.latitude}_${position!.longitude}';
          markerMap[key] = markerMap.length.toString();
        }
      });
    });
  }

  @override
  void dispose() {
    _mapcontroller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: OSMFlutter(
        controller: _mapcontroller,
        mapIsLoading: const Center(child: CircularProgressIndicator()),
        trackMyPosition: true,
        initZoom: 12,
        minZoomLevel: 12,
        maxZoomLevel: 19,
        stepZoom: 2.0,
        userLocationMarker: UserLocationMaker(
            personMarker: const MarkerIcon(
              icon: Icon(Icons.person, color: Colors.greenAccent, size: 40),
            ),
            directionArrowMarker: const MarkerIcon(
              icon: Icon(Icons.location_on_sharp,
                  color: Colors.black54, size: 51),
            )),
        roadConfiguration: const RoadOption(roadColor: Colors.red),
        markerOption: MarkerOption(
            defaultMarker: const MarkerIcon(
                icon: Icon(
          Icons.person_pin_circle,
          size: 50,
          color: Colors.greenAccent,
        ))),
        onMapIsReady: (isRady) async {
          if (isRady) {
            await Future.delayed(Duration(seconds: 1), () async {
              await _mapcontroller.currentLocation();
            });
          }
        },
        onGeoPointClicked: (geopoint) {
          var key = '${geopoint!.latitude}_${geopoint!.longitude}';
          //when user click to marker
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Card(
                  child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Position ${markerMap['key']}',
                                    style: const TextStyle(
                                      fontSize: 50,
                                      color: Colors.grey,
                                    )),
                                const Divider(
                                  thickness: 3,
                                  indent: 20, // empty space to the leading edge of divider.
                                  endIndent: 20, // empty space to the trailing edge of the divider.
                                  color: Colors.pinkAccent, // The color to use when painting the line.
                                  height: 60,

                                ),
                                Text(key,),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context,),
                            child: const Icon(Icons.clear),
                          )
                        ],
                      )),
                );
              });
        },
      ),
    );
  }
}
