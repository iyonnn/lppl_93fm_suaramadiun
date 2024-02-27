// // ignore_for_file: unused_local_variable, prefer_const_constructors, avoid_print

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:siri_wave/siri_wave.dart';

// class AudioPlayerWidget extends StatefulWidget {
//   final AudioPlayer player;
//   final List<double> audioSamples;
//   final void Function(Duration) updateVisualPosition;

//   AudioPlayerWidget({
//     Key? key,
//     required this.player,
//     required this.audioSamples,
//     required this.updateVisualPosition,
//   }) : super(key: key);

//   @override
//   _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
// }

// class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
//   late SiriWaveController _controller;
//   double _amplitude = 0.0;
//   bool _isPlaying = false;

//   void _updateAmplitude(double amplitude) {
//     setState(() {
//       _amplitude = amplitude;
//       _controller.setAmplitude(_amplitude);
//     });
//   }

//   void _togglePlayback() async {
//     if (_isPlaying) {
//       await widget.player.stop();
//     } else {
//       await widget.player.play();
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _controller = SiriWaveController();

//     widget.player.playerStateStream.listen((playerState) {
//       if (playerState.processingState == ProcessingState.completed ||
//           playerState.processingState == ProcessingState.idle) {
//         setState(() {
//           _isPlaying = false;
//           _updateAmplitude(0.0);
//         });
//       } else if (playerState.processingState == ProcessingState.ready ||
//           playerState.processingState == ProcessingState.buffering ||
//           playerState.processingState == ProcessingState.ready) {
//         setState(() {
//           _isPlaying = true;
//           _updateAmplitude(1.0);
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     widget.player.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: <Widget>[
//         Padding(
//           padding: EdgeInsets.zero,
//           child: SiriWave(
//             controller: _controller,
//             style: SiriWaveStyle.ios_9,
//             options: SiriWaveOptions(
//               height: kIsWeb ? 300 : 180,
//               width: kIsWeb ? 600 : 360,
//               showSupportBar: true,
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(top: 0.0),
//           child: ElevatedButton(
//             onPressed: _togglePlayback,
//             style: ElevatedButton.styleFrom(
//               shape: CircleBorder(),
//               elevation: 5,
//               padding: EdgeInsets.all(10), // Ubah ukuran tombol di sini
//             ),
//             child: Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.5),
//                     spreadRadius: 2,
//                     blurRadius: 5,
//                     offset: Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: _isPlaying
//                   ? Icon(
//                       Icons.stop,
//                       size: 50,
//                     )
//                   : Icon(
//                       Icons.play_circle_filled,
//                       size: 50,
//                     ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
