class TodoType {
  String? id;
  String? name;

  TodoType({
    this.id,
    this.name,
  });

  factory TodoType.fromJson(Map json) {
    return TodoType(id: json['id'], name: json['name']);
  }

  factory TodoType.addFromJson(Map json) {
    return TodoType(name: json['name'].toString());
  }

  Map toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
