import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';

class ScheduledTasksScreen extends StatefulWidget {
  const ScheduledTasksScreen({Key? key}) : super(key: key);

  @override
  State<ScheduledTasksScreen> createState() => _ScheduledTasksScreenState();
}

class _ScheduledTasksScreenState extends State<ScheduledTasksScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();
  late Future<List<ScheduledTask>> _tasks;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      _tasks = _db.getScheduledTasks();
    });
  }

  void _addTask() {
    showDialog(
      context: context,
      builder: (context) => _ScheduledTaskDialog(
        onSave: (title, description, startDate, endDate, isRecurring,
            recurrencePattern, hasAlarm, alarmTime) async {
          final task = ScheduledTask(
            title: title,
            description: description,
            startDate: startDate,
            endDate: endDate,
            isRecurring: isRecurring,
            recurrencePattern: recurrencePattern,
            hasAlarm: hasAlarm,
            alarmTime: alarmTime,
          );
          await _db.insertScheduledTask(task);

          if (hasAlarm && alarmTime != null) {
            final alarmDateTime = DateTime(
              startDate.year,
              startDate.month,
              startDate.day,
              alarmTime.hour,
              alarmTime.minute,
            );
            await _notificationService.scheduleTaskReminder(
              id: task.id ?? DateTime.now().millisecondsSinceEpoch.toInt(),
              title: title,
              taskTime: alarmDateTime,
            );
          }

          _loadTasks();
        },
      ),
    );
  }

  void _deleteTask(int id) async {
    await _db.deleteScheduledTask(id);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas Agendadas'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ScheduledTask>>(
        future: _tasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 64,
                    color: AppTheme.errorPastel.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma tarefa agendada',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agende suas tarefas com lembretes',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final tasks = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                // Calendário
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: TableCalendar(
                      focusedDay: _selectedDate,
                      firstDay: DateTime(2020),
                      lastDay: DateTime(2030),
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDate, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDate = selectedDay;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        selectedDecoration: BoxDecoration(
                          color: AppTheme.primaryPastel,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: AppTheme.accentPastel,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                    ),
                  ),
                ),
                // Lista de tarefas
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: List.generate(
                      tasks.length,
                      (index) {
                        final task = tasks[index];
                        final isToday = isSameDay(task.startDate, _selectedDate);
                        final isUpcoming =
                            task.startDate.isAfter(_selectedDate) &&
                                task.startDate
                                    .isBefore(_selectedDate.add(const Duration(days: 7)));

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: isToday
                              ? AppTheme.warningPastel.withOpacity(0.2)
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        task.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () =>
                                          _deleteTask(task.id!),
                                    ),
                                  ],
                                ),
                                if (task.description != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      task.description!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: AppTheme.textLight,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${task.startDate.day}/${task.startDate.month}/${task.startDate.year}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                    if (task.isRecurring)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8),
                                        child: Chip(
                                          label: Text(
                                            task.recurrencePattern ?? 'Repetindo',
                                          ),
                                          labelStyle: const TextStyle(
                                            fontSize: 10,
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ),
                                  ],
                                ),
                                if (task.hasAlarm && task.alarmTime != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.alarm,
                                          size: 16,
                                          color: AppTheme.warningPastel,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${task.alarmTime!.hour.toString().padLeft(2, '0')}:${task.alarmTime!.minute.toString().padLeft(2, '0')}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ScheduledTaskDialog extends StatefulWidget {
  final Function(String, String?, DateTime, DateTime?, bool, String?, bool,
      TimeOfDay?) onSave;

  const _ScheduledTaskDialog({required this.onSave});

  @override
  State<_ScheduledTaskDialog> createState() => _ScheduledTaskDialogState();
}

class _ScheduledTaskDialogState extends State<_ScheduledTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _selectedStartDate;
  DateTime? _selectedEndDate;
  bool _isRecurring = false;
  String _recurrencePattern = 'daily';
  bool _hasAlarm = true;
  TimeOfDay? _alarmTime;

  @override
  void initState() {
    super.initState();
    _selectedStartDate = DateTime.now();
    _alarmTime = const TimeOfDay(hour: 9, minute: 0);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedStartDate = picked);
    }
  }

  void _selectAlarmTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _alarmTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() => _alarmTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Tarefa Agendada'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Digite o título da tarefa',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                hintText: 'Digite a descrição',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Data: ${_selectedStartDate.day}/${_selectedStartDate.month}/${_selectedStartDate.year}',
                  ),
                ),
                ElevatedButton(
                  onPressed: _selectStartDate,
                  child: const Text('Selecionar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Tarefa Recorrente'),
              value: _isRecurring,
              onChanged: (value) {
                setState(() => _isRecurring = value ?? false);
              },
            ),
            if (_isRecurring)
              DropdownButton<String>(
                value: _recurrencePattern,
                isExpanded: true,
                items: ['daily', 'weekly', 'monthly']
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(p == 'daily'
                              ? 'Diariamente'
                              : p == 'weekly'
                                  ? 'Semanalmente'
                                  : 'Mensalmente'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _recurrencePattern = value);
                  }
                },
              ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Adicionar Alarme'),
              value: _hasAlarm,
              onChanged: (value) {
                setState(() => _hasAlarm = value ?? false);
              },
            ),
            if (_hasAlarm)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Hora: ${_alarmTime?.hour.toString().padLeft(2, '0')}:${_alarmTime?.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _selectAlarmTime,
                    child: const Text('Selecionar'),
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              widget.onSave(
                _titleController.text,
                _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
                _selectedStartDate,
                _selectedEndDate,
                _isRecurring,
                _isRecurring ? _recurrencePattern : null,
                _hasAlarm,
                _hasAlarm ? _alarmTime : null,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
