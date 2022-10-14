import 'package:flutter/material.dart';
import 'package:elastic_app/model/cluster_health.dart';

class ClusterHealthWidget extends StatefulWidget {
  const ClusterHealthWidget({
    Key? key,
    required this.clusterHealth,
    required this.isLoading,
  }) : super(key: key);

  final ClusterHealth clusterHealth ;
  final bool isLoading;

  @override
  State<StatefulWidget> createState() => ClusterHealthWidgetState();
}

class ClusterHealthWidgetState extends State<ClusterHealthWidget>{
  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Cluster Health",
          style: TextStyle(
            height: 2,
            fontSize: 24,
            fontWeight: FontWeight.bold
          )
        ),
        Text('Cluster Name: ${widget.clusterHealth.clusterName}'),
        Text('Status: ${widget.clusterHealth.status}'),
        Text('Timed Out: ${widget.clusterHealth.timedOut}'),
        Text('Number Of Nodes: ${widget.clusterHealth.numberOfNodes}'),
        Text('Number Of Data Nodes: ${widget.clusterHealth.numberOfDataNodes}'),
        Text('Active Primary Shards: ${widget.clusterHealth.activePrimaryShards}'),
        Text('Active Shards: ${widget.clusterHealth.activeShards}'),
        Text('Relocating Shards: ${widget.clusterHealth.relocatingShards}'),
        Text('Initializing Shards: ${widget.clusterHealth.initializingShards}'),
        Text('Unassinged Shards: ${widget.clusterHealth.unassignedShards}'),
        Text('Number Of Pending Tasks: ${widget.clusterHealth.numberOfPendingTasks}'),
        Text('Number Of In Flight Fetch: ${widget.clusterHealth.numberOfInFlightFetch}'),
        Text('Task Max Waiting In Queue: ${widget.clusterHealth.taskMaxWaitingInQueueMillis} /ms'),
        Text('Active Shards Percent (As Number): ${widget.clusterHealth.activeShardsPercentAsNumber}'),

      ],
    );
  }
  
}
