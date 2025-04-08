
class TodoModel {
  int id;
  String title;
  String desc;
  bool isDone;

  TodoModel({
    required this.id,
    required this.title,
    required this.desc,
    this.isDone = false,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
    id: json['id'],
    title: json['title'],
    desc: json['desc'],
    isDone: json['isDone'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'desc': desc,
    'isDone': isDone,
  };
}
