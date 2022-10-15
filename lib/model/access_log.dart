class AccessLog {
  final String id;
  final String index;
  final String sourceModuleName;
  final String sourceReqest;
  final String sourceMethod;
  final String sourceTimestamp;
  final int sourceResponse;

  const AccessLog({
    required this.id,
    required this.index,
    required this.sourceModuleName,
    required this.sourceReqest,
    required this.sourceMethod,
    required this.sourceTimestamp,
    required this.sourceResponse,
  });
  
  factory AccessLog.fromJson(Map<String,dynamic> json){
    return AccessLog(
      id: json['_id'],
      index: json['_index'], 
      sourceModuleName: json['_source']['module_name'], 
      sourceReqest: json['_source']['request'], 
      sourceMethod: json['_source']['method'], 
      sourceTimestamp: json['_source']['@timestamp'], 
      sourceResponse: json['_source']['response']
      
    );
  }
}
