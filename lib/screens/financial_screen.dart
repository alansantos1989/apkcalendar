import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../database/database_helper.dart';

class FinancialScreen extends StatefulWidget {
  const FinancialScreen({Key? key}) : super(key: key);

  @override
  State<FinancialScreen> createState() => _FinancialScreenState();
}

class _FinancialScreenState extends State<FinancialScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  late Future<List<FinancialTransaction>> _transactions;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    setState(() {
      _transactions = _db.getTransactionsByMonth(
        _selectedMonth.year,
        _selectedMonth.month,
      );
    });
  }

  void _addTransaction() {
    showDialog(
      context: context,
      builder: (context) => _TransactionDialog(
        onSave: (description, amount, category, subcategory, notes) async {
          final transaction = FinancialTransaction(
            description: description,
            amount: amount,
            category: category,
            subcategory: subcategory,
            date: DateTime.now(),
            notes: notes,
          );
          await _db.insertTransaction(transaction);
          _loadTransactions();
        },
      ),
    );
  }

  void _deleteTransaction(int id) async {
    await _db.deleteTransaction(id);
    _loadTransactions();
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
      );
      _loadTransactions();
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
      );
      _loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle Financeiro'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Seletor de mês
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                ),
                Text(
                  '${_selectedMonth.month}/${_selectedMonth.year}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          // Lista de transações
          Expanded(
            child: FutureBuilder<List<FinancialTransaction>>(
              future: _transactions,
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
                          Icons.trending_up,
                          size: 64,
                          color: AppTheme.warningPastel.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma transação',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Registre suas transações financeiras',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                final transactions = snapshot.data!;
                double totalIncome = 0;
                double totalExpense = 0;

                for (var t in transactions) {
                  if (t.category == 'Renda') {
                    totalIncome += t.amount;
                  } else {
                    totalExpense += t.amount;
                  }
                }

                final balance = totalIncome - totalExpense;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Resumo
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Card(
                              color: AppTheme.successPastel.withOpacity(0.2),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Renda',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        Text(
                                          'R\$ ${totalIncome.toStringAsFixed(2)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: AppTheme.successPastel,
                                              ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Despesa',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        Text(
                                          'R\$ ${totalExpense.toStringAsFixed(2)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: AppTheme.errorPastel,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Card(
                              color: balance >= 0
                                  ? AppTheme.successPastel.withOpacity(0.2)
                                  : AppTheme.errorPastel.withOpacity(0.2),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Saldo',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    Text(
                                      'R\$ ${balance.toStringAsFixed(2)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: balance >= 0
                                                ? AppTheme.successPastel
                                                : AppTheme.errorPastel,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Lista de transações
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: List.generate(
                            transactions.length,
                            (index) {
                              final transaction = transactions[index];
                              final isIncome =
                                  transaction.category == 'Renda';
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: Icon(
                                    isIncome
                                        ? Icons.add_circle
                                        : Icons.remove_circle,
                                    color: isIncome
                                        ? AppTheme.successPastel
                                        : AppTheme.errorPastel,
                                  ),
                                  title: Text(transaction.description),
                                  subtitle: Text(
                                    '${transaction.subcategory} • ${transaction.date.day}/${transaction.date.month}',
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${isIncome ? '+' : '-'} R\$ ${transaction.amount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: isIncome
                                              ? AppTheme.successPastel
                                              : AppTheme.errorPastel,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        iconSize: 16,
                                        onPressed: () =>
                                            _deleteTransaction(transaction.id!),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTransaction,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TransactionDialog extends StatefulWidget {
  final Function(String, double, String, String, String?) onSave;

  const _TransactionDialog({required this.onSave});

  @override
  State<_TransactionDialog> createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<_TransactionDialog> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCategory = 'Despesa';
  String _selectedSubcategory = 'Alimentação';

  final categories = {
    'Renda': ['Salário', 'Freelance', 'Investimento', 'Outro'],
    'Despesa': [
      'Alimentação',
      'Transporte',
      'Saúde',
      'Educação',
      'Lazer',
      'Moradia',
      'Outro'
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedSubcategory = categories[_selectedCategory]![0];
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Transação'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              items: categories.keys
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                    _selectedSubcategory = categories[value]![0];
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedSubcategory,
              isExpanded: true,
              items: categories[_selectedCategory]!
                  .map((subcat) => DropdownMenuItem(
                        value: subcat,
                        child: Text(subcat),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedSubcategory = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Digite a descrição',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Valor',
                hintText: 'Digite o valor',
                prefixText: 'R\$ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                hintText: 'Digite notas adicionais',
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
            if (_descriptionController.text.isNotEmpty &&
                _amountController.text.isNotEmpty) {
              widget.onSave(
                _descriptionController.text,
                double.parse(_amountController.text),
                _selectedCategory,
                _selectedSubcategory,
                _notesController.text.isEmpty ? null : _notesController.text,
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
