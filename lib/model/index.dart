class Index {
  final String health;
  final String status;
  final String name;
  final String uuid;
  final String pri;
  final String rep;
  final String docsCount;
  final String docsDeleted;
  final String storeSize;
  final String priStoreSize;

  Index({
    required this.health,
    required this.status,
    required this.name,
    required this.uuid,
    required this.pri,
    required this.rep,
    required this.docsCount,
    required this.docsDeleted,
    required this.storeSize,
    required this.priStoreSize,
  });

  factory Index.fromJson(Map<String, dynamic> json){
    return Index(
      health: json['health'],
      status: json['status'],
      name: json['name'],
      uuid: json['uuid'],
      pri: json['pri'],
      rep: json['rep'],
      docsCount: json['docs.count'],
      docsDeleted: json['docs.deleted'],
      storeSize: json['store.size'],
      priStoreSize: json['pri.store.size'],
    );
  }
}
