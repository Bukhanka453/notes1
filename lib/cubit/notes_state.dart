class Note {
  final String id;
  final String text;

  Note({required this.id, required this.text});

  Note copyWith({String? text}) => Note(id: id, text: text ?? this.text);
}

class NotesState {
  final List<Note> notes;
  final Note? editingNote;

  NotesState({this.notes = const [], this.editingNote});
}