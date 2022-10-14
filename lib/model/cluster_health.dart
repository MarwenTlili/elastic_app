class ClusterHealth {
  final String clusterName;
  final String status;
  final bool timedOut;
  final int numberOfNodes;
  final int numberOfDataNodes;
  final int activePrimaryShards;
  final int activeShards;
  final int relocatingShards;
  final int initializingShards;
  final int unassignedShards;
  final int numberOfPendingTasks;
  final int numberOfInFlightFetch;
  final int taskMaxWaitingInQueueMillis;
  final double activeShardsPercentAsNumber;

  const ClusterHealth({
    required this.clusterName,
    required this.status,
    required this.timedOut,
    required this.numberOfNodes,
    required this.numberOfDataNodes,
    required this.activePrimaryShards,
    required this.activeShards,
    required this.relocatingShards,
    required this.initializingShards,
    required this.unassignedShards,
    required this.numberOfPendingTasks,
    required this.numberOfInFlightFetch,
    required this.taskMaxWaitingInQueueMillis,
    required this.activeShardsPercentAsNumber,
  });

  factory ClusterHealth.fromJson(Map<String, dynamic> json){
    return ClusterHealth(
      clusterName: json['cluster_name'], 
      status: json['status'], 
      timedOut: json['timed_out'], 
      numberOfNodes: json['number_of_nodes'], 
      numberOfDataNodes: json['number_of_data_nodes'], 
      activePrimaryShards: json['active_primary_shards'], 
      activeShards: json['active_shards'], 
      relocatingShards: json['relocating_shards'], 
      initializingShards: json['initializing_shards'], 
      unassignedShards: json['unassigned_shards'], 
      numberOfPendingTasks: json['number_of_pending_tasks'], 
      numberOfInFlightFetch: json['number_of_in_flight_fetch'], 
      taskMaxWaitingInQueueMillis: json['task_max_waiting_in_queue_millis'], 
      activeShardsPercentAsNumber: json['active_shards_percent_as_number']
    );
  }
}
