// Modelo para To-Do
class TodoTask {
  final int? id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime createdAt;

  TodoTask({
    this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.isCompleted = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TodoTask.fromMap(Map<String, dynamic> map) {
    return TodoTask(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      isCompleted: map['isCompleted'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  TodoTask copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TodoTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Modelo para Diário
class DiaryEntry {
  final int? id;
  final String title;
  final String content;
  final DateTime date;
  final List<String>? tags;

  DiaryEntry({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'tags': tags?.join(',') ?? '',
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      date: DateTime.parse(map['date']),
      tags: (map['tags'] as String?)?.split(',').where((t) => t.isNotEmpty).toList(),
    );
  }
}

// Modelo para Meta
class Goal {
  final int? id;
  final String title;
  final String? description;
  final String category; // leitura, exercício, aprendizado, etc.
  final DateTime createdAt;
  final DateTime? targetDate;
  final bool isCompleted;
  final int progress; // 0-100

  Goal({
    this.id,
    required this.title,
    this.description,
    required this.category,
    required this.createdAt,
    this.targetDate,
    this.isCompleted = false,
    this.progress = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'progress': progress,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      createdAt: DateTime.parse(map['createdAt']),
      targetDate: map['targetDate'] != null ? DateTime.parse(map['targetDate']) : null,
      isCompleted: map['isCompleted'] == 1,
      progress: map['progress'] ?? 0,
    );
  }
}

// Modelo para Compromisso
class Appointment {
  final int? id;
  final String title;
  final String? description;
  final DateTime dateTime;
  final Duration? duration;
  final bool hasNotification;
  final int notificationMinutesBefore;

  Appointment({
    this.id,
    required this.title,
    this.description,
    required this.dateTime,
    this.duration,
    this.hasNotification = true,
    this.notificationMinutesBefore = 15,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'duration': duration?.inMinutes,
      'hasNotification': hasNotification ? 1 : 0,
      'notificationMinutesBefore': notificationMinutesBefore,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dateTime: DateTime.parse(map['dateTime']),
      duration: map['duration'] != null ? Duration(minutes: map['duration']) : null,
      hasNotification: map['hasNotification'] == 1,
      notificationMinutesBefore: map['notificationMinutesBefore'] ?? 15,
    );
  }
}

// Modelo para Transação Financeira
class FinancialTransaction {
  final int? id;
  final String description;
  final double amount;
  final String category; // renda, despesa
  final String subcategory; // alimentação, transporte, etc.
  final DateTime date;
  final String? notes;

  FinancialTransaction({
    this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.subcategory,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category,
      'subcategory': subcategory,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory FinancialTransaction.fromMap(Map<String, dynamic> map) {
    return FinancialTransaction(
      id: map['id'],
      description: map['description'],
      amount: map['amount'],
      category: map['category'],
      subcategory: map['subcategory'],
      date: DateTime.parse(map['date']),
      notes: map['notes'],
    );
  }
}

// Modelo para Tarefa Agendada
class ScheduledTask {
  final int? id;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isRecurring;
  final String? recurrencePattern; // daily, weekly, monthly
  final bool hasAlarm;
  final TimeOfDay? alarmTime;

  ScheduledTask({
    this.id,
    required this.title,
    this.description,
    required this.startDate,
    this.endDate,
    this.isRecurring = false,
    this.recurrencePattern,
    this.hasAlarm = true,
    this.alarmTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isRecurring': isRecurring ? 1 : 0,
      'recurrencePattern': recurrencePattern,
      'hasAlarm': hasAlarm ? 1 : 0,
      'alarmTime': alarmTime != null ? '${alarmTime!.hour}:${alarmTime!.minute}' : null,
    };
  }

  factory ScheduledTask.fromMap(Map<String, dynamic> map) {
    TimeOfDay? alarmTime;
    if (map['alarmTime'] != null) {
      final parts = (map['alarmTime'] as String).split(':');
      alarmTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    
    return ScheduledTask(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      isRecurring: map['isRecurring'] == 1,
      recurrencePattern: map['recurrencePattern'],
      hasAlarm: map['hasAlarm'] == 1,
      alarmTime: alarmTime,
    );
  }
}

// Modelo para Acompanhamento Diário
class DailyProgress {
  final int? id;
  final DateTime date;
  final int tasksCompleted;
  final int totalTasks;
  final int goalsProgress;
  final double financialBalance;
  final String mood; // happy, neutral, sad

  DailyProgress({
    this.id,
    required this.date,
    this.tasksCompleted = 0,
    this.totalTasks = 0,
    this.goalsProgress = 0,
    this.financialBalance = 0,
    this.mood = 'neutral',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'tasksCompleted': tasksCompleted,
      'totalTasks': totalTasks,
      'goalsProgress': goalsProgress,
      'financialBalance': financialBalance,
      'mood': mood,
    };
  }

  factory DailyProgress.fromMap(Map<String, dynamic> map) {
    return DailyProgress(
      id: map['id'],
      date: DateTime.parse(map['date']),
      tasksCompleted: map['tasksCompleted'] ?? 0,
      totalTasks: map['totalTasks'] ?? 0,
      goalsProgress: map['goalsProgress'] ?? 0,
      financialBalance: map['financialBalance'] ?? 0,
      mood: map['mood'] ?? 'neutral',
    );
  }
}
