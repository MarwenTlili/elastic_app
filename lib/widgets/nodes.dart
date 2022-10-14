import 'package:flutter/material.dart';
import 'package:elastic_app/model/node.dart';

class NodesWidget extends StatefulWidget{
  const NodesWidget({
    Key? key,
    required this.nodesDataList,
    required this.isLoading,
  });

  final List<Node> nodesDataList ;
  final bool isLoading;

  @override
  State<StatefulWidget> createState() => NodesWidgetState();
}

class NodesWidgetState extends State<NodesWidget>{
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        
      ],
    );
  }
  
}
