// import 'dart:convert';
// import 'dart:html';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:elastic_app/model/cluster_health.dart';
import 'package:elastic_client/elastic_client.dart';
import 'package:flutter/material.dart';
import 'package:dio/src/response.dart' as dio_resp;
// import 'package:elastic_client/elastic_client.dart';
// import 'package:universal_io/io.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:settings_yaml/settings_yaml.dart';
import 'global.dart';
import 'model/node.dart';
// import 'widgets/nodes.dart';
import 'widgets/cluster_health.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

Future<void> main() async{
  HttpOverrides.global = new CustomHttpOverrides();
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

  bool isLoading = true;
  List<Node> nodesDataList = [];
  late ClusterHealth clusterHealth;

  String configsFileName = 'settings.yml';
  File configsFile = File('');
  String tmp = "";

  String elasticsearchURL = "";
  String apiKey = "";
  String accessLogindex = "";
  String uriIndices = "";
  String uriClusterHealth = "";

  

  Future<void> initClient() async{
    // init tansprot auth 
    transport = HttpTransport(
      url: elasticsearchURL, 
      authorization: '$authorizationType $apiKey'
    );
    // init client object
    client = Client(transport);
  }
  
  Future<PermissionStatus> requestPermission(Permission permission) async {
    final status = await permission.request();
    return status;
  }

  Future<void> saveSettings(String filePath) async {
    final settings = SettingsYaml.load(pathToSettings: filePath);
    settings['elasticsearchURL'] = 'https://192.168.1.16:9200/';
    settings['ApiKey'] = 'SjBDV3hvTUIyMFBuSGhoblktT1U6WlVVUk5WQXhRcWlvV0JQNzF2UHJjUQ==';
    settings['accessLogIndex'] = 'workstation-apache-access-logs';
    settings['uriIndices'] = '_cat/indices';
    settings['uriClusterHealth'] = '_cluster/health';
    settings['enabled'] = true;
    await settings.save();
  }

  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    await directory!.create(recursive: true);
    return directory.path;
  }

  Future<File> _configsFile(String path) async {
    return File(join(path, configsFileName));
  }

  @override
  void initState(){
    super.initState();

    requestPermission(Permission.storage).then((permissionStatus){
      developer.log("Permission.storage isGranted: ${permissionStatus.isGranted}");

      // handle confis file 
      _localPath.then((path){
        developer.log('path: $path');
        _configsFile(path).then((file){ // set configs file path
          File(file.uri.path).exists().then((exists){  // check if file exist befaure creating
            developer.log("${file.uri.path} exists: ${exists.toString()}");
            if(!exists){
              file.createSync();  // create configs file
              developer.log("configsFile created");
            }
            setState(() {
              configsFile = file;
            });
          });
          
          saveSettings(file.uri.path);
          
        });
      });

    });

    initClient();
    // elasticClientTest(transport, client);
    // refreshNodes();
    
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: Column(
        children: [
          Text('access log index: $tmp')
        ],
        // children: [
        //   ClusterHealthWidget(clusterHealth: clusterHealth, isLoading: isLoading,)
        // ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var settings = SettingsYaml.load(pathToSettings: configsFile.uri.path);
          refreshClusterHealth();
          setState(() {
            tmp = SettingsYaml.load(pathToSettings: configsFile.uri.path)['accessLogIndex'];
          });
          // refreshNodes();
          // refreshClusterHealth();
        },
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  //////////////////////////////////////////////////////////////////////////////
  /// List of ES Nodes
  //////////////////////////////////////////////////////////////////////////////
  Future <List<Node>> nodesData(String uri) async{
    http.Response httpResponse = await http.get( // fetch response from URI
      Uri.parse(uri),
      headers: {
        HttpHeaders.authorizationHeader: 'ApiKey $apiKey'
      },
    );
    if(httpResponse.statusCode == 200){ // if status 200 get list for nodes
      dynamic jsonResponse = json.decode(httpResponse.body);  
      return List<Node>.from(
        jsonResponse.map((model) => Node.fromJson(model))
      );
    }else{
      developer.log('Request "fetchNodesData" failed with status: ${httpResponse.statusCode}');
      return [];
    }
  }
  Future<void> refreshNodes() async{
    isLoading = true;
    await nodesData(elasticsearchURL+uriNodes+'?format=json').then((value) {
      setState(() {
        if(value.isNotEmpty){
          nodesDataList = value;
        }
        isLoading = false;
        value.forEach((element) {
          developer.inspect(element);
        });
      });
    }).onError((error, stackTrace) {
      developer.log('Exception: refreshNodes');
    });
  }
  //////////////////////////////////////////////////////////////////////////////
  /// Cluster Health
  //////////////////////////////////////////////////////////////////////////////
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
    var settings = SettingsYaml.load(pathToSettings: configsFile.uri.path);
    await clusterHealthData(
      settings['elasticsearchURL']+settings['uriClusterHealth']
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

////////////////////////////////////////////////////////////////////////////////
Future<void> dioTest() async{
  Dio dio = new Dio();
  ByteData rootCertificate = await rootBundle.load('assets/cert/elasticsearch-ca.pem');
  ByteData clientCertificate = await rootBundle.load('assets/cert/client.crt');
  ByteData privateKey = await rootBundle.load('assets/cert/client.key');
  try {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client){
      dio.options.headers['Authorization'] = 'ApiKey Y3pobXVJTUJZb3hIRG5xdUJLc1o6aEpXTmJZc1dTMVdxUnpRcVVFLXM5UQ==';
      SecurityContext securityContext = SecurityContext(withTrustedRoots: true);
      securityContext.setTrustedCertificatesBytes(rootCertificate.buffer.asUint8List());
      securityContext.useCertificateChainBytes(clientCertificate.buffer.asUint8List());
      securityContext.usePrivateKeyBytes(privateKey.buffer.asUint8List());
      HttpClient httpClient = HttpClient(context:securityContext);
      return httpClient;
    };
    dio_resp.Response<String> response = await dio.get(elasticsearchURL);
    developer.log(response.data.toString());
  } catch(e) {
    developer.log(e.toString());
  }
}

Future<void> elasticClientTest(HttpTransport transport, Client client) async{
  try{
    transport = HttpTransport(
      url: elasticsearchURL, 
      authorization: '$authorizationType $apiKey',
      timeout: const Duration(minutes: 1)
    );
    SearchResult indicesSearchResult = await client.search(
      index: indexToMonitor,
      type: indexToMonitorType,
      query: Query.term('response', ['200'])
    );
    developer.log(indicesSearchResult.toMap().toString());
  }catch(e){
    developer.log(e.toString());
  } finally{
    await transport.close();
  }
}
////////////////////////////////////////////////////////////////////////////////


