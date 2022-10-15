import 'package:flutter/material.dart';
import 'package:elastic_app/model/node.dart';

class NodesWidget extends StatefulWidget{
  const NodesWidget({
    Key? key,
    required this.nodesList,
    required this.isLoading,
  }): super(key:key);

  final List<Node> nodesList ;
  final bool isLoading;

  @override
  State<StatefulWidget> createState() => NodesWidgetState();
}

class NodesWidgetState extends State<NodesWidget>{
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: ScrollPhysics(),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Nodes",
          style: TextStyle(
            height: 2,
            fontSize: 24,
            fontWeight: FontWeight.bold
          )
        ),
        Text('Nodes Count: ${widget.nodesList.length}'),
        widget.nodesList.isNotEmpty
        ? ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: widget.nodesList.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: ListTile(
                leading: Text(widget.nodesList[index].ip),
                trailing: Text(widget.nodesList[index].nodeRole),
                title: Text(widget.nodesList[index].name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Heap Percent ${widget.nodesList[index].heapPercent}'),
                    Text('RAM Pcercent ${widget.nodesList[index].ramPercent}'),
                    Text('CPU ${widget.nodesList[index].cpu}'),
                    Text('Load 1m ${widget.nodesList[index].load1m}'),
                    Text('master ${widget.nodesList[index].master}'),
                  ],
                )
              ),
            );
          },
        )
        : const Text('')
      ],
    )
    );
  }
  
}
