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
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Cluster Health",
            style: TextStyle(
              height: 2,
              fontSize: 32,
              fontWeight: FontWeight.bold
            )
          ),
          Text(
            'Cluster Name: ${widget.clusterHealth.clusterName}',
            style: const TextStyle(
              height: 2,
              fontSize: 16,
              fontWeight: FontWeight.bold
            )
          ),
          Text(
            'Status: ${widget.clusterHealth.status}',
            style: const TextStyle(
              height: 2,
              fontSize: 16,
              fontWeight: FontWeight.bold
            )
          ),
          Text(
            'Timed Out: ${widget.clusterHealth.timedOut}',
            style: const TextStyle(
              height: 2,
              fontSize: 16,
              fontWeight: FontWeight.bold
            )
          ),
          Text(
            'Number Of Nodes: ${widget.clusterHealth.numberOfNodes}',
            style: const TextStyle(
              height: 2,
              fontSize: 16,
              fontWeight: FontWeight.bold
            )
          ),
          Text(
            'Number Of Data Nodes: ${widget.clusterHealth.numberOfDataNodes}',
            style: const TextStyle(
              height: 2,
              fontSize: 16,
              fontWeight: FontWeight.bold
            )
          ),
          Text(
            'Active Primary Shards: ${widget.clusterHealth.activePrimaryShards}',
            style: const TextStyle(
              height: 2,
              fontSize: 16,
              fontWeight: FontWeight.bold
            )
          ),
          Text(
            'Active Shards: ${widget.clusterHealth.activeShards}',
            style: const TextStyle(
              height: 2,
              fontSize: 16,
              fontWeight: FontWeight.bold
            )
          ),
          Text(
            'Relocating Shards: ${widget.clusterHealth.relocatingShards}',
            style: const TextStyle(
              height: 2,
              fontSize: 16,
              fontWeight: FontWeight.bold
            )
          ),
          Text(
            'Initializing Shards: ${widget.clusterHealth.initializingShards}',
            style: const TextStyle(
              height: 2,
              fontSize: 16,
              fontWeight: FontWeight.bold
            )
          ),
          Text(
            'Unassinged Shards: ${widget.clusterHealth.unassignedShards}',
            style: const TextStyle(
              height: 2,
              fontSize: 16,
              fontWeight: FontWeight.bold
            )
          ),
          Text(
            'Number Of Pending Tasks: ${widget.clusterHealth.numberOfPendingTasks}',
            style: const TextStyle(
              height: 2,
              fontSize: 16,
              fontWeight: FontWeight.bold
            )
          ),
          Text(
            'Number Of In Flight Fetch: ${widget.clusterHealth.numberOfInFlightFetch}',
            style: const TextStyle(
              height: 2,
              fontSize: 16,
              fontWeight: FontWeight.bold
            )
          ),
          Text(
            'Task Max Waiting In Queue: ${widget.clusterHealth.taskMaxWaitingInQueueMillis} /ms',
            style: const TextStyle(
              height: 2,
              fontSize: 16,
              fontWeight: FontWeight.bold
            )
          ),
          Text(
            'Active Shards Percent (As Number): ${widget.clusterHealth.activeShardsPercentAsNumber.toStringAsFixed(3)}',
            style: const TextStyle(
              height: 2,
              fontSize: 16,
              fontWeight: FontWeight.bold
            )
          ),
          
        ],
      ),
    );
  }
  
}
