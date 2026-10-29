import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/notes_cubit.dart';
import 'cubit/notes_state.dart';

void main() => runApp(BlocProvider(
      create: (_) => NotesCubit(),
      child: const MaterialApp(home: NotesPage()),
    ));

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotesCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('Заметки')),
      body: BlocBuilder<NotesCubit, NotesState>(
        builder: (context, state) {
          final editing = state.editingNote != null;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Введите текст...',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (editing) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                cubit.cancelEditing();
                                _controller.clear();
                              },
                              child: const Text('Отмена'),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              cubit.addOrUpdate(_controller.text);
                              _controller.clear();
                              FocusScope.of(context).unfocus();
                            },
                            child: Text(editing ? 'Обновить' : 'Сохранить'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.notes.length,
                  itemBuilder: (context, i) {
                    final note = state.notes[i];
                    return Card(
                      child: ListTile(
                        title: Text(note.text),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () {
                                cubit.startEditing(note);
                                _controller.text = note.text;
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => cubit.delete(note.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}