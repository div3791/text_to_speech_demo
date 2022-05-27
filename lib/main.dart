import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/services.dart';
import 'package:text_to_speech_api/text_to_speech_api.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AudioPlayer player = AudioPlayer();
  String message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text to Speech'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: <Widget>[
              TextField(
                decoration: InputDecoration(hintText: 'Enter Message to play'),
                onChanged: (val) {
                  setState(() {
                    message = val;
                  });
                },
              ),
              SizedBox(
                height: 24,
              ),
              Builder(
                builder: (context) {
                  return RaisedButton.icon(
                    icon: StreamBuilder<AudioPlayerState>(
                        stream: player.onPlayerStateChanged,
                        builder: (context, snapshot) {
                          return Icon(snapshot.data == AudioPlayerState.PLAYING
                              ? Icons.pause
                              : Icons.play_arrow);
                        }),
                    label: StreamBuilder<AudioPlayerState>(
                        stream: player.onPlayerStateChanged,
                        builder: (context, snapshot) {
                          return Text(snapshot.data == AudioPlayerState.PLAYING
                              ? 'PAUSE'
                              : 'PLAY');
                        }),
                    onPressed: () async {
                      if (message.length > 4) {
                        if (player.state == AudioPlayerState.PLAYING) {
                          await player.pause();
                        } else if (player.state == AudioPlayerState.PAUSED) {
                        } else {
                          getRootDirectory();
                        }
                      } else {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Please enter message'),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  getRootDirectory() async {
    TextToSpeechService textToSpeechService =
        TextToSpeechService('API KEY');
    File mp3;
    try {
      mp3 = await textToSpeechService.textToSpeech(
        text: message,
        languageCode: 'en-US',
        audioEncoding: 'MP3',
        voiceName: 'en-US-Wavenet-D',
      );
    } catch (e) {
      print(e);
    }
    if (mp3 == null) {
      print('Mp3 null');
    } else {
      try {
        if (mp3.existsSync()) {
          print('exists');
        }
        print(mp3.path);
        await player.play(mp3.path, isLocal: true);
      } catch (e) {
        print(e);
      }
    }
  }
}
