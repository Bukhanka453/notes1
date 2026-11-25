import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/notes_cubit.dart';
import 'cubit/notes_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotesCubit(),
      child: MaterialApp(
        title: 'Заметки',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const NotesPage(),
      ),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _handleSubmit(NotesCubit cubit) {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final state = cubit.state;
    if (state is NotesEditing && state.editingNote != null) {
      cubit.updateNote(state.editingNote!.id, text);
    } else {
      cubit.addNote(text);
    }

    _inputController.clear();
    FocusScope.of(context).unfocus();
  }

  void _startEditing(NotesCubit cubit, Note note) {
    cubit.startEditing(note);
    _inputController.text = note.text;
    _inputController.selection = TextSelection.fromPosition(
      TextPosition(offset: _inputController.text.length),
    );
  }

  void _cancelEditing(NotesCubit cubit) {
    cubit.cancelEditing();
    _inputController.clear();
  }

  void _showFullNote(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (note.isImportant) const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 8),
            const Text('Заметка'),
          ],
        ),
        content: SingleChildScrollView(child: Text(note.text, style: const TextStyle(fontSize: 18))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои заметки'), centerTitle: true),
      body: BlocBuilder<NotesCubit, NotesState>(
        builder: (context, state) {
          final cubit = context.read<NotesCubit>();
          final isEditing = state is NotesEditing && state.editingNote != null;

          return Column(
            children: [
              _buildInputSection(cubit, isEditing),
              const Divider(height: 1),
              Expanded(
                child: state.notes.isEmpty
                    ? _buildEmptyState()
                    : _buildNotesList(context, cubit, state.notes),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputSection(NotesCubit cubit, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _inputController,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              hintText: isEditing ? 'Редактирование...' : 'Введите текст заметки...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (isEditing) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _cancelEditing(cubit),
                    icon: const Icon(Icons.close),
                    label: const Text('Отмена'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => _handleSubmit(cubit),
                  icon: Icon(isEditing ? Icons.check : Icons.save),
                  label: Text(isEditing ? 'Обновить' : 'Сохранить'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_outlined, size: 72, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text('Заметок пока нет', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Двойной клик по заметке делает её важной', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildNotesList(BuildContext context, NotesCubit cubit, List<Note> notes) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final note = notes[index];
        
        return Dismissible(
          key: Key(note.id),
          background: _buildSwipeBackground(Alignment.centerLeft, Colors.blue, Icons.star_border, 'Убрать статус'),
          secondaryBackground: _buildSwipeBackground(Alignment.centerRight, Colors.red, Icons.delete, 'Удалить'),
          
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              cubit.deleteNote(note.id);
              return false; 
            } else if (direction == DismissDirection.startToEnd) {
              if (note.isImportant) {
                cubit.removeImportance(note.id);
              }
              return false;
            }
            return false;
          },
          
          child: GestureDetector(
            onTap: () => _showFullNote(context, note),
            onDoubleTap: () => cubit.toggleImportance(note.id),
            onLongPress: () => _startEditing(cubit, note),
            child: Card(
              elevation: 2,
              color: note.isImportant ? Colors.amber[50] : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: note.isImportant 
                    ? const BorderSide(color: Colors.amber, width: 2) 
                    : BorderSide.none,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: note.isImportant ? Colors.amber : Colors.blue[100],
                  child: note.isImportant 
                      ? const Icon(Icons.star, color: Colors.white) 
                      : Text('${index + 1}', style: const TextStyle(color: Colors.black)),
                ),
                title: Text(
                  note.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: const Icon(Icons.touch_app, color: Colors.grey, size: 20),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwipeBackground(Alignment alignment, Color color, IconData icon, String text) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerLeft) ...[
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
          ] else ...[
            const SizedBox(width: 16),
            Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Icon(icon, color: Colors.white),
          ]
        ],
      ),
    );
  }
}