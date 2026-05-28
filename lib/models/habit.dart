class Habit {
  final int? id;
  final String name;
  final String icon; // emoji
  final int targetCount; // daily target
  final String createdAt;

  const Habit({
    this.id,
    required this.name,
    this.icon = '✅',
    this.targetCount = 1,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'icon': icon,
        'target_count': targetCount,
        'created_at': createdAt,
      };

  factory Habit.fromMap(Map<String, dynamic> map) => Habit(
        id: map['id'] as int?,
        name: map['name'] as String,
        icon: map['icon'] as String? ?? '✅',
        targetCount: map['target_count'] as int? ?? 1,
        createdAt: map['created_at'] as String,
      );

  Habit copyWith({
    int? id,
    String? name,
    String? icon,
    int? targetCount,
    String? createdAt,
  }) =>
      Habit(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        targetCount: targetCount ?? this.targetCount,
        createdAt: createdAt ?? this.createdAt,
      );
}

class HabitDate {
  final int? id;
  final int habitId;
  final String date;
  final int count;

  const HabitDate({
    this.id,
    required this.habitId,
    required this.date,
    this.count = 0,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'habit_id': habitId,
        'date': date,
        'count': count,
      };

  factory HabitDate.fromMap(Map<String, dynamic> map) => HabitDate(
        id: map['id'] as int?,
        habitId: map['habit_id'] as int,
        date: map['date'] as String,
        count: map['count'] as int? ?? 0,
      );
}
