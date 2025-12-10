import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../database/database_helper.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({Key? key}) : super(key: key);

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  late Future<List<DiaryEntry>> _entries;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() {
    setState(() {
      _entries = _db.getDiaryEntries();
    });
  }

  void _addEntry() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _DiaryEditorScreen(
          onSave: (title, content, tags) async {
            final entry = DiaryEntry(
              title: title,
              content: content,
              date: DateTime.now(),
              tags: tags,
            );
            await _db.insertDiaryEntry(entry);
            _loadEntries();
          },
        ),
      ),
    );
  }

  void _editEntry(DiaryEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _DiaryEditorScreen(
          entry: entry,
          onSave: (title, content, tags) async {
            final updated = DiaryEntry(
              id: entry.id,
              title: title,
              content: content,
              date: entry.date,
              tags: tags,
            );
            await _db.updateDiaryEntry(updated);
            _loadEntries();
          },
        ),
      ),
    );
  }

  void _deleteEntry(int id) async {
    await _db.deleteDiaryEntry(id);
    _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<DiaryEntry>>(
        future: _entries,
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
                    Icons.book_outlined,
                    size: 64,
                    color: AppTheme.secondaryPastel.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma entrada',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Comece a escrever suas anotações',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final entries = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
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
                              entry.title,
                              style: Theme.of(context).textTheme.titleLarge,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: const Text('Editar'),
                                onTap: () => _editEntry(entry),
                              ),
                              PopupMenuItem(
                                child: const Text('Deletar'),
                                onTap: () => _deleteEntry(entry.id!),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.date.toLocal().toString().split(' ')[0],
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (entry.tags != null && entry.tags!.isNotEmpty)
                            Wrap(
                              spacing: 4,
                              children: entry.tags!
                                  .map((tag) => Chip(
                                    label: Text(tag),
                                    labelStyle: const TextStyle(fontSize: 10),
                                    padding: EdgeInsets.zero,
                                  ))
                                  .toList(),
                            ),
                        ],
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
        onPressed: _addEntry,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DiaryEditorScreen extends StatefulWidget {
  final DiaryEntry? entry;
  final Function(String, String, List<String>?) onSave;

  const _DiaryEditorScreen({
    this.entry,
    required this.onSave,
  });

  @override
  State<_DiaryEditorScreen> createState() => _DiaryEditorScreenState();
}

class _DiaryEditorScreenState extends State<_DiaryEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController = TextEditingController(text: widget.entry?.content ?? '');
    _tagsController = TextEditingController(
      text: widget.entry?.tags?.join(', ') ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'Nova Entrada' : 'Editar Entrada'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (_titleController.text.isNotEmpty &&
                  _contentController.text.isNotEmpty) {
                final tags = _tagsController.text
                    .split(',')
                    .map((t) => t.trim())
                    .where((t) => t.isNotEmpty)
                    .toList();

                widget.onSave(
                  _titleController.text,
                  _contentController.text,
                  tags.isEmpty ? null : tags,
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Digite o título da entrada',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Conteúdo',
                hintText: 'Digite suas anotações aqui',
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (separadas por vírgula)',
                hintText: 'exemplo: reflexão, importante',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
