import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../database/database_helper.dart';

class RecurringExpensesScreen extends StatefulWidget {
  const RecurringExpensesScreen({Key? key}) : super(key: key);

  @override
  State<RecurringExpensesScreen> createState() => _RecurringExpensesScreenState();
}

class _RecurringExpensesScreenState extends State<RecurringExpensesScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  late Future<List<RecurringExpense>> _expenses;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() {
    setState(() {
      _expenses = _db.getRecurringExpenses();
    });
  }

  void _addExpense() {
    showDialog(
      context: context,
      builder: (context) => _RecurringExpenseDialog(
        onSave: (name, amount, dayOfMonth, description) async {
          final expense = RecurringExpense(
            name: name,
            amount: amount,
            dayOfMonth: dayOfMonth,
            description: description,
            createdAt: DateTime.now(),
          );
          await _db.insertRecurringExpense(expense);
          _loadExpenses();
        },
      ),
    );
  }

  void _markAsPaid(RecurringExpense expense) async {
    final updatedExpense = expense.copyWith(
      isPaid: true,
      paidDate: DateTime.now(),
    );
    await _db.updateRecurringExpense(updatedExpense);
    _loadExpenses();
  }

  void _resetMonthly() async {
    final expenses = await _db.getRecurringExpenses();
    for (var expense in expenses) {
      final resetExpense = expense.copyWith(isPaid: false, paidDate: null);
      await _db.updateRecurringExpense(resetExpense);
    }
    _loadExpenses();
  }

  void _deleteExpense(int id) async {
    await _db.deleteRecurringExpense(id);
    _loadExpenses();
  }

  void _editExpense(RecurringExpense expense) {
    showDialog(
      context: context,
      builder: (context) => _RecurringExpenseDialog(
        initialExpense: expense,
        onSave: (name, amount, dayOfMonth, description) async {
          final updatedExpense = expense.copyWith(
            name: name,
            amount: amount,
            dayOfMonth: dayOfMonth,
            description: description,
          );
          await _db.updateRecurringExpense(updatedExpense);
          _loadExpenses();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos Fixos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetMonthly,
            tooltip: 'Resetar para novo mês',
          ),
        ],
      ),
      body: FutureBuilder<List<RecurringExpense>>(
        future: _expenses,
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
                    Icons.receipt_long,
                    size: 64,
                    color: AppTheme.errorPastel.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum gasto fixo cadastrado',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione seus gastos recorrentes mensais',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final expenses = snapshot.data!;
          final totalAmount = expenses.fold<double>(
            0,
            (sum, expense) => sum + expense.amount,
          );
          final paidAmount = expenses
              .where((e) => e.isPaid)
              .fold<double>(0, (sum, expense) => sum + expense.amount);

          return SingleChildScrollView(
            child: Column(
              children: [
                // Resumo
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    color: AppTheme.primaryPastel.withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Mensal',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    'R\$ ${totalAmount.toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Já Pago',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    'R\$ ${paidAmount.toStringAsFixed(2)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(color: AppTheme.successPastel),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: totalAmount > 0 ? paidAmount / totalAmount : 0,
                              minHeight: 8,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.successPastel,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Lista de gastos
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: expense.isPaid,
                            onChanged: (value) {
                              if (value == true) {
                                _markAsPaid(expense);
                              }
                            },
                          ),
                          title: Text(
                            expense.name,
                            style: TextStyle(
                              decoration: expense.isPaid
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dia ${expense.dayOfMonth}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (expense.description.isNotEmpty)
                                Text(
                                  expense.description,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              if (expense.isPaid && expense.paidDate != null)
                                Text(
                                  'Pago em ${expense.paidDate!.day}/${expense.paidDate!.month}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppTheme.successPastel),
                                ),
                            ],
                          ),
                          trailing: SizedBox(
                            width: 120,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'R\$ ${expense.amount.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: const Text('Editar'),
                                      onTap: () => _editExpense(expense),
                                    ),
                                    PopupMenuItem(
                                      child: const Text('Deletar'),
                                      onTap: () => _deleteExpense(expense.id!),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        tooltip: 'Adicionar gasto fixo',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _RecurringExpenseDialog extends StatefulWidget {
  final Function(String, double, int, String) onSave;
  final RecurringExpense? initialExpense;

  const _RecurringExpenseDialog({
    required this.onSave,
    this.initialExpense,
  });

  @override
  State<_RecurringExpenseDialog> createState() =>
      _RecurringExpenseDialogState();
}

class _RecurringExpenseDialogState extends State<_RecurringExpenseDialog> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late int _dayOfMonth;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialExpense?.name ?? '');
    _amountController = TextEditingController(
      text: widget.initialExpense?.amount.toString() ?? '',
    );
    _descriptionController =
        TextEditingController(text: widget.initialExpense?.description ?? '');
    _dayOfMonth = widget.initialExpense?.dayOfMonth ?? DateTime.now().day;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialExpense == null
          ? 'Adicionar Gasto Fixo'
          : 'Editar Gasto Fixo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Gasto',
                hintText: 'Ex: Conta de Luz',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Valor (R\$)',
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _dayOfMonth,
              decoration: const InputDecoration(
                labelText: 'Dia do Mês',
              ),
              items: List.generate(31, (index) => index + 1)
                  .map((day) => DropdownMenuItem(
                        value: day,
                        child: Text('Dia $day'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _dayOfMonth = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                hintText: 'Detalhes adicionais',
              ),
              maxLines: 2,
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
            if (_nameController.text.isEmpty ||
                _amountController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Preencha todos os campos obrigatórios'),
                ),
              );
              return;
            }

            widget.onSave(
              _nameController.text,
              double.parse(_amountController.text),
              _dayOfMonth,
              _descriptionController.text,
            );

            Navigator.pop(context);
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
