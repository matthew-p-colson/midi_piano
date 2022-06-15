import 'dart:convert';
import 'package:midi_piano/note.dart';
import 'package:flutter/services.dart';

// load the contents of json file and converts it into
// models for the app to use
Future<List<Octave>> loadNotes() async {
  List<Octave> octaves = [];

  // loads json file to a string
  final jsonFile = await rootBundle.loadString('assets/midi_notes.json');

  // decodes string into json object
  final data = await jsonDecode(jsonFile);

  // iterates through json object and calls
  // the factory method of note to convert
  // data into a model
  for (var octave in data['octaves']) {
    int octaveValue = octave['octave'];
    List<Note> notes = [];
    for (var note in octave['notes']) {
      notes.add(Note.fromJson(note));
    }

    // add notes to octave list
    octaves.add(Octave(value: octaveValue, notes: notes));
  }
  return octaves;
}
