import 'package:elastic_app/model/access_log.dart';
import 'package:flutter/material.dart';

class NotificationsWidget extends StatefulWidget{
  const NotificationsWidget({
    Key? key,
    required this.notificationsList,
    required this.isLoading,
  }): super(key:key);

  final List<AccessLog> notificationsList ;
  final bool isLoading;

  @override
  State<StatefulWidget> createState() => NotificationsWidgetState();
}

class NotificationsWidgetState extends State<NotificationsWidget>{
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: ScrollPhysics(),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Notifications",
          style: TextStyle(
            height: 2,
            fontSize: 24,
            fontWeight: FontWeight.bold
          )
        ),
        // Text('Count: ${widget.notificationsList.length}'),
        widget.notificationsList.isNotEmpty
        ? ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: widget.notificationsList.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: ListTile(
                leading: Text(widget.notificationsList[index].sourceTimestamp),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('method ${widget.notificationsList[index].sourceMethod}'),
                    Text('resp ${widget.notificationsList[index].sourceResponse}'),
                    Text('mod ${widget.notificationsList[index].sourceModuleName}'),

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
