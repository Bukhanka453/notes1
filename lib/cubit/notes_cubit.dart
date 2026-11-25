import 'package:flutter_bloc/flutter_bloc.dart';
import 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(const NotesInitial());

  List<Note> get _currentNotes => state.notes;

  void addNote(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final newNote = Note(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: trimmed,
    );

    emit(NotesLoaded(notes: [..._currentNotes, newNote]));
  }

  void deleteNote(String id) {
    final updated = _currentNotes.where((n) => n.id != id).toList();

    if (state is NotesEditing) {
      final editing = (state as NotesEditing).editingNote;
      if (editing != null && editing.id == id) {
        emit(NotesLoaded(notes: updated));
        return;
      }
    }
    emit(NotesLoaded(notes: updated));
  }

  void startEditing(Note note) {
    emit(NotesEditing(notes: _currentNotes, editingNote: note));
  }

  void cancelEditing() {
    emit(NotesLoaded(notes: _currentNotes));
  }

  void updateNote(String id, String newText) {
    final trimmed = newText.trim();
    if (trimmed.isEmpty) {
      deleteNote(id);
      return;
    }

    final updated = _currentNotes
        .map((n) => n.id == id ? n.copyWith(text: trimmed) : n)
        .toList();

    emit(NotesLoaded(notes: updated));
  }

  // Двойной клик: переключение статуса
  void toggleImportance(String id) {
    final updated = _currentNotes
        .map((n) => n.id == id ? n.copyWith(isImportant: !n.isImportant) : n)
        .toList();
    emit(NotesLoaded(notes: updated));
  }

  // Свайп вправо: снять статус важности
  void removeImportance(String id) {
    final updated = _currentNotes
        .map((n) => n.id == id ? n.copyWith(isImportant: false) : n)
        .toList();
    emit(NotesLoaded(notes: updated));
  }
}