class TaskItem {
  final int? id;
  final String title;
  final String description;
  final DateTime startAt;
  final DateTime endAt;
  final bool completed;

  const TaskItem({
    this.id,
    required this.title,
    this.description = '',
    required this.startAt,
    required this.endAt,
    this.completed = false,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'start_at': startAt.millisecondsSinceEpoch,
    'end_at': endAt.millisecondsSinceEpoch,
    'completed': completed ? 1 : 0,
  };

  factory TaskItem.fromMap(Map<String, Object?> map) => TaskItem(
    id: map['id'] as int?,
    title: map['title'] as String,
    description: (map['description'] as String?) ?? '',
    startAt: DateTime.fromMillisecondsSinceEpoch(map['start_at'] as int),
    endAt: DateTime.fromMillisecondsSinceEpoch(map['end_at'] as int),
    completed: (map['completed'] as int? ?? 0) == 1,
  );

  TaskItem copyWith({int? id, bool? completed}) => TaskItem(
    id: id ?? this.id,
    title: title,
    description: description,
    startAt: startAt,
    endAt: endAt,
    completed: completed ?? this.completed,
  );
}
