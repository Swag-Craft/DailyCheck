class Task {
  final int? id;
  final String title;
  final bool isDone;
  final String date; // YYYY-MM-DD
  final int sortOrder;

  const Task({
    this.id,
    required this.title,
    this.isDone = false,
    required this.date,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'is_done': isDone ? 1 : 0,
        'date': date,
        'sort_order': sortOrder,
      };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        id: map['id'] as int?,
        title: map['title'] as String,
        isDone: (map['is_done'] as int) == 1,
        date: map['date'] as String,
        sortOrder: map['sort_order'] as int? ?? 0,
      );

  Task copyWith({
    int? id,
    String? title,
    bool? isDone,
    String? date,
    int? sortOrder,
  }) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        isDone: isDone ?? this.isDone,
        date: date ?? this.date,
        sortOrder: sortOrder ?? this.sortOrder,
      );
}
