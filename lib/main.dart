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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
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
          var markerMap =<String,String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
     _mapcontroller.listenerMapLongTapping.addListener(() async{
       //when will tap on map , we will add  new marker
       var position= _mapcontroller.listenerMapLongTapping.value;
       if (position!=null){
         await _mapcontroller.addMarker(position,markerIcon: const MarkerIcon(
         icon: Icon(Icons.pin_drop,color: Colors.cyan,size: 48,),
         ));
         //Add Marker to map, for hold information of marker in case
         //we want use it
         var key = '${position!.latitude}_${position!.longitude}';
         markerMap[key] = markerMap.length.toString();

       }

     });
    });
    
  }
  @override
  void dispose(){
  _mapcontroller.dispose();
   super.dispose();

}


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: OSMFlutter(controller: _mapcontroller,
        mapIsLoading: const Center(child: CircularProgressIndicator()
        ),
        trackMyPosition: true,
        initZoom: 12,
        minZoomLevel: 12,
        maxZoomLevel: 19,
        stepZoom: 2.0,

        userLocationMarker: UserLocationMaker(
            personMarker: const MarkerIcon(
              icon: Icon(
                  Icons.person, color: Colors.greenAccent, size: 40),
            ),
            directionArrowMarker: const MarkerIcon(
              icon: Icon(Icons.location_on, color: Colors.black54, size: 51),
            )
        ),

        roadConfiguration: const RoadOption(roadColor: Colors.red),
        markerOption: MarkerOption(
            defaultMarker: const MarkerIcon(
              icon: Icon(
                Icons.person_pin_circle,
                color: Colors.greenAccent,
                size: 50,

              ),
            )
        ),

        onMapIsReady: (isRady) async {
          if (isRady) {
            await Future.delayed( Duration(seconds: 1), () async {
              await _mapcontroller.currentLocation();
            });
          }
        },

        onGeoPointClicked: (geopoint){
          var key = '${geopoint!.latitude}_${geopoint!.longitude}';
        //when user click to marker
          showModalBottomSheet(context: context, builder:(context){
            return Card(
              child:Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      Text('Position ${markerMap['key']}',
                          style: const TextStyle(
                            fontSize: 50,
                            color: Colors.black,
                          )

                      ),
                        const Divider(thickness: 1,),
                        Text(key,
                        ),
                      ],

                    )
                      ,),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.clear),
                    )
                  ],
                )
              ),
            );
          });
        },
      ),
    );
  }
}