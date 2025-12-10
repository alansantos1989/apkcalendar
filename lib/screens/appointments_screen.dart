import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();
  late Future<List<Appointment>> _appointments;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() {
    setState(() {
      _appointments = _db.getAppointments();
    });
  }

  void _addAppointment() {
    showDialog(
      context: context,
      builder: (context) => _AppointmentDialog(
        onSave: (title, description, dateTime, notificationMinutes) async {
          final appointment = Appointment(
            title: title,
            description: description,
            dateTime: dateTime,
            hasNotification: true,
            notificationMinutesBefore: notificationMinutes,
          );
          await _db.insertAppointment(appointment);
          
          // Agendar notificação
          await _notificationService.scheduleAppointmentReminder(
            id: appointment.id ?? DateTime.now().millisecondsSinceEpoch.toInt(),
            title: title,
            appointmentTime: dateTime,
            minutesBefore: notificationMinutes,
          );
          
          _loadAppointments();
        },
      ),
    );
  }

  void _deleteAppointment(int id) async {
    await _db.deleteAppointment(id);
    _loadAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compromissos'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Appointment>>(
        future: _appointments,
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
                    Icons.calendar_today,
                    size: 64,
                    color: AppTheme.successPastel.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum compromisso',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agende seus compromissos aqui',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final appointments = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              final dateTime = appointment.dateTime;
              final formattedDate =
                  '${dateTime.day}/${dateTime.month}/${dateTime.year}';
              final formattedTime =
                  '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              appointment.title,
                              style: Theme.of(context).textTheme.titleLarge,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _deleteAppointment(appointment.id!),
                          ),
                        ],
                      ),
                      if (appointment.description != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            appointment.description!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppTheme.textLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$formattedDate às $formattedTime',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      if (appointment.hasNotification)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.notifications,
                                size: 16,
                                color: AppTheme.warningPastel,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Lembrete: ${appointment.notificationMinutesBefore} min antes',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAppointment,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AppointmentDialog extends StatefulWidget {
  final Function(String, String?, DateTime, int) onSave;

  const _AppointmentDialog({required this.onSave});

  @override
  State<_AppointmentDialog> createState() => _AppointmentDialogState();
}

class _AppointmentDialogState extends State<_AppointmentDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _selectedDateTime;
  int _notificationMinutes = 15;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo Compromisso'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Digite o título do compromisso',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                hintText: 'Digite a descrição',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Data e Hora: ${_selectedDateTime.toLocal().toString().substring(0, 16)}',
                  ),
                ),
                ElevatedButton(
                  onPressed: _selectDateTime,
                  child: const Text('Selecionar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Lembrete (minutos antes):'),
                DropdownButton<int>(
                  value: _notificationMinutes,
                  items: [5, 10, 15, 30, 60]
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text('$m min'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _notificationMinutes = value);
                    }
                  },
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
                _selectedDateTime,
                _notificationMinutes,
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
