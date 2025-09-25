import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:taski/core/providers/audio_recorder_provider.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';

class ChatMessageWidget extends ConsumerStatefulWidget {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isLastMessage;
  final String? messageType; // 'text' or 'voice'
  final String? duration; // for voice messages
  final String? path;
  final VoidCallback? onPlayVoice; // callback for voice playback

  const ChatMessageWidget({
    super.key,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isLastMessage = false,
    this.messageType = 'text',
    this.duration,
    this.path,
    this.onPlayVoice,
  });

  @override
  ConsumerState<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends ConsumerState<ChatMessageWidget> {

  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  late StreamController<PlaybackDisposition> localController = 
    StreamController<PlaybackDisposition>.broadcast();
  late Stream<PlaybackDisposition> playerStream;

  final _sliderPosition = _SliderPosition();

  @override
  void initState() {
    setupPlayer();
    playerStream = localController.stream;
    playerStream.listen((event) {
      setState(() {
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    localController.close();
    _player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    
    return Row(
      mainAxisAlignment: widget.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.isUser) ...[
          // AI Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade200.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          XMargin(12),
        ],
        
        // Message bubble
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: config.sw(16),
              vertical: config.sh(12),
            ),
            decoration: BoxDecoration(
              color: widget.isUser 
                  ? Colors.blue.shade500 
                  : isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.isUser 
                      ? Colors.blue.shade200.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
              border: widget.isUser 
                  ? null 
                  : Border.all(
                      color: isDark ? const Color(0xFF333333) : Colors.grey.shade200,
                      width: 1,
                    ),
            ),
            child: widget.messageType == 'audio' 
                ? _buildVoiceMessage(textTheme)
                : _buildTextMessage(textTheme, context),
          ),
        ),
        
        if (widget.isUser) ...[
          XMargin(12),
          // User Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade300, Colors.grey.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextMessage(TextTheme textTheme, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Message text
        SelectableText(
          widget.text,
          style: textTheme.bodyMedium?.copyWith(
            color: widget.isUser ? Colors.white : isDark ? Colors.white : Colors.black87,
            fontSize: config.sp(14),
            height: 1.4,
            fontWeight: widget.isUser ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
        
        YMargin(6),
        
        // Timestamp
        Align(
          alignment: Alignment.bottomRight,
          child: Text(
            _getTimeString(widget.timestamp),
            style: textTheme.bodySmall?.copyWith(
              color: widget.isUser 
                  ? Colors.white.withOpacity(0.8) 
                  : Colors.grey.shade500,
              fontSize: config.sp(11),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceMessage(TextTheme textTheme) {

    return Row(
      children: [
        // Play button
        GestureDetector(
          onTap: () async {
            await playAudio(path: widget.path, url: widget.text);
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: widget.isUser 
                  ? Colors.white.withOpacity(0.2) 
                  : Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _player.isPlaying ? Icons.pause : Icons.play_arrow,
              color: widget.isUser ? Colors.white : Colors.blue.shade600,
              size: 20,
            ),
          ),
        ),
        
        XMargin(0),
        
        // Waveform
        Expanded(
          child: StreamBuilder<PlaybackDisposition>(
            stream: playerStream,
            initialData: PlaybackDisposition.zero(),
            builder: (context, snapshot) {
              var disposition = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      
                      trackShape: RoundedRectSliderTrackShape(),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 3),
                      thumbColor: widget.isUser ? Colors.white : Colors.blue.shade600,
                      activeTrackColor: widget.isUser ? Colors.white : Colors.blue.shade600,
                      inactiveTrackColor: Colors.grey.shade400,
                      disabledThumbColor: widget.isUser ? Colors.white : Colors.blue.shade600
                    ),
                    child: Slider(
                      onChanged: (value) {
                        Duration position = Duration(milliseconds: value.toInt());
                        _sliderPosition.position = position;
                        if (_player.isPlaying || _player.isPaused) {
                          _player.seekToPlayer(position);
                        }
                      },
                      max: disposition.duration.inMilliseconds.toDouble(),
                      value: disposition.position.inMilliseconds.toDouble(),
                    ),
                  ),          
                  // Duration
                  Text(
                    '0:00',
                    style: textTheme.bodySmall?.copyWith(
                      color: widget.isUser 
                          ? Colors.white.withOpacity(0.8) 
                          : Colors.grey.shade600,
                      fontSize: config.sp(11),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        
        XMargin(8),
        
        // Timestamp
        Text(
          _getTimeString(widget.timestamp),
          style: textTheme.bodySmall?.copyWith(
            color: widget.isUser 
                ? Colors.white.withOpacity(0.8) 
                : Colors.grey.shade500,
            fontSize: config.sp(11),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void setupPlayer() async {
    if(!_player.isOpen()) {
      _player.openPlayer();
    }

    _sliderPosition.maxPosition = Duration.zero;
    _sliderPosition.position = Duration.zero;

    _player.setVolume(1.0);
    _player.onProgress?.listen(localController.add);
    _player.setSubscriptionDuration(Duration(milliseconds: 100));
    
  }

  Future<void> playAudio({String? url, String? path}) async {
    try {
      if(!_player.isOpen()) {
        await _player.openPlayer();
      }

      String? uri;

      if(path == null) {
        uri = url;
      } else if(path.isNotEmpty) {
        final file = File(path);

        logger.i('File path: ${file.path}');
        logger.i('File exists: ${file.existsSync()}');

        if(file.existsSync()) {
          uri = file.path;
        } else {
          uri = url;
        }
      } else {
        uri = url;
      }

      await _player.startPlayer(
        fromURI: uri!,
        whenFinished: () {
          // _player.stopPlayer();
          setState(() {
            localController.add(PlaybackDisposition.zero());
          });
        },
      );
      
      
    } catch (e) {
      logger.e('Error playing audio: $e');
    }
  }

  String _getTimeString(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
} 


class _SliderPosition extends ChangeNotifier {
  /// The current position of the slider.
  Duration _position = Duration.zero;

  /// The max position of the slider.
  Duration maxPosition = Duration.zero;

  bool _disposed = false;

  ///
  set position(Duration position) {
    _position = position;

    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  ///
  Duration get position {
    return _position;
  }
}