class TaskItem {
  const TaskItem({
    this.id,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    this.isCompleted = false,
  });

  final int? id;
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final bool isCompleted;

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'start_ms': start.millisecondsSinceEpoch,
        'end_ms': end.millisecondsSinceEpoch,
        'is_completed': isCompleted ? 1 : 0,
      };

  factory TaskItem.fromMap(Map<String, Object?> map) => TaskItem(
        id: map['id'] as int?,
        title: map['title'] as String,
        description: (map['description'] as String?) ?? '',
        start: DateTime.fromMillisecondsSinceEpoch(map['start_ms'] as int),
        end: DateTime.fromMillisecondsSinceEpoch(map['end_ms'] as int),
        isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      );

  TaskItem copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? start,
    DateTime? end,
    bool? isCompleted,
  }) =>
      TaskItem(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        start: start ?? this.start,
        end: end ?? this.end,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}
