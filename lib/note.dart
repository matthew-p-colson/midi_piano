// stores note information to be used in app
class Note {
  int value = 0;
  String name = '';
  double frequency = 0.0;

  Note({this.value = 0, this.name = '', this.frequency = 0.0});

  // factory constructor that takes json object and creates
  // instance of model out of it
  factory Note.fromJson(Map<String, dynamic> data) {
    final value = data['value'];
    final name = data['name'];
    final frequency = data['frequency'];
    return Note(value: value, name: name, frequency: frequency);
  }
}

// stores all the notes for a certain octave
class Octave {
  int value = 0;
  List<Note> notes = [];

  Octave({this.value = 0, required this.notes});
}
