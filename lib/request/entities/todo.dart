class Todo {
  String? id;
  String? userId;
  String? typeId;
  String? name;
  String? createdAt;
  String? done;

  Todo({
    this.id,
    this.userId,
    this.typeId,
    this.name,
    this.createdAt,
    this.done,
  });

  factory Todo.fromJson(Map json) {
    return Todo(
        id: json['id'],
        userId: json['user_id'],
        typeId: json['type_id'],
        name: json['name'],
        createdAt: json['created_at'],
        done: json['done']);
  }

  factory Todo.addFromJson(Map json) {
    return Todo(
        typeId: json['type_id'].toString(),
        name: json['name'].toString()
    );
  }

  Map toJson() {
    return {
      'id': id,
      'type_id': typeId,
      'name': name,
      'done': done,
    };
  }
}
