import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:midi_piano/note.dart';
import 'package:midi_piano/note_controller.dart';
import 'package:flutter_midi/flutter_midi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.orange.shade100,
        appBar: AppBar(
          backgroundColor: Colors.deepOrangeAccent,
          title: Text(
            'MIDI PIANO',
            style: TextStyle(
              color: Colors.orange.shade100,
              fontFamily: 'SourceSansPro',
              fontWeight: FontWeight.bold,
              fontSize: 30.0,
              letterSpacing: 2.0,
            ),
          ),
        ),
        body: const Piano(),
      ),
    );
  }
}

class Piano extends StatefulWidget {
  const Piano({Key? key}) : super(key: key);

  @override
  State<Piano> createState() => _PianoState();
}

class _PianoState extends State<Piano> {
  FlutterMidi flutterMidi = FlutterMidi();
  List<Widget> octaveElements = [];
  List<Widget> noteElements = [];
  int numberOfOctaves = 10;
  int selectedOctave = 0;
  int selectedMidiValue = 0;
  double selectedFrequency = 0.0;
  List<Octave> octaves = [];
  List<Note> notes = [];

  // Loads sf2 midi file and converts it to byte format
  Future<ByteData> loadMidiFile() async {
    return await rootBundle.load('assets/Piano.sf2');
  }

  // Adds octave button to list
  void buildOctaveElements() {
    for (int i = 0; i < numberOfOctaves; i++) {
      octaveElements.add(buildOctaveElement(i));
    }
  }

  // Iterates through notes list and builds
  // piano key buttons then adds buttons
  // to a list to update ui
  void buildPianoKeys() {
    noteElements.clear();
    for (int i = 0; i < notes.length; i++) {
      noteElements.add(buildPianoKey(
          note: notes[i], fgColor: Colors.black, bgColor: Colors.white));
    }
  }

  // Fetches notes of newly selected octave
  void updatePianoKeys() {
    for (var octave in octaves) {
      if (octave.value == selectedOctave) {
        notes = octave.notes;
      }
    }

    buildPianoKeys();
  }

  // Called once at startup to handle
  // setup after acync call is complete
  void startApp(List<Octave> octavesIn) {
    // json file note contents
    octaves = octavesIn;

    // setup initial octave of notes so
    // that keys can be build using them
    for (var octave in octaves) {
      if (octave.value == selectedOctave) {
        notes = octave.notes;
      }
    }

    // builds the piano keys buttons
    buildPianoKeys();
  }

  @override
  void initState() {
    buildOctaveElements();

    // load json file and parse contents
    // once complete start setup of app
    loadNotes().then((value) => startApp(value));

    // load sf2 file then send to midi plugin to use
    loadMidiFile().then((value) => flutterMidi.prepare(sf2: value));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildHeaderElement('Octave', selectedOctave),
              buildHeaderElement('Midi Value', selectedMidiValue),
              buildHeaderElement('Frequency', selectedFrequency),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: octaveElements,
              ),
            ),
            Expanded(
              flex: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: noteElements,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // builds piano key widget to play a note
  Container buildPianoKey(
      {required Note note, fgColor = Colors.black, bgColor = Colors.white}) {
    return Container(
      margin: const EdgeInsets.only(top: 2.0, bottom: 2.0),
      color: bgColor,
      child: TextButton(
        onPressed: () {
          setState(() {
            selectedMidiValue = note.value;
            selectedFrequency = note.frequency;
            flutterMidi.playMidiNote(midi: note.value);
          });
        },
        child: Text(
          note.name,
          style: TextStyle(
            color: fgColor,
            fontFamily: 'SourceSansPro',
            fontWeight: FontWeight.normal,
            fontSize: 20.0,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  // builds a widget to select a octave
  Container buildOctaveElement(int octave) {
    return Container(
      margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      color: Colors.deepOrangeAccent,
      child: TextButton(
        onPressed: () {
          setState(() {
            selectedOctave = octave;
            updatePianoKeys();
          });
        },
        child: Text(
          octave.toString(),
          style: TextStyle(
            color: Colors.orange.shade100,
            fontFamily: 'SourceSansPro',
            fontWeight: FontWeight.normal,
            fontSize: 20.0,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  // builds widget that displays current not information
  Row buildHeaderElement(String elementName, num value) {
    return Row(
      children: [
        Text(
          elementName,
          style: const TextStyle(
            color: Colors.deepOrangeAccent,
            fontFamily: 'SourceSansPro',
            fontWeight: FontWeight.normal,
            fontSize: 15.0,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(
          width: 5.0,
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(5.0),
          child: Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.black,
              fontFamily: 'SourceSansPro',
              fontWeight: FontWeight.normal,
              fontSize: 13.0,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
