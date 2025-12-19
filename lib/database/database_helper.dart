import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseHelper {
  static const String _databaseName = 'life_planner.db';
  static const int _databaseVersion = 1;

  // Tabelas
  static const String todoTable = 'todos';
  static const String diaryTable = 'diary_entries';
  static const String goalTable = 'goals';
  static const String appointmentTable = 'appointments';
  static const String financialTable = 'financial_transactions';
  static const String scheduledTaskTable = 'scheduled_tasks';
  static const String dailyProgressTable = 'daily_progress';
  static const String recurringExpenseTable = 'recurring_expenses';

  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela de To-Do
    await db.execute('''
      CREATE TABLE $todoTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        dueDate TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    // Tabela de Diário
    await db.execute('''
      CREATE TABLE $diaryTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        date TEXT NOT NULL,
        tags TEXT
      )
    ''');

    // Tabela de Metas
    await db.execute('''
      CREATE TABLE $goalTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        targetDate TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        progress INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tabela de Compromissos
    await db.execute('''
      CREATE TABLE $appointmentTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        dateTime TEXT NOT NULL,
        duration INTEGER,
        hasNotification INTEGER NOT NULL DEFAULT 1,
        notificationMinutesBefore INTEGER NOT NULL DEFAULT 15
      )
    ''');

    // Tabela de Transações Financeiras
    await db.execute('''
      CREATE TABLE $financialTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        subcategory TEXT NOT NULL,
        date TEXT NOT NULL,
        notes TEXT
      )
    ''');

    // Tabela de Tarefas Agendadas
    await db.execute('''
      CREATE TABLE $scheduledTaskTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        startDate TEXT NOT NULL,
        endDate TEXT,
        isRecurring INTEGER NOT NULL DEFAULT 0,
        recurrencePattern TEXT,
        hasAlarm INTEGER NOT NULL DEFAULT 1,
        alarmTime TEXT
      )
    ''');

    // Tabela de Progresso Diário
    await db.execute('''
      CREATE TABLE $dailyProgressTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        tasksCompleted INTEGER NOT NULL DEFAULT 0,
        totalTasks INTEGER NOT NULL DEFAULT 0,
        goalsProgress INTEGER NOT NULL DEFAULT 0,
        financialBalance REAL NOT NULL DEFAULT 0,
        mood TEXT NOT NULL DEFAULT 'neutral'
      )
    ''');
  }

  // ===== TO-DO OPERATIONS =====
  Future<int> insertTodo(TodoTask task) async {
    final db = await database;
    return await db.insert(todoTable, task.toMap());
  }

  Future<List<TodoTask>> getTodos() async {
    final db = await database;
    final maps = await db.query(todoTable, orderBy: 'dueDate ASC');
    return List.generate(maps.length, (i) => TodoTask.fromMap(maps[i]));
  }

  Future<List<TodoTask>> getTodosByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final maps = await db.query(
      todoTable,
      where: 'dueDate >= ? AND dueDate < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'dueDate ASC',
    );
    return List.generate(maps.length, (i) => TodoTask.fromMap(maps[i]));
  }

  Future<int> updateTodo(TodoTask task) async {
    final db = await database;
    return await db.update(
      todoTable,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete(
      todoTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== DIARY OPERATIONS =====
  Future<int> insertDiaryEntry(DiaryEntry entry) async {
    final db = await database;
    return await db.insert(diaryTable, entry.toMap());
  }

  Future<List<DiaryEntry>> getDiaryEntries() async {
    final db = await database;
    final maps = await db.query(diaryTable, orderBy: 'date DESC');
    return List.generate(maps.length, (i) => DiaryEntry.fromMap(maps[i]));
  }

  Future<DiaryEntry?> getDiaryEntryByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final maps = await db.query(
      diaryTable,
      where: 'date >= ? AND date < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
    
    if (maps.isEmpty) return null;
    return DiaryEntry.fromMap(maps.first);
  }

  Future<int> updateDiaryEntry(DiaryEntry entry) async {
    final db = await database;
    return await db.update(
      diaryTable,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteDiaryEntry(int id) async {
    final db = await database;
    return await db.delete(
      diaryTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== GOAL OPERATIONS =====
  Future<int> insertGoal(Goal goal) async {
    final db = await database;
    return await db.insert(goalTable, goal.toMap());
  }

  Future<List<Goal>> getGoals() async {
    final db = await database;
    final maps = await db.query(goalTable, orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => Goal.fromMap(maps[i]));
  }

  Future<int> updateGoal(Goal goal) async {
    final db = await database;
    return await db.update(
      goalTable,
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await database;
    return await db.delete(
      goalTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== APPOINTMENT OPERATIONS =====
  Future<int> insertAppointment(Appointment appointment) async {
    final db = await database;
    return await db.insert(appointmentTable, appointment.toMap());
  }

  Future<List<Appointment>> getAppointments() async {
    final db = await database;
    final maps = await db.query(appointmentTable, orderBy: 'dateTime ASC');
    return List.generate(maps.length, (i) => Appointment.fromMap(maps[i]));
  }

  Future<List<Appointment>> getAppointmentsByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final maps = await db.query(
      appointmentTable,
      where: 'dateTime >= ? AND dateTime < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'dateTime ASC',
    );
    return List.generate(maps.length, (i) => Appointment.fromMap(maps[i]));
  }

  Future<int> updateAppointment(Appointment appointment) async {
    final db = await database;
    return await db.update(
      appointmentTable,
      appointment.toMap(),
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }

  Future<int> deleteAppointment(int id) async {
    final db = await database;
    return await db.delete(
      appointmentTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== FINANCIAL OPERATIONS =====
  Future<int> insertTransaction(FinancialTransaction transaction) async {
    final db = await database;
    return await db.insert(financialTable, transaction.toMap());
  }

  Future<List<FinancialTransaction>> getTransactions() async {
    final db = await database;
    final maps = await db.query(financialTable, orderBy: 'date DESC');
    return List.generate(maps.length, (i) => FinancialTransaction.fromMap(maps[i]));
  }

  Future<List<FinancialTransaction>> getTransactionsByMonth(int year, int month) async {
    final db = await database;
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 1);
    
    final maps = await db.query(
      financialTable,
      where: 'date >= ? AND date < ?',
      whereArgs: [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => FinancialTransaction.fromMap(maps[i]));
  }

  Future<int> updateTransaction(FinancialTransaction transaction) async {
    final db = await database;
    return await db.update(
      financialTable,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      financialTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== SCHEDULED TASK OPERATIONS =====
  Future<int> insertScheduledTask(ScheduledTask task) async {
    final db = await database;
    return await db.insert(scheduledTaskTable, task.toMap());
  }

  Future<List<ScheduledTask>> getScheduledTasks() async {
    final db = await database;
    final maps = await db.query(scheduledTaskTable, orderBy: 'startDate ASC');
    return List.generate(maps.length, (i) => ScheduledTask.fromMap(maps[i]));
  }

  Future<int> updateScheduledTask(ScheduledTask task) async {
    final db = await database;
    return await db.update(
      scheduledTaskTable,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteScheduledTask(int id) async {
    final db = await database;
    return await db.delete(
      scheduledTaskTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== DAILY PROGRESS OPERATIONS =====
  Future<int> insertDailyProgress(DailyProgress progress) async {
    final db = await database;
    return await db.insert(dailyProgressTable, progress.toMap());
  }

  Future<DailyProgress?> getDailyProgress(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    
    final maps = await db.query(
      dailyProgressTable,
      where: 'date = ?',
      whereArgs: [startOfDay.toIso8601String()],
    );
    
    if (maps.isEmpty) return null;
    return DailyProgress.fromMap(maps.first);
  }

  Future<List<DailyProgress>> getDailyProgressRange(DateTime start, DateTime end) async {
    final db = await database;
    final maps = await db.query(
      dailyProgressTable,
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => DailyProgress.fromMap(maps[i]));
  }

  Future<int> updateDailyProgress(DailyProgress progress) async {
    final db = await database;
    return await db.update(
      dailyProgressTable,
      progress.toMap(),
      where: 'date = ?',
      whereArgs: [DateTime(progress.date.year, progress.date.month, progress.date.day).toIso8601String()],
    );
  }

  // ===== RECURRING EXPENSE OPERATIONS =====
  Future<int> insertRecurringExpense(RecurringExpense expense) async {
    final db = await database;
    return await db.insert(recurringExpenseTable, expense.toMap());
  }

  Future<List<RecurringExpense>> getRecurringExpenses() async {
    final db = await database;
    final maps = await db.query(recurringExpenseTable, orderBy: 'dayOfMonth ASC');
    return List.generate(maps.length, (i) => RecurringExpense.fromMap(maps[i]));
  }

  Future<List<RecurringExpense>> getUnpaidRecurringExpenses() async {
    final db = await database;
    final maps = await db.query(
      recurringExpenseTable,
      where: 'isPaid = ?',
      whereArgs: [0],
      orderBy: 'dayOfMonth ASC',
    );
    return List.generate(maps.length, (i) => RecurringExpense.fromMap(maps[i]));
  }

  Future<int> updateRecurringExpense(RecurringExpense expense) async {
    final db = await database;
    return await db.update(
      recurringExpenseTable,
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteRecurringExpense(int id) async {
    final db = await database;
    return await db.delete(
      recurringExpenseTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
