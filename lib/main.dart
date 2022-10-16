import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:elastic_app/model/cluster_health.dart';
import 'package:elastic_app/widgets/nodes.dart';
import 'package:elastic_app/widgets/notifications.dart';
import 'package:elastic_client/elastic_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:settings_yaml/settings_yaml.dart';
import 'global.dart';
import 'model/node.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'widgets/cluster_health.dart';
import 'model/access_log.dart';

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
  //////////////////////////////////////////////////////////////////////////////
  List<Node> nodesList = [];
  dynamic clusterHealth = const ClusterHealth(
    clusterName: "", status: " ", timedOut: true, numberOfNodes: 0, 
    numberOfDataNodes: 0, activePrimaryShards: 0, activeShards: 0, 
    relocatingShards: 0, initializingShards: 0, unassignedShards: 0, 
    numberOfPendingTasks: 0, numberOfInFlightFetch: 0, 
    taskMaxWaitingInQueueMillis: 0, activeShardsPercentAsNumber: 0
  );
  //////////////////////////////////////////////////////////////////////////////
  String configsFileName = 'settings.yml';
  String configsFilePath = '/storage/emulated/0/Android/data/com.example.elastic_app/files/settings.yml';
  //////////////////////////////////////////////////////////////////////////////
  
  //////////////////////////////////////////////////////////////////////////////
  late SettingsYaml settingsYaml;
  String elasticsearchURL = "https://192.168.1.16:9200/";
  String apiKey = "SjBDV3hvTUIyMFBuSGhoblktT1U6WlVVUk5WQXhRcWlvV0JQNzF2UHJjUQ==";
  String accessLogIndex = "access-log-2022";
  String uriIndices = "_cat/indices";
  String uriClusterHealth = "_cluster/health";
  String uriNodes = "_cat/nodes/?format=json";
  String filterTerm = "response";
  int numEvents = 1;
  int timeFrame = 2;  // Hours
  //////////////////////////////////////////////////////////////////////////////
  String dropdownValue = formResponsesList.first;
  //////////////////////////////////////////////////////////////////////////////
  List<AccessLog> notificationsList = [];

  List<dynamic> fieldsList = [];

  final _formKey = GlobalKey<FormState>();
  final accessLogIndexController = TextEditingController();
  final numEventsController = TextEditingController();
  final timeFrameController = TextEditingController();

  int _selectedNav = 0;

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

    fetchNodes(http.Client(), elasticsearchURL+uriNodes);
    timer = Timer.periodic(
      const Duration(seconds: 3), (Timer t) => fetchAccessLogsResponse(
        http.Client(), elasticsearchURL+accessLogIndex+"/_search", ""
      )
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedNav = index;
    });
  }

  Future<void> initWidgetOptions() async{
    _widgetOptions.add(const Text(
      'loading ...',
    ));
    _widgetOptions.add(const Text(
      'loading ...',
    ));
    _widgetOptions.add(const Text(
      'loading ...',
    ));
  }

  @override
  Widget build(BuildContext context) {
    initWidgetOptions();
    _widgetOptions[0] = ClusterHealthWidget(clusterHealth: clusterHealth, isLoading: isLoading);
    _widgetOptions[1] = NodesWidget(nodesList: nodesList, isLoading: isLoading);
    _widgetOptions[2] = NotificationsWidget(notificationsList: notificationsList, isLoading: isLoading);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Column(
          children: [
            _widgetOptions.elementAt(_selectedNav),
          ],
        )
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Cluster',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_tree_rounded),
            label: 'Nodes',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.doorbell,
              color: notificationsList.isNotEmpty ? Colors.red: Colors.grey,
            ),
            label: 'Notifications',
          ),
        ],
        currentIndex: _selectedNav,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          refreshClusterHealth();
          fetchNodes(http.Client(), elasticsearchURL+uriNodes);
          fetchAccessLogsResponse(http.Client(), elasticsearchURL+accessLogIndex+"/_search", "");
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
                  const Text('Response Code'),
                  DropdownButton<String>(
                    value: dropdownValue,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String? value) {
                      developer.inspect(value);
                      setState(() {
                        dropdownValue = value!;
                      });
                    },
                    items: formResponsesList.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                    }).toList()
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
                  TextFormField(
                    keyboardType: TextInputType.number,
                    initialValue: timeFrame.toString(),
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Time Frame (in Hours)'
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some integer';
                      }
                      timeFrameController.text = value;
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Saving settings ...')),
                          );

                          // update settings
                          settingsYaml['accessLogIndex'] = accessLogIndexController.text;
                          settingsYaml['numEvents'] = int.parse(numEventsController.text);
                          settingsYaml['timeFrame'] = int.parse(timeFrameController.text);
                          settingsYaml.save();

                          // keep ui state
                          setState(() {
                            accessLogIndex = accessLogIndexController.text;
                            numEvents = int.parse(numEventsController.text);
                            timeFrame = int.parse(timeFrameController.text);
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
    settingsYaml = SettingsYaml.load(pathToSettings: configsFilePath);

    if(settingsYaml['elasticsearchURL'] == null){
      settingsYaml['elasticsearchURL'] = elasticsearchURL;
    }else{
      elasticsearchURL = settingsYaml['elasticsearchURL'] as String;
    }

    if(settingsYaml['apiKey'] == null){
      settingsYaml['apiKey'] = apiKey;
    }else{
      apiKey = settingsYaml['apiKey'] as String;
    }

    if(settingsYaml['accessLogIndex'] == null){
      settingsYaml['accessLogIndex'] = accessLogIndex;
    }else{
      accessLogIndex = settingsYaml['accessLogIndex'] as String;
    }

    if(settingsYaml['uriIndices'] == null){
      settingsYaml['uriIndices'] = uriIndices;
    }else{
      uriIndices = settingsYaml['uriIndices'] as String;
    }

    if(settingsYaml['uriClusterHealth'] == null){
      settingsYaml['uriClusterHealth'] = uriClusterHealth;
    }else{
      uriClusterHealth = settingsYaml['uriClusterHealth'] as String;
    }

    if(settingsYaml['uriNodes'] == null){
      settingsYaml['uriNodes'] = uriNodes;
    }else{
      uriNodes = settingsYaml['uriNodes'] as String;
    }

    if(settingsYaml['numEvents'] == null){
      settingsYaml['numEvents'] = numEvents;
    }else{
      numEvents = settingsYaml['numEvents'] as int;
    }

    if(settingsYaml['timeFrame'] == null){
      settingsYaml['timeFrame'] = timeFrame;
    }else{
      timeFrame = settingsYaml['timeFrame'] as int;
    }
    
    settingsYaml.save();
    
    refreshClusterHealth();

    return settingsYaml;
  }

  Future<void> saveSetting(String key, dynamic value) async{
    settingsYaml = SettingsYaml.load(pathToSettings: configsFilePath);
    settingsYaml[key] = value;
    settingsYaml.save();
  }
  //////////////////////////////////////////////////////////////////////////////
  /// Cluster Health
  //////////////////////////////////////////////////////////////////////////////
  Future <ClusterHealth> clusterHealthData(String uri) async{
    http.Response httpResponse = await http.get( // fetch response from URI
      Uri.parse(uri),
      headers: {HttpHeaders.authorizationHeader: 'ApiKey $apiKey'},
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
        // developer.inspect(clusterHealth);
      });
    }).onError((error, stackTrace) {
      throw Exception('Exception: failed to refresh ClusterHealth !');
    });
  }
  //////////////////////////////////////////////////////////////////////////////
  // A function that converts a response body into a List<Node>.
  List<Node> parseNodes(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    List<Node> list = parsed.map<Node>((json) => Node.fromJson(json)).toList();
    nodesList = list;
    return list;
  }
  Future<List<Node>> fetchNodes(http.Client client, String uri) async{
    isLoading = true;
    final response = await client.get(Uri.parse(uri),headers: {HttpHeaders.authorizationHeader: 'ApiKey $apiKey'});
    isLoading = false;
    return parseNodes(response.body);
  }
  //////////////////////////////////////////////////////////////////////////////
  List<AccessLog> parseAccessLogsResponse(String responseBody){
    final parsed = jsonDecode(responseBody).cast<String, dynamic>();
    // developer.log('hits: ${parsed["hits"]["total"]["value"]}');
    if(parsed['error'] != null){
      developer.log(parsed.toString());
      return [];
    }
    List<AccessLog> list = parsed['hits']['hits'].map<AccessLog>((json) => AccessLog.fromJson(json)).toList();
    // checkForAccessLogsEvent(list);
    return list;
  }
  Future<List<AccessLog>> fetchAccessLogsResponse(http.Client client, String uri, String response) async{
    isLoading = true;
    String nowSubHours = DateTime.now().subtract(Duration(hours: timeFrame)).toIso8601String();
    // print(nowSubHours);
    String body = '{ "query": {"query_string": { "query": "@timestamp:[$nowSubHours TO now] AND (response:$dropdownValue)" }}}';
    final response = await client.post(
      Uri.parse(uri),
      headers: {
        HttpHeaders.authorizationHeader: 'ApiKey $apiKey',
        HttpHeaders.contentTypeHeader: 'application/json'
      },
      body: body
    );
    isLoading = false;
    // developer.log(body);
    // developer.log(response.body);
    var data = parseAccessLogsResponse(response.body);
    // List<dynamic> hits = data['hits']['hits'].cast<Map<String, dynamic>>();
    // developer.inspect(data);
    print("numEvents: $numEvents, timeFrame: $timeFrame");
    return data;
  }

  Future<void> checkForAccessLogsEvent(List<AccessLog> data) async{
    if(data.length >= numEvents){ // notify
      setState(() {
        notificationsList = data;
      });
      print("checkForAccessLogsEvent called");

      // data.every((element) => notificationsList.contains(element));

      // for (AccessLog element in data) {
      //   if (notificationsList.isNotEmpty && (notificationsList.contains(element) == false)) {
      //     print("add element to notificationsList");
      //     setState(() {
      //       notificationsList.add(element);
      //     });
      //   }
      // }

      // developer.inspect(notificationsList);

    }
  }

}

class CustomHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
