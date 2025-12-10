import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../database/database_helper.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  late Future<List<DailyProgress>> _progressData;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  void _loadProgressData() {
    final startDate = DateTime.now().subtract(const Duration(days: 30));
    final endDate = DateTime.now();
    setState(() {
      _progressData = _db.getDailyProgressRange(startDate, endDate);
    });
  }

  void _recordProgress() {
    showDialog(
      context: context,
      builder: (context) => _ProgressDialog(
        onSave: (tasksCompleted, totalTasks, goalsProgress, mood) async {
          final progress = DailyProgress(
            date: _selectedDate,
            tasksCompleted: tasksCompleted,
            totalTasks: totalTasks,
            goalsProgress: goalsProgress,
            mood: mood,
          );
          
          final existing = await _db.getDailyProgress(_selectedDate);
          if (existing != null) {
            await _db.updateDailyProgress(progress);
          } else {
            await _db.insertDailyProgress(progress);
          }
          
          _loadProgressData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acompanhamento Diário'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<DailyProgress>>(
        future: _progressData,
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
                    Icons.analytics,
                    size: 64,
                    color: AppTheme.primaryPastel.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum registro',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Registre seu progresso diário',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _recordProgress,
                    child: const Text('Registrar Progresso'),
                  ),
                ],
              ),
            );
          }

          final progressList = snapshot.data!;
          
          // Calcular estatísticas
          double avgTasksCompletion = 0;
          double avgGoalsProgress = 0;
          int happyDays = 0;
          int neutralDays = 0;
          int sadDays = 0;

          for (var progress in progressList) {
            if (progress.totalTasks > 0) {
              avgTasksCompletion +=
                  (progress.tasksCompleted / progress.totalTasks) * 100;
            }
            avgGoalsProgress += progress.goalsProgress;
            
            switch (progress.mood) {
              case 'happy':
                happyDays++;
                break;
              case 'neutral':
                neutralDays++;
                break;
              case 'sad':
                sadDays++;
                break;
            }
          }

          avgTasksCompletion /= progressList.length;
          avgGoalsProgress /= progressList.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estatísticas Gerais
                Text(
                  'Últimos 30 Dias',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                
                // Card de Conclusão de Tarefas
                Card(
                  color: AppTheme.successPastel.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conclusão de Tarefas',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${avgTasksCompletion.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppTheme.successPastel,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: avgTasksCompletion / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.successPastel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Card de Progresso de Metas
                Card(
                  color: AppTheme.accentPastel.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progresso de Metas',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${avgGoalsProgress.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppTheme.accentPastel,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: avgGoalsProgress / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.accentPastel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Card de Humor
                Card(
                  color: AppTheme.secondaryPastel.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Humor',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '😊',
                                  style: Theme.of(context).textTheme.displayMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$happyDays dias',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '😐',
                                  style: Theme.of(context).textTheme.displayMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$neutralDays dias',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '😢',
                                  style: Theme.of(context).textTheme.displayMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$sadDays dias',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Histórico
                Text(
                  'Histórico',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                
                ...progressList.map((progress) {
                  final percentage = progress.totalTasks > 0
                      ? (progress.tasksCompleted / progress.totalTasks * 100)
                          .toStringAsFixed(0)
                      : '0';
                  
                  String moodEmoji = '😐';
                  if (progress.mood == 'happy') moodEmoji = '😊';
                  if (progress.mood == 'sad') moodEmoji = '😢';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${progress.date.day}/${progress.date.month}/${progress.date.year}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tarefas: $percentage% | Metas: ${progress.goalsProgress}%',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          Text(
                            moodEmoji,
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _recordProgress,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ProgressDialog extends StatefulWidget {
  final Function(int, int, int, String) onSave;

  const _ProgressDialog({required this.onSave});

  @override
  State<_ProgressDialog> createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<_ProgressDialog> {
  int _tasksCompleted = 0;
  int _totalTasks = 0;
  int _goalsProgress = 50;
  String _mood = 'neutral';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar Progresso'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tarefas
            Text(
              'Tarefas Concluídas: $_tasksCompleted/$_totalTasks',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _tasksCompleted.toDouble(),
                    min: 0,
                    max: _totalTasks.toDouble() == 0 ? 10 : _totalTasks.toDouble(),
                    onChanged: (value) {
                      setState(() => _tasksCompleted = value.toInt());
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() => _tasksCompleted = int.tryParse(value) ?? 0);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Total: '),
                Expanded(
                  child: Slider(
                    value: _totalTasks.toDouble(),
                    min: 0,
                    max: 20,
                    onChanged: (value) {
                      setState(() => _totalTasks = value.toInt());
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() => _totalTasks = int.tryParse(value) ?? 0);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Metas
            Text(
              'Progresso de Metas: $_goalsProgress%',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Slider(
              value: _goalsProgress.toDouble(),
              min: 0,
              max: 100,
              onChanged: (value) {
                setState(() => _goalsProgress = value.toInt());
              },
            ),
            const SizedBox(height: 16),

            // Humor
            Text(
              'Como você se sente?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _mood = 'happy'),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _mood == 'happy'
                            ? AppTheme.successPastel
                            : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('😊', style: TextStyle(fontSize: 32)),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _mood = 'neutral'),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _mood == 'neutral'
                            ? AppTheme.primaryPastel
                            : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('😐', style: TextStyle(fontSize: 32)),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _mood = 'sad'),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _mood == 'sad'
                            ? AppTheme.errorPastel
                            : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('😢', style: TextStyle(fontSize: 32)),
                  ),
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
            widget.onSave(_tasksCompleted, _totalTasks, _goalsProgress, _mood);
            Navigator.pop(context);
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
