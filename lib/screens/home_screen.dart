import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../database/database_helper.dart';
import 'todo_screen.dart';
import 'diary_screen.dart';
import 'goals_screen.dart';
import 'appointments_screen.dart';
import 'financial_screen.dart';
import 'scheduled_tasks_screen.dart';
import 'progress_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  late Future<List<TodoTask>> _todayTodos;
  late Future<int> _completedTodosCount;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _todayTodos = _db.getTodosByDate(DateTime.now());
    _completedTodosCount = _db.getTodosByDate(DateTime.now()).then(
      (todos) => todos.where((t) => t.isCompleted).length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Life Planner'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saudação
            Text(
              'Bem-vindo!',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Organize sua vida e rotina',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Card de Tarefas de Hoje
            _buildTodayTasksCard(context),
            const SizedBox(height: 16),

            // Seção de Funcionalidades Principais
            Text(
              'Funcionalidades',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            // Grid de funcionalidades
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildFeatureCard(
                  context,
                  icon: Icons.check_circle,
                  title: 'To-Do',
                  subtitle: 'Tarefas diárias',
                  color: AppTheme.primaryPastel,
                  onTap: () => _navigateTo(context, const TodoScreen()),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.book,
                  title: 'Diário',
                  subtitle: 'Anotações',
                  color: AppTheme.secondaryPastel,
                  onTap: () => _navigateTo(context, const DiaryScreen()),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.flag,
                  title: 'Metas',
                  subtitle: 'Objetivos',
                  color: AppTheme.accentPastel,
                  onTap: () => _navigateTo(context, const GoalsScreen()),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.calendar_today,
                  title: 'Compromissos',
                  subtitle: 'Agendamentos',
                  color: AppTheme.successPastel,
                  onTap: () => _navigateTo(context, const AppointmentsScreen()),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.trending_up,
                  title: 'Financeiro',
                  subtitle: 'Controle',
                  color: AppTheme.warningPastel,
                  onTap: () => _navigateTo(context, const FinancialScreen()),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.schedule,
                  title: 'Tarefas',
                  subtitle: 'Agendadas',
                  color: AppTheme.errorPastel,
                  onTap: () => _navigateTo(context, const ScheduledTasksScreen()),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Botão de Acompanhamento
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateTo(context, const ProgressScreen()),
                icon: const Icon(Icons.analytics),
                label: const Text('Ver Acompanhamento Diário'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPastel,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayTasksCard(BuildContext context) {
    return Card(
      color: AppTheme.accentPastel.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tarefas de Hoje',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<TodoTask>>(
              future: _todayTodos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text(
                    'Nenhuma tarefa para hoje',
                    style: Theme.of(context).textTheme.bodyMedium,
                  );
                }

                final todos = snapshot.data!;
                final completed = todos.where((t) => t.isCompleted).length;
                final percentage = (completed / todos.length * 100).toStringAsFixed(0);

                return Column(
                  children: [
                    LinearProgressIndicator(
                      value: completed / todos.length,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.successPastel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$completed de ${todos.length} tarefas completas ($percentage%)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
