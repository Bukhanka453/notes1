import 'package:equatable/equatable.dart';

// Модель заметки
class Note extends Equatable {
  final String id;
  final String text;
  final bool isImportant;

  const Note({
    required this.id,
    required this.text,
    this.isImportant = false,
  });

  Note copyWith({String? id, String? text, bool? isImportant}) {
    return Note(
      id: id ?? this.id,
      text: text ?? this.text,
      isImportant: isImportant ?? this.isImportant,
    );
  }

  @override
  List<Object?> get props => [id, text, isImportant];
}

// Состояния
abstract class NotesState extends Equatable {
  final List<Note> notes;

  const NotesState({this.notes = const []});

  @override
  List<Object?> get props => [notes];
}

class NotesInitial extends NotesState {
  const NotesInitial() : super(notes: const []);
}

class NotesEditing extends NotesState {
  final Note? editingNote;

  const NotesEditing({
    required List<Note> notes,
    this.editingNote,
  }) : super(notes: notes);

  @override
  List<Object?> get props => [notes, editingNote];
}

class NotesLoaded extends NotesState {
  const NotesLoaded({required List<Note> notes}) : super(notes: notes);
}