class Node{
  final String ip;
  final String heapPercent;
  final String ramPercent;
  final String cpu;
  final String load1m;
  final String load5m;
  final String load15m;
  final String nodeRole;
  final String master;
  final String name;

  const Node({
    required this.ip,
    required this.heapPercent,
    required this.ramPercent,
    required this.cpu,
    required this.load1m,
    required this.load5m,
    required this.load15m,
    required this.nodeRole,
    required this.master,
    required this.name
  });

  factory Node.fromJson(Map<String, dynamic> json){
    return Node(
      ip: json['ip'],
      heapPercent: json['heap.percent'],
      ramPercent: json['ram.percent'],
      cpu: json['cpu'],
      load1m: json['load_1m'],
      load5m: json['load_5m'],
      load15m: json['load_15m'],
      nodeRole: json['node.role'],
      master: json['master'],
      name: json['name'],
    );
  }
}
