import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
// import 'package:elastic_app/global.dart';
import 'package:elastic_app/model/cluster_health.dart';
import 'package:elastic_client/elastic_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:settings_yaml/settings_yaml.dart';
import 'model/node.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'widgets/cluster_health.dart';

Future<void> main() async{
  HttpOverrides.global = CustomHttpOverrides();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elastic App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'Elastic App'),
    );
  }
  
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HttpTransport transport;
  late Client client;

  static bool isLoading = true;
  List<Node> nodesDataList = [];
  dynamic clusterHealth = const ClusterHealth(
    clusterName: "", status: " ", timedOut: true, numberOfNodes: 0, 
    numberOfDataNodes: 0, activePrimaryShards: 0, activeShards: 0, 
    relocatingShards: 0, initializingShards: 0, unassignedShards: 0, 
    numberOfPendingTasks: 0, numberOfInFlightFetch: 0, 
    taskMaxWaitingInQueueMillis: 0, activeShardsPercentAsNumber: 0
  );
  String configsFileName = 'settings.yml';
  String configsFilePath = '/storage/emulated/0/Android/data/com.example.elastic_app/files/settings.yml';
  bool configsInitializated = false;
  // late SettingsYaml settings;

  String elasticsearchURL = "https://192.168.1.16:9200/";
  String apiKey = "SjBDV3hvTUIyMFBuSGhoblktT1U6WlVVUk5WQXhRcWlvV0JQNzF2UHJjUQ==";
  String accessLogIndex = "workstation-apache-access-logs";
  String uriIndices = "_cat/indices";
  String uriClusterHealth = "_cluster/health";

  String filterTerm = "response";
  int numEvents = 0;
  int timeFrame = 2;  // Hours

  List<dynamic> fieldsList = [];

  final _formKey = GlobalKey<FormState>();
  final accessLogIndexController = TextEditingController();
  final numEventsController = TextEditingController();

  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = [];

  @override
  void initState(){
    super.initState();
    requestPermission(Permission.storage).then((permissionStatus){
      developer.log("Permission.storage isGranted: ${permissionStatus.isGranted}");

      // handle config file 
      _localPath.then((path){
        developer.log('path: $path');
        _configsFile(path).then((file){ // set configs file path

          File(file.uri.path).exists().then((exists){  // check if file exist befaure creating
            developer.log("${file.uri.path} exists: ${exists.toString()}");
            if(!exists){
              file.createSync();  // create configs file
              developer.log("configsFile created");
            }
            
          });

          setState(() {
            configsFilePath = file.uri.path;
            loadSettings(configsFilePath);
          });
          
        });
      });

      
    });


  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> initWidgetOptions() async{
    _widgetOptions.add(const Text(
      'loading ...',
    ));
    _widgetOptions.add(const Text(
      'Index 1: Business',
    ));
    _widgetOptions.add(const Text(
      'Index 2: School',
    ));
  }

  @override
  Widget build(BuildContext context) {
    initWidgetOptions();
    _widgetOptions[0] = ClusterHealthWidget(clusterHealth: clusterHealth, isLoading: isLoading);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
          // 
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Cluster',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner),
            label: 'Indices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.doorbell),
            label: 'Notifications',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          refreshClusterHealth();
        },
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Notification Settings'),
            ),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text("access logs index name"),
                  TextFormField(
                    // controller: accessLogIndexController,
                    initialValue: accessLogIndex,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'access logs index name'
                    ),
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      // accessLogIndexController.text = value!;
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      accessLogIndexController.text = value;
                      return null;
                    },
                  ),
                  TextFormField(
                    // controller: numEventsController,
                    keyboardType: TextInputType.number,
                    initialValue: numEvents.toString(),
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Number of events'
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      // accessLogIndexController.text = value!;
                      if (value == null || value.isEmpty) {
                        return 'Please enter some integer';
                      }
                      numEventsController.text = value;
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState!.validate()) {
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Processing Data')),
                          );
                          // update settings
                          saveSetting("accessLogIndex", accessLogIndexController.text);
                          saveSetting("numEvents", int.parse(numEventsController.text));
                          setState(() {
                            accessLogIndex = accessLogIndexController.text;
                            numEvents = int.parse(numEventsController.text);
                          });
                        }
                      },
                      child: const Text('save'),
                    ),
                  ),
                ],
              ),
            )

          ],
        )
      ),
    );
    
  }

  Future<PermissionStatus> requestPermission(Permission permission) async {
    final status = await permission.request();
    return status;
  }

  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    await directory!.create(recursive: true);
    return directory.path;
  }

  Future<File> _configsFile(String path) async {
    return File(join(path, configsFileName));
  }

  Future<SettingsYaml> loadSettings(String configsFilePath) async {
    final settings = SettingsYaml.load(pathToSettings: configsFilePath);
    if(settings.valueMap.isEmpty){
      developer.log("empty settings");
      settings['elasticsearchURL'] = elasticsearchURL;
      settings['apiKey'] = apiKey;
      settings['accessLogIndex'] = accessLogIndex;
      settings['uriIndices'] = uriIndices;
      settings['uriClusterHealth'] = uriClusterHealth;
      settings['numEvents'] = numEvents;
    }else{
      if(!configsInitializated){
        if(settings['elasticsearchURL'] == ''){
          settings['elasticsearchURL'] = 'https://192.168.1.16:9200/';
        }
        if(settings['apiKey'] == ""){
          settings['apiKey'] = 'SjBDV3hvTUIyMFBuSGhoblktT1U6WlVVUk5WQXhRcWlvV0JQNzF2UHJjUQ==';
        }
        if(settings['accessLogIndex'] == ""){
          settings['accessLogIndex'] = 'workstation-apache-access-logs';
        }
        if(settings['uriIndices'] == ''){
          settings['uriIndices'] = '_cat/indices';
        }
        if(settings['uriClusterHealth'] == ''){
          settings['uriClusterHealth'] = '_cluster/health';
        }
        if(settings['enabled'] == false){
          settings['enabled'] = true;
        }
        if(settings['numEvents'] == 0){
          settings['numEvents'] = 1;
        }

        setState(() {
          elasticsearchURL = settings['elasticsearchURL'] as String;
          apiKey = settings['apiKey'] as String;
          accessLogIndex = settings['accessLogIndex'] as String;
          uriIndices = settings['uriIndices'] as String;
          uriClusterHealth = settings['uriClusterHealth'] as String;
          numEvents = settings['numEvents'] as int;
        });
      }
    }
    
    await settings.save();
    configsInitializated = true;
    
    await initClient();
    refreshClusterHealth();

    return settings;
  }

  Future<void> saveSetting(String key, dynamic value) async{
    final settings = SettingsYaml.load(pathToSettings: configsFilePath);
    settings[key] = value;
    await settings.save();
  }
  //////////////////////////////////////////////////////////////////////////////
  /// Cluster Health
  //////////////////////////////////////////////////////////////////////////////
  Future<void> initClient() async{
    // init tansprot auth 
    transport = HttpTransport(
      url: elasticsearchURL, 
      authorization: 'ApiKey $apiKey'
    );
    // init client object
    client = Client(transport);
  }

  Future <ClusterHealth> clusterHealthData(String uri) async{
    http.Response httpResponse = await http.get( // fetch response from URI
      Uri.parse(uri),
      headers: {
        HttpHeaders.authorizationHeader: 'ApiKey $apiKey'
      },
    );
    if(httpResponse.statusCode == 200){ // if status 200 get list for nodes
      return ClusterHealth.fromJson(jsonDecode(httpResponse.body));  
    }else{
      developer.log('Request "fetchNodesData" failed with status: ${httpResponse.statusCode}');
      throw Exception('Exception: failed to load ClusterHealth data!');
    }
  }
  Future<void> refreshClusterHealth() async{
    isLoading = true;
    await clusterHealthData(
      elasticsearchURL+uriClusterHealth
    ).then((value) {
      setState(() {
        clusterHealth = value;
        isLoading = false;
        developer.inspect(clusterHealth);
      });
    }).onError((error, stackTrace) {
      throw Exception('Exception: failed to refresh ClusterHealth !');
    });
  }
  //////////////////////////////////////////////////////////////////////////////
}

class CustomHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
