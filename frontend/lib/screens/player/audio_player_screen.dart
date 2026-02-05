import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/story.dart';
import '../../models/episode.dart';
import '../../utils/app_theme.dart';
import '../../utils/api_constants.dart';

class AudioPlayerScreen extends StatefulWidget {
  final Story story;
  final List<Episode> episodes;
  final int initialIndex;

  const AudioPlayerScreen({
    super.key,
    required this.story,
    required this.episodes,
    required this.initialIndex,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _audioPlayer;
  late int _currentIndex;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _currentIndex = widget.initialIndex;
    _setupAudioPlayer();
    _loadAudio();
  }

  void _setupAudioPlayer() {
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isLoading = state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;
        });
        
        if (state.processingState == ProcessingState.completed) {
          _onComplete();
        }
      }
    });

    _audioPlayer.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() => _duration = duration);
      }
    });

    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });
  }

  Future<void> _loadAudio() async {
    setState(() => _isLoading = true);
    
    try {
      final episode = widget.episodes[_currentIndex];
      final audioUrl = '${ApiConstants.baseUrl}${episode.audioUrl}';
      print('DEBUG: Loading audio URL: $audioUrl');
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể phát audio: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onComplete() {
    if (_currentIndex < widget.episodes.length - 1) {
      _nextTrack();
    }
  }

  void _togglePlay() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void _previousTrack() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _loadAudio();
    }
  }

  void _nextTrack() {
    if (_currentIndex < widget.episodes.length - 1) {
      setState(() => _currentIndex++);
      _loadAudio();
    }
  }

  void _seekTo(double value) {
    _audioPlayer.seek(Duration(milliseconds: value.toInt()));
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentEpisode = widget.episodes[_currentIndex];
    final imageUrl = widget.story.coverImage.isNotEmpty
        ? '${ApiConstants.baseUrl}${widget.story.coverImage}'
        : null;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
              const Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.keyboard_arrow_down, size: 32),
                      color: Colors.white,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'ĐANG PHÁT',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            widget.story.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showEpisodeList(),
                      icon: const Icon(Icons.playlist_play),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Cover Image
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.white.withOpacity(0.1),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.white.withOpacity(0.1),
                            child: const Icon(
                              Icons.book,
                              size: 80,
                              color: Colors.white70,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.white.withOpacity(0.1),
                          child: const Icon(
                            Icons.book,
                            size: 80,
                            color: Colors.white70,
                          ),
                        ),
                ),
              ),

              const Spacer(),

              // Episode Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      currentEpisode.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tập ${currentEpisode.episodeNumber} / ${widget.episodes.length}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 16,
                        ),
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white.withOpacity(0.3),
                        thumbColor: Colors.white,
                        overlayColor: Colors.white.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: _position.inMilliseconds.toDouble(),
                        max: _duration.inMilliseconds.toDouble() > 0
                            ? _duration.inMilliseconds.toDouble()
                            : 1,
                        onChanged: _seekTo,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Previous
                    IconButton(
                      onPressed: _currentIndex > 0 ? _previousTrack : null,
                      icon: const Icon(Icons.skip_previous),
                      iconSize: 40,
                      color: _currentIndex > 0 
                          ? Colors.white 
                          : Colors.white.withOpacity(0.3),
                    ),

                    // Rewind 10s
                    IconButton(
                      onPressed: () {
                        final newPosition = _position - const Duration(seconds: 10);
                        _audioPlayer.seek(
                          newPosition > Duration.zero ? newPosition : Duration.zero,
                        );
                      },
                      icon: const Icon(Icons.replay_10),
                      iconSize: 36,
                      color: Colors.white,
                    ),

                    // Play/Pause
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _isLoading ? null : _togglePlay,
                        icon: _isLoading
                            ? SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryColor,
                                  strokeWidth: 3,
                                ),
                              )
                            : Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                size: 40,
                                color: AppTheme.primaryColor,
                              ),
                      ),
                    ),

                    // Forward 10s
                    IconButton(
                      onPressed: () {
                        final newPosition = _position + const Duration(seconds: 10);
                        _audioPlayer.seek(
                          newPosition < _duration ? newPosition : _duration,
                        );
                      },
                      icon: const Icon(Icons.forward_10),
                      iconSize: 36,
                      color: Colors.white,
                    ),

                    // Next
                    IconButton(
                      onPressed: _currentIndex < widget.episodes.length - 1 
                          ? _nextTrack 
                          : null,
                      icon: const Icon(Icons.skip_next),
                      iconSize: 40,
                      color: _currentIndex < widget.episodes.length - 1
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  void _showEpisodeList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Danh sách tập',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.episodes.length,
                itemBuilder: (context, index) {
                  final episode = widget.episodes[index];
                  final isPlaying = index == _currentIndex;
                  
                  return ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      if (index != _currentIndex) {
                        setState(() => _currentIndex = index);
                        _loadAudio();
                      }
                    },
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isPlaying 
                            ? AppTheme.primaryColor 
                            : AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: isPlaying
                            ? const Icon(
                                Icons.volume_up,
                                color: Colors.white,
                                size: 20,
                              )
                            : Text(
                                '${episode.episodeNumber}',
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    title: Text(
                      episode.title,
                      style: TextStyle(
                        fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                        color: isPlaying ? AppTheme.primaryColor : null,
                      ),
                    ),
                    subtitle: Text(episode.formattedDuration),
                    trailing: isPlaying
                        ? const Icon(
                            Icons.graphic_eq,
                            color: AppTheme.primaryColor,
                          )
                        : const Icon(Icons.play_circle_outline),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
