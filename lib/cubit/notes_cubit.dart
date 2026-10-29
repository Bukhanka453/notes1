import 'package:flutter_bloc/flutter_bloc.dart';
import 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(NotesState());

  void addOrUpdate(String text) {
    text = text.trim();
    if (text.isEmpty) return;

    final notes = [...state.notes];

    if (state.editingNote != null) {
      final i = notes.indexWhere((n) => n.id == state.editingNote!.id);
      notes[i] = notes[i].copyWith(text: text);
    } else {
      notes.add(Note(id: DateTime.now().microsecondsSinceEpoch.toString(), text: text));
    }

    emit(NotesState(notes: notes));
  }

  void startEditing(Note note) => emit(NotesState(notes: state.notes, editingNote: note));

  void cancelEditing() => emit(NotesState(notes: state.notes));

  void delete(String id) =>
      emit(NotesState(notes: state.notes.where((n) => n.id != id).toList()));
}