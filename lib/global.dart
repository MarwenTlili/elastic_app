String host = '192.168.1.16';
String port = '9200';
String elasticsearchURL = 'https://$host:$port/';

String apiKey = 'SjBDV3hvTUIyMFBuSGhoblktT1U6WlVVUk5WQXhRcWlvV0JQNzF2UHJjUQ==';
String authorizationType = 'ApiKey';

/// ip, heap.percent ram.percent, cpu
/// load_1m, load_5m, load_15m 
/// node.role, master, name
String uriNodes = '_cat/nodes';

/// health, status, index, uuid, pri, rep, 
/// docs.count, docs.deleted
/// store.size, pri.store.size
String uriIndices = '_cat/indices';

String uriClusterHealth = '_cluster/health';

String indexToMonitor = 'workstation-apache-access-logs';
String indexToMonitorType = '_doc';
